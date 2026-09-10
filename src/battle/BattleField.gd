# res://src/battle/BattleField.gd
extends Control

enum TurnState {
	PLAYER_TURN,
	ENEMY_TURN,
	SCRIPTED_CUTSCENE,
	QTE_PHASE,
	GAME_OVER
}

var current_state: TurnState = TurnState.PLAYER_TURN
var turn_number: int = 1

# Combat entities
var player_data: CharacterData
var enemy_data: CharacterData
var player_shield: int = 0
var enemy_shield: int = 0

# Reservas de Chakra Elemental (Estilo Pokémon TCG)
# Mapeia ChakraElement.Type -> quantidade acumulada
var player_chakra_pool: Dictionary = {
	ChakraElement.Type.WATER: 0,
	ChakraElement.Type.FIRE: 0,
	ChakraElement.Type.WIND: 0,
	ChakraElement.Type.EARTH: 0,
	ChakraElement.Type.LIGHTNING: 0
}

var enemy_chakra_pool: Dictionary = {
	ChakraElement.Type.WATER: 0,
	ChakraElement.Type.FIRE: 0,
	ChakraElement.Type.WIND: 0,
	ChakraElement.Type.EARTH: 0,
	ChakraElement.Type.LIGHTNING: 0
}

# Deck management
var draw_pile: Array[AbilityData] = []
var hand_cards: Array[Node] = []
var discard_pile: Array[AbilityData] = []
var exhaust_pile: Array[AbilityData] = []

# Enemy Deck management
var enemy_draw_pile: Array[AbilityData] = []
var enemy_hand_cards: Array[AbilityData] = []
var enemy_discard_pile: Array[AbilityData] = []
var enemy_exhaust_pile: Array[AbilityData] = []

# Trap & Support slots
var active_trap_card: AbilityData = null
var active_enemy_trap_card: AbilityData = null
var active_support_card: AbilityData = null

# Clones das Sombras
var player_clone_visual: Node2D = null
var enemy_clone_visual: Node2D = null
const CHARACTER_VISUAL_SCENE = preload("res://src/battle/CharacterVisual.tscn")

# Target arrow
var target_arrow: Line2D

# Node references
@onready var player_visual: Node2D = $Arena2D/PlayerVisual
@onready var enemy_visual: Node2D = $Arena2D/EnemyVisual
@onready var hand_container: Control = $UI/HandContainer
@onready var combo_meter: Control = $UI/ComboMeter
@onready var qte_overlay: Control = $UI/QTEOverlay
@onready var chakra_label: Label = $UI/BottomBar/ChakraOrb/ChakraLabel
@onready var draw_pile_label: Label = $UI/BottomBar/DrawPile/Label
@onready var discard_pile_label: Label = $UI/BottomBar/DiscardPile/Label
@onready var end_turn_btn: Button = $UI/BottomBar/EndTurnButton
@onready var turn_banner: Label = $UI/TurnBanner
@onready var trap_slot: Panel = $UI/FieldZones/TrapSlot
@onready var trap_label: Label = $UI/FieldZones/TrapSlot/TrapLabel
@onready var support_slot: Panel = $UI/FieldZones/SupportSlot
@onready var support_label: Label = $UI/FieldZones/SupportSlot/SupportLabel
@onready var arena_bg: TextureRect = $Arena2D/Background

# Cutscene dialog
@onready var cutscene_panel: Panel = $UI/CutscenePanel
@onready var cutscene_speaker: Label = $UI/CutscenePanel/SpeakerLabel
@onready var cutscene_text: RichTextLabel = $UI/CutscenePanel/TextLabel
@onready var cutscene_next_btn: Button = $UI/CutscenePanel/NextButton

var pending_ultimate_card: AbilityData = null
var phase_manager: ScriptedPhaseManager
var current_cutscene_dialogue: Array[Dictionary] = []
var current_dialogue_index: int = 0

const CARD_UI_SCENE = preload("res://src/battle/CardUI.tscn")

func _ready() -> void:
	# Add Line2D for targeting
	target_arrow = Line2D.new()
	target_arrow.width = 12.0
	target_arrow.default_color = Color(1.0, 0.2, 0.2, 0.8)
	target_arrow.visible = false
	target_arrow.z_index = 50
	add_child(target_arrow)

	phase_manager = ScriptedPhaseManager.new()
	phase_manager.init_phase_manager(self)
	phase_manager.phase_cutscene_started.connect(_on_phase_cutscene_started)
	add_child(phase_manager)
	
	# Instancia o gerenciador de efeitos visuais na Arena2D
	var battle_vfx = BattleVFX.new()
	battle_vfx.name = "BattleVFX"
	$Arena2D.add_child(battle_vfx)
	
	qte_overlay.qte_finished.connect(_on_qte_finished)
	end_turn_btn.pressed.connect(_on_end_turn_pressed)
	cutscene_next_btn.pressed.connect(_on_cutscene_next_pressed)
	
	_setup_battle()

func shake_arena(intensity: float = 8.0, duration: float = 0.25) -> void:
	var arena = $Arena2D
	var original_pos = Vector2.ZERO
	var tw = create_tween()
	var steps = maxi(2, int(duration / 0.04))
	var cur_intensity = intensity
	for i in range(steps):
		var offset = Vector2(randf_range(-cur_intensity, cur_intensity), randf_range(-cur_intensity, cur_intensity))
		cur_intensity = maxf(0.0, cur_intensity - (intensity / float(steps)))
		tw.tween_property(arena, "position", offset, 0.04)
	tw.tween_property(arena, "position", original_pos, 0.04)

func _setup_battle() -> void:
	if GameManager.active_hero:
		player_data = GameManager.active_hero.duplicate(true)
	elif Database.get_character("naruto"):
		player_data = Database.get_character("naruto").duplicate(true)
	else:
		player_data = CharacterData.new()
		
	if GameManager.active_enemy_data:
		enemy_data = GameManager.active_enemy_data.duplicate(true)
	elif Database.get_character("sasuke"):
		enemy_data = Database.get_character("sasuke").duplicate(true)
	else:
		enemy_data = CharacterData.new()
	
	if has_player_clone():
		player_clone_visual.queue_free()
		player_clone_visual = null
	if has_enemy_clone():
		enemy_clone_visual.queue_free()
		enemy_clone_visual = null
		
	player_visual.setup_character(player_data)
	enemy_visual.setup_character(enemy_data)
	
	_setup_background()
	_reset_chakra_pools()

## Carrega o cenário de fundo com base no encontro ativo ou ID da fase
func _setup_background() -> void:
	var bg_path = ""
	match GameManager.active_encounter_id:
		"kakashi_bell_test":
			bg_path = "res://assets/backgrounds/naruto_stage.bmp"
		"zabuza_mist":
			bg_path = "res://assets/backgrounds/sasuke_stage.bmp"
		"gaara_chunin_phase1":
			bg_path = "res://assets/backgrounds/chunin_arena.png"
		"valley_of_the_end":
			bg_path = "res://assets/backgrounds/valley_of_the_end.png"
		"forest_of_death":
			bg_path = "res://assets/backgrounds/forest_of_death.png"
		_:
			bg_path = "res://assets/backgrounds/forest_of_death.png"
			
	if ResourceLoader.exists(bg_path):
		arena_bg.texture = load(bg_path)
	elif ResourceLoader.exists("res://assets/backgrounds/konoha_training - Copia.png"):
		arena_bg.texture = load("res://assets/backgrounds/konoha_training - Copia.png")
	elif ResourceLoader.exists("res://assets/backgrounds/florest.bmp"):
		arena_bg.texture = load("res://assets/backgrounds/florest.bmp")
	
	# Prepare draw piles
	draw_pile = GameManager.player_deck.duplicate()
	draw_pile.shuffle()
	discard_pile.clear()
	exhaust_pile.clear()
	hand_cards.clear()
	
	enemy_draw_pile = enemy_data.starting_deck.duplicate()
	enemy_draw_pile.shuffle()
	enemy_discard_pile.clear()
	enemy_exhaust_pile.clear()
	enemy_hand_cards.clear()
	
	# Mão inicial
	draw_cards(5)
	_enemy_draw_cards(5)
	
	_start_player_turn()

func _reset_chakra_pools() -> void:
	for elem in [ChakraElement.Type.WATER, ChakraElement.Type.FIRE, ChakraElement.Type.WIND, ChakraElement.Type.EARTH, ChakraElement.Type.LIGHTNING]:
		player_chakra_pool[elem] = 0
		enemy_chakra_pool[elem] = 0

func _start_player_turn() -> void:
	current_state = TurnState.PLAYER_TURN
	turn_banner.text = "TURNO DO JOGADOR (TURNO %d)" % turn_number
	turn_banner.modulate = Color(0.2, 0.8, 1.0)
	_animate_turn_banner()
	
	player_shield = 0 # Shield reseta a cada turno
	
	# Sorteia 1 energia elemental aleatória de acordo com as afinidades do ninja (Estilo Pokémon TCG)
	_gain_random_chakra(true)
	
	# Compra 1 carta por turno
	draw_cards(1)
	
	combo_meter.reset_combo()
	_update_ui()
	_reorganize_hand()

func _gain_random_chakra(is_player: bool) -> void:
	var char_data = player_data if is_player else enemy_data
	var pool = player_chakra_pool if is_player else enemy_chakra_pool
	var visual = player_visual if is_player else enemy_visual
	
	if char_data.chakra_affinities.is_empty():
		# Especialista em Taijutsu (ex: Rock Lee): Não usa chakra elemental
		if is_player:
			visual.spawn_floating_text("🥋 Foco em Taijutsu!", Color(0.95, 0.6, 0.2))
		return
		
	var chosen_element: ChakraElement.Type = char_data.chakra_affinities[randi() % char_data.chakra_affinities.size()]
	pool[chosen_element] = pool.get(chosen_element, 0) + 1
	
	var elem_name = ChakraElement.get_element_short_name(chosen_element)
	var elem_icon = ChakraElement.get_element_icon(chosen_element)
	var elem_color = ChakraElement.get_element_color(chosen_element)
	
	visual.spawn_floating_text("+1 %s %s" % [elem_icon, elem_name], elem_color)
	if is_player:
		SoundManager.play_sfx("chakra_charge", 1.2)

func draw_cards(amount: int) -> void:
	for i in range(amount):
		if draw_pile.is_empty():
			if discard_pile.is_empty():
				break
			draw_pile = discard_pile.duplicate()
			discard_pile.clear()
			draw_pile.shuffle()
			
		var card_data = draw_pile.pop_back()
		if card_data:
			_spawn_card_in_hand(card_data)
			
	_reorganize_hand()

func _enemy_draw_cards(amount: int) -> void:
	for i in range(amount):
		if enemy_draw_pile.is_empty():
			if enemy_discard_pile.is_empty():
				break
			enemy_draw_pile = enemy_discard_pile.duplicate()
			enemy_discard_pile.clear()
			enemy_draw_pile.shuffle()
			
		var card_data = enemy_draw_pile.pop_back()
		if card_data:
			enemy_hand_cards.append(card_data)

func _spawn_card_in_hand(c_data: AbilityData) -> void:
	var card_ui = CARD_UI_SCENE.instantiate()
	hand_container.add_child(card_ui)
	card_ui.set_card_data(c_data)
	card_ui.card_played.connect(_on_card_played)
	card_ui.target_drag_moved.connect(_on_target_drag_moved)
	card_ui.target_drag_ended.connect(_on_target_drag_ended)
	hand_cards.append(card_ui)

func _reorganize_hand() -> void:
	var total = hand_cards.size()
	if total == 0:
		return
		
	var center_x = hand_container.size.x / 2.0
	var spacing = 120.0
	var total_w = (total - 1) * spacing
	var start_x = center_x - (total_w / 2.0) - 80.0
	
	for i in range(total):
		var card = hand_cards[i]
		
		# Curva da mão em leque
		var center_offset = float(i) - (float(total - 1) / 2.0)
		var angle = center_offset * 0.1
		var height_offset = abs(center_offset) * abs(center_offset) * 8.0
		
		var x_pos = start_x + (i * spacing)
		card.set_hand_target(Vector2(x_pos, height_offset), angle)
		
		# Validação de jogabilidade: Taijutsu não exige chakra elemental; Ninjutsu exige elemento >= custo
		var is_playable = false
		if card.card_data.required_element == ChakraElement.Type.NONE or card.card_data.element_cost == 0:
			is_playable = true
		else:
			var current_elem_chakra = player_chakra_pool.get(card.card_data.required_element, 0)
			is_playable = (current_elem_chakra >= card.card_data.element_cost)
			
		# Restrições de Clone das Sombras
		if card.card_data.requires_clone and not has_player_clone():
			is_playable = false
		if card.card_data.id == "kagebunshin" and has_player_clone():
			is_playable = false
			
		card.set_playable_state(is_playable)

func _on_target_drag_moved(card_node: Control, mouse_pos: Vector2) -> void:
	if not target_arrow.visible:
		target_arrow.visible = true
		
	var start_pos = card_node.global_position + Vector2(card_node.size.x/2, 0)
	
	var points = PackedVector2Array()
	points.append(start_pos)
	
	# Curva de Bézier para a flecha
	var control_point = Vector2(start_pos.x, mouse_pos.y)
	for i in range(1, 11):
		var t = float(i) / 10.0
		var p1 = start_pos.lerp(control_point, t)
		var p2 = control_point.lerp(mouse_pos, t)
		points.append(p1.lerp(p2, t))
		
	target_arrow.points = points

func has_player_clone() -> bool:
	return player_clone_visual != null and is_instance_valid(player_clone_visual) and not player_clone_visual.is_queued_for_deletion()

func has_enemy_clone() -> bool:
	return enemy_clone_visual != null and is_instance_valid(enemy_clone_visual) and not enemy_clone_visual.is_queued_for_deletion()

func are_animations_running() -> bool:
	var running = (player_visual != null and player_visual.is_busy()) or (enemy_visual != null and enemy_visual.is_busy())
	if not running and has_player_clone() and player_clone_visual.is_busy():
		running = true
	if not running and has_enemy_clone() and enemy_clone_visual.is_busy():
		running = true
	return running

func summon_clone(is_player_team: bool) -> void:
	if is_player_team:
		if has_player_clone():
			player_visual.spawn_floating_text("MÁXIMO DE 1 CLONE!", Color(1.0, 0.4, 0.4))
			return
		player_visual.play_custom_animation("chakra_pose_clone")
		var clone = CHARACTER_VISUAL_SCENE.instantiate()
		clone.position = player_visual.position + Vector2(100, 30)
		clone.z_index = player_visual.z_index + 1
		clone.visible = true
		clone.modulate = Color(1.0, 1.0, 1.0, 0.95)
		$Arena2D.add_child(clone)
		player_clone_visual = clone
		clone.setup_clone(player_data, true)
	else:
		if has_enemy_clone():
			return
		enemy_visual.play_custom_animation("chakra_pose_clone")
		var clone = CHARACTER_VISUAL_SCENE.instantiate()
		clone.position = enemy_visual.position + Vector2(-100, 30)
		clone.z_index = enemy_visual.z_index + 1
		clone.visible = true
		clone.modulate = Color(1.0, 1.0, 1.0, 0.95)
		$Arena2D.add_child(clone)
		enemy_clone_visual = clone
		clone.setup_clone(enemy_data, false)
	_reorganize_hand()

func _on_target_drag_ended(card_node: Control, mouse_pos: Vector2) -> void:
	target_arrow.visible = false
	if are_animations_running():
		_reorganize_hand()
		return
	var enemy_rect = Rect2(enemy_visual.global_position - Vector2(120, 150), Vector2(240, 300))
	if enemy_rect.has_point(mouse_pos):
		_on_card_played(card_node.card_data, card_node)

func _on_card_played(c_data: AbilityData, card_node: Control) -> void:
	# Não permite outro ataque enquanto qualquer animação estiver em execução
	if current_state != TurnState.PLAYER_TURN or are_animations_running():
		_reorganize_hand()
		return
		
	# Validação de Requisito de Clone
	if c_data.requires_clone and not has_player_clone():
		player_visual.spawn_floating_text("REQUER CLONE!", Color(1.0, 0.4, 0.4))
		_reorganize_hand()
		return
		
	# Limite de 1 Clone ativo por vez
	if c_data.id == "kagebunshin" and has_player_clone():
		player_visual.spawn_floating_text("MÁXIMO DE 1 CLONE!", Color(1.0, 0.4, 0.4))
		_reorganize_hand()
		return
		
	# Validação de Custo Elemental
	var has_chakra = false
	if c_data.required_element == ChakraElement.Type.NONE or c_data.element_cost == 0:
		has_chakra = true
	else:
		has_chakra = (player_chakra_pool.get(c_data.required_element, 0) >= c_data.element_cost)
		
	if not has_chakra:
		_reorganize_hand()
		return
		
	# Consome o chakra elemental necessário
	if c_data.required_element != ChakraElement.Type.NONE and c_data.element_cost > 0:
		player_chakra_pool[c_data.required_element] -= c_data.element_cost
		
	SoundManager.play_sfx("card_play")
	
	# Remove carta da mão
	hand_cards.erase(card_node)
	card_node.queue_free()
	
	if c_data.is_exhaust:
		exhaust_pile.append(c_data)
	else:
		discard_pile.append(c_data)
	
	# Se for Ultimate com QTE, inicia minigame
	if c_data.qte_difficulty > 0:
		pending_ultimate_card = c_data
		current_state = TurnState.QTE_PHASE
		qte_overlay.start_qte(c_data)
		return
		
	_apply_card_effect(c_data, 1.0)
	_reorganize_hand()
	_update_ui()

func _apply_card_effect(c_data: AbilityData, qte_multiplier: float = 1.0, triggers: Array[String] = ["on_play"], is_player: bool = true) -> void:
	var combo_mult = combo_meter.get_multiplier() if is_player else 1.0
	var final_multiplier = combo_mult * qte_multiplier
	
	var caster_visual = player_visual if is_player else enemy_visual
	var target_visual = enemy_visual if is_player else player_visual
	
	# Sincronização do impacto visual: executa triggers e scripts no momento exato do impacto!
	var on_impact_callback = func():
		for trigger in triggers:
			for script in c_data.scripts:
				if script.get("trigger", "") == trigger:
					_execute_script(script, final_multiplier, is_player)
		_check_battle_state()
	
	# Lógica Visual e Estados Específicos por Tipo
	match c_data.ability_type:
		AbilityData.AbilityType.TAIJUTSU, AbilityData.AbilityType.NINJUTSU, AbilityData.AbilityType.ULTIMATE:
			caster_visual.execute_ability(c_data, target_visual, on_impact_callback)
			
			# Se for ataque físico do jogador e houver Clone em campo, o clone repete o ataque físico!
			if is_player and has_player_clone() and c_data.ability_type == AbilityData.AbilityType.TAIJUTSU and c_data.delivery_type == AbilityData.DeliveryType.MELEE_DASH:
				var on_original_finished: Callable
				on_original_finished = func(anim_name: String):
					if caster_visual.animation_finished.is_connected(on_original_finished):
						caster_visual.animation_finished.disconnect(on_original_finished)
					var target_current_hp = enemy_data.current_hp if is_player else player_data.current_hp
					if has_player_clone() and target_current_hp > 0 and current_state != TurnState.GAME_OVER:
						player_clone_visual.execute_ability(c_data, target_visual, func():
							for script in c_data.scripts:
								if script.get("trigger", "") == "on_play" and script.get("effect", "") == "damage":
									var clone_dmg = int(int(script.get("value", 10)) * final_multiplier)
									var t_data = enemy_data if is_player else player_data
									_damage_character(t_data, target_visual, clone_dmg, not is_player)
									combo_meter.add_combo(1, 1)
							_check_battle_state()
						)
				caster_visual.animation_finished.connect(on_original_finished)
			
		AbilityData.AbilityType.GENJUTSU:
			on_impact_callback.call()
				
		AbilityData.AbilityType.TRAP:
			if is_player:
				active_trap_card = c_data
				trap_slot.visible = true
				trap_label.text = "🎴 " + c_data.name.to_upper()
			else:
				active_enemy_trap_card = c_data
			caster_visual.execute_ability(c_data, target_visual, on_impact_callback)
			
		AbilityData.AbilityType.SUPPORT:
			if is_player:
				active_support_card = c_data
				support_slot.visible = true
				support_label.text = "🤝 " + c_data.support_name.to_upper()
			caster_visual.execute_ability(c_data, target_visual, on_impact_callback)
			
		_:
			caster_visual.execute_ability(c_data, target_visual, on_impact_callback)

func _execute_script(script: Dictionary, multiplier: float, is_player: bool = true) -> void:
	var effect = script.get("effect", "")
	var value = script.get("value", 0)
	
	var caster_data = player_data if is_player else enemy_data
	var caster_visual = player_visual if is_player else enemy_visual
	var target_data = enemy_data if is_player else player_data
	var target_visual = enemy_visual if is_player else player_visual
	
	match effect:
		"damage":
			var total_dmg = int(int(value) * multiplier)
			_damage_character(target_data, target_visual, total_dmg, not is_player)
			if is_player:
				var combo = int(script.get("combo", 1))
				var hits = int(script.get("hits", 1))
				combo_meter.add_combo(combo, hits)
		"heal":
			caster_data.current_hp = mini(caster_data.max_hp, caster_data.current_hp + int(value))
			caster_visual.spawn_floating_text("+%d HP" % int(value), Color(0.2, 0.9, 0.3))
		"shield":
			if is_player:
				player_shield += int(value)
			else:
				enemy_shield += int(value)
			SoundManager.play_sfx("chakra_charge")
			caster_visual.spawn_floating_text("+%d GUARDA" % int(value), Color(0.4, 0.7, 1.0))
		"lose_all_chakra":
			var pool = player_chakra_pool if is_player else enemy_chakra_pool
			for k in pool.keys():
				pool[k] = 0
		"self_damage":
			var dmg = int(value)
			if dmg > 0:
				caster_data.current_hp = maxi(0, caster_data.current_hp - dmg)
				caster_visual.spawn_floating_text("-%d" % dmg, Color(1.0, 0.2, 0.2))
				if caster_visual.has_method("play_damage_animation"):
					caster_visual.play_damage_animation()
				elif caster_visual.has_method("play_hit_reaction"):
					caster_visual.play_hit_reaction("normal")
		"reduce_max_hp":
			caster_data.max_hp = maxi(1, caster_data.max_hp - int(value))
			caster_data.current_hp = mini(caster_data.current_hp, caster_data.max_hp)
		"apply_status":
			if is_player:
				draw_cards(int(value))
			else:
				_enemy_draw_cards(int(value))
		"summon_clone":
			summon_clone(is_player)
		"plant_trap":
			pass

func _damage_character(target_data: CharacterData, target_visual: Node2D, amount: int, is_target_player: bool) -> void:
	# Intercepção pelo Kage Bunshin (Clone das Sombras)
	# Caso o ninja tenha um clone ativo, ele se sacrificará primeiro para absorver o golpe,
	# mantendo a armadilha armada (não ativa a armadilha enquanto houver clone para se sacrificar).
	if is_target_player and has_player_clone():
		var clone = player_clone_visual
		player_clone_visual = null
		clone.spawn_floating_text("INTERCEPTOU!", Color(1.0, 0.9, 0.2))
		clone.dissipate_clone()
		target_visual.spawn_floating_text("PROTEGIDO!", Color(0.4, 0.8, 1.0))
		_reorganize_hand()
		return
	elif not is_target_player and has_enemy_clone():
		var clone = enemy_clone_visual
		enemy_clone_visual = null
		clone.spawn_floating_text("INTERCEPTOU!", Color(1.0, 0.9, 0.2))
		clone.dissipate_clone()
		target_visual.spawn_floating_text("PROTEGIDO!", Color(0.4, 0.8, 1.0))
		return

	# Armadilha de Substituição (Kawarimi) é acionada quando o ninja é atacado diretamente (sem clone)
	if is_target_player and active_trap_card != null:
		active_trap_card = null
		trap_slot.visible = false
		target_visual.trigger_kawarimi_substitution()
		return
	elif not is_target_player and active_enemy_trap_card != null:
		active_enemy_trap_card = null
		target_visual.trigger_kawarimi_substitution()
		return
		
	# Absorção de escudo
	if is_target_player and player_shield > 0:
		if player_shield >= amount:
			player_shield -= amount
			target_visual.spawn_floating_text("BLOQUEADO!", Color(0.4, 0.8, 1.0))
			amount = 0
		else:
			amount -= player_shield
			player_shield = 0
	elif not is_target_player and enemy_shield > 0:
		if enemy_shield >= amount:
			enemy_shield -= amount
			target_visual.spawn_floating_text("BLOQUEADO!", Color(0.5, 0.7, 1.0))
			amount = 0
		else:
			amount -= enemy_shield
			enemy_shield = 0
			
	if amount > 0:
		target_data.current_hp = maxi(0, target_data.current_hp - amount)
		target_visual.spawn_floating_text("-%d" % amount, Color(1.0, 0.2, 0.2))
		if target_visual.has_method("play_damage_animation"):
			target_visual.play_damage_animation()
		elif target_visual.has_method("play_hit_reaction"):
			target_visual.play_hit_reaction("normal")
		
	var shield = player_shield if is_target_player else enemy_shield
	var pool = player_chakra_pool if is_target_player else enemy_chakra_pool
	target_visual.update_stats(target_data.current_hp, target_data.max_hp, shield, pool)

func _on_qte_finished(success: bool, multiplier: float) -> void:
	current_state = TurnState.PLAYER_TURN
	if pending_ultimate_card:
		var active_triggers: Array[String] = ["on_play"]
		if success:
			active_triggers.append("on_qte_success")
		else:
			active_triggers.append("on_qte_failure")
			
		_apply_card_effect(pending_ultimate_card, multiplier, active_triggers)
		pending_ultimate_card = null
		_reorganize_hand()
		_update_ui()

func _on_end_turn_pressed() -> void:
	if current_state != TurnState.PLAYER_TURN or are_animations_running():
		return
	
	_start_enemy_turn()

func _start_enemy_turn() -> void:
	current_state = TurnState.ENEMY_TURN
	turn_banner.text = "TURNO DO OPONENTE"
	turn_banner.modulate = Color(1.0, 0.3, 0.3)
	_animate_turn_banner()
	
	enemy_shield = 0
	_enemy_draw_cards(1)
	_gain_random_chakra(false)
	
	var tw = create_tween()
	tw.tween_interval(0.8)
	tw.tween_callback(_play_next_enemy_card)

func _play_next_enemy_card() -> void:
	if enemy_data.current_hp <= 0 or current_state == TurnState.GAME_OVER:
		_finish_enemy_turn()
		return
		
	# Aguarda animações pendentes antes de a IA agir
	if are_animations_running():
		var tw_wait = create_tween()
		tw_wait.tween_interval(0.25)
		tw_wait.tween_callback(_play_next_enemy_card)
		return
		
	# Avalia cartas viáveis com base nas energias e Taijutsu
	var playable: Array[AbilityData] = []
	for c in enemy_hand_cards:
		if c.required_element == ChakraElement.Type.NONE or c.element_cost == 0:
			playable.append(c)
		elif enemy_chakra_pool.get(c.required_element, 0) >= c.element_cost:
			playable.append(c)
			
	if playable.is_empty():
		_finish_enemy_turn()
		return
		
	# Seleciona melhor carta
	var best_card: AbilityData = playable[0]
	var best_score = -999
	var is_critical_hp = (enemy_data.current_hp < enemy_data.max_hp * 0.5)
	
	for c in playable:
		var score = c.element_cost * 2
		if is_critical_hp and (c.ability_type == AbilityData.AbilityType.SUPPORT or c.ability_type == AbilityData.AbilityType.TRAP):
			score += 10
		if c.ability_type == AbilityData.AbilityType.ULTIMATE:
			score += 6
			
		if score > best_score:
			best_score = score
			best_card = c
			
	# Consome chakra da IA se for elemental
	if best_card.required_element != ChakraElement.Type.NONE and best_card.element_cost > 0:
		enemy_chakra_pool[best_card.required_element] -= best_card.element_cost
		
	enemy_hand_cards.erase(best_card)
	
	if best_card.is_exhaust:
		enemy_exhaust_pile.append(best_card)
	else:
		enemy_discard_pile.append(best_card)
		
	var success = true
	var multiplier = 1.0
	if best_card.qte_difficulty > 0:
		success = randf() > 0.35
		if not success:
			multiplier = 0.5
			
	var triggers: Array[String] = ["on_play"]
	if best_card.qte_difficulty > 0:
		if success:
			triggers.append("on_qte_success")
		else:
			triggers.append("on_qte_failure")
			
	# Atualiza intenção visual
	if best_card.ability_type == AbilityData.AbilityType.SUPPORT:
		enemy_visual.set_intent("shield", 0)
	elif best_card.ability_type == AbilityData.AbilityType.NINJUTSU or best_card.ability_type == AbilityData.AbilityType.ULTIMATE:
		enemy_visual.set_intent("jutsu", best_card.element_cost)
	else:
		enemy_visual.set_intent("attack", 0)
			
	_apply_card_effect(best_card, multiplier, triggers, false)
	_update_ui()
	
	var tw = create_tween()
	tw.tween_interval(1.4)
	tw.tween_callback(_play_next_enemy_card)

func _finish_enemy_turn() -> void:
	var tw = create_tween()
	tw.tween_interval(0.6)
	tw.tween_callback(func():
		_check_battle_state()
		if current_state != TurnState.GAME_OVER and current_state != TurnState.SCRIPTED_CUTSCENE:
			turn_number += 1
			_start_player_turn()
	)

func _check_battle_state() -> void:
	if phase_manager.check_phase_triggers(player_data.current_hp, enemy_data.current_hp):
		return
		
	if enemy_data.current_hp <= 0:
		_trigger_victory()
	elif player_data.current_hp <= 0:
		_trigger_defeat()

func _on_phase_cutscene_started(title: String, dialogue: Array[Dictionary]) -> void:
	current_state = TurnState.SCRIPTED_CUTSCENE
	current_cutscene_dialogue = dialogue
	current_dialogue_index = 0
	cutscene_panel.visible = true
	_show_current_dialogue()

func _show_current_dialogue() -> void:
	if current_dialogue_index < current_cutscene_dialogue.size():
		var entry = current_cutscene_dialogue[current_dialogue_index]
		cutscene_speaker.text = entry.speaker
		cutscene_speaker.modulate = entry.color
		cutscene_text.text = entry.text
		SoundManager.play_sfx("chakra_charge", 1.2)
	else:
		cutscene_panel.visible = false
		phase_manager.apply_phase_buffs(player_data, enemy_data)
		player_visual.update_stats(player_data.current_hp, player_data.max_hp, player_shield, player_chakra_pool)
		enemy_visual.update_stats(enemy_data.current_hp, enemy_data.max_hp, enemy_shield, enemy_chakra_pool)
		_start_player_turn()

func _on_cutscene_next_pressed() -> void:
	current_dialogue_index += 1
	_show_current_dialogue()

func _trigger_victory() -> void:
	current_state = TurnState.GAME_OVER
	SoundManager.play_sfx("qte_success", 1.5)
	turn_banner.text = "VITÓRIA SHINOBI! 🏆"
	turn_banner.modulate = Color(0.2, 1.0, 0.4)
	_animate_turn_banner()
	
	# Salva o nó de história como concluído
	if not GameManager.completed_nodes.has(GameManager.active_encounter_id):
		GameManager.completed_nodes.append(GameManager.active_encounter_id)
	
	var tw = create_tween()
	tw.tween_interval(1.5)
	tw.tween_callback(func():
		get_tree().change_scene_to_file("res://src/ui/RewardScreen.tscn")
	)

func _trigger_defeat() -> void:
	current_state = TurnState.GAME_OVER
	SoundManager.play_sfx("hit", 0.5)
	turn_banner.text = "DERROTA... TENTE NOVAMENTE"
	turn_banner.modulate = Color(1.0, 0.2, 0.2)
	_animate_turn_banner()
	
	var tw = create_tween()
	tw.tween_interval(2.0)
	tw.tween_callback(func():
		get_tree().change_scene_to_file("res://src/map/StoryMap.tscn")
	)

func _update_ui() -> void:
	# Atualiza texto das naturezas de chakra
	var chakra_strs: Array[String] = []
	if player_data.chakra_affinities.is_empty():
		chakra_strs.append("🥋 Taijutsu Puro")
	else:
		for aff in player_data.chakra_affinities:
			var icon = ChakraElement.get_element_icon(aff)
			var short_name = ChakraElement.get_element_short_name(aff)
			var count = player_chakra_pool.get(aff, 0)
			chakra_strs.append("%s %s: %d" % [icon, short_name, count])
			
	chakra_label.text = "  |  ".join(chakra_strs)
	draw_pile_label.text = str(draw_pile.size())
	discard_pile_label.text = str(discard_pile.size())
	
	player_visual.update_stats(player_data.current_hp, player_data.max_hp, player_shield, player_chakra_pool)
	enemy_visual.update_stats(enemy_data.current_hp, enemy_data.max_hp, enemy_shield, enemy_chakra_pool)

func _animate_turn_banner() -> void:
	turn_banner.visible = true
	turn_banner.modulate.a = 0.0
	var tw = create_tween()
	tw.tween_property(turn_banner, "modulate:a", 1.0, 0.2)
	tw.tween_interval(0.8)
	tw.tween_property(turn_banner, "modulate:a", 0.0, 0.3)
	tw.tween_callback(func(): turn_banner.visible = false)
