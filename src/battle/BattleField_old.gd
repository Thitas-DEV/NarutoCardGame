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
var player_chakra: int = 3
var player_max_chakra: int = 3
var player_shield: int = 0
var enemy_shield: int = 0

# Deck management
var draw_pile: Array[AbilityData] = []
var hand_cards: Array[Node] = []
var discard_pile: Array[AbilityData] = []

# Trap & Support slots
var active_trap_card: AbilityData = null
var active_support_card: AbilityData = null

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
@onready var arena_bg: CanvasItem = $Arena2D/Background

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
	phase_manager = ScriptedPhaseManager.new()
	phase_manager.init_phase_manager(self)
	phase_manager.phase_cutscene_started.connect(_on_phase_cutscene_started)
	add_child(phase_manager)
	
	qte_overlay.qte_finished.connect(_on_qte_finished)
	end_turn_btn.pressed.connect(_on_end_turn_pressed)
	cutscene_next_btn.pressed.connect(_on_cutscene_next_pressed)
	
	_setup_battle()

func _setup_battle() -> void:
	player_data = GameManager.active_hero.duplicate(true)
	enemy_data = GameManager.active_enemy_data.duplicate(true) if GameManager.active_enemy_data else CharacterData.new()
	
	player_visual.setup_character(player_data)
	enemy_visual.setup_character(enemy_data)
	
	player_max_chakra = player_data.max_chakra
	player_chakra = player_max_chakra
	
	# Prepare draw pile
	draw_pile = GameManager.player_deck.duplicate()
	draw_pile.shuffle()
	discard_pile.clear()
	
	_start_player_turn()

func _start_player_turn() -> void:
	current_state = TurnState.PLAYER_TURN
	turn_banner.text = "TURNO DO JOGADOR (TURNO %d)" % turn_number
	turn_banner.modulate = Color(0.2, 0.8, 1.0)
	_animate_turn_banner()
	
	player_chakra = player_max_chakra
	player_shield = 0 # Shield resets every turn
	player_visual.update_stats(player_data.current_hp, player_data.max_hp, player_shield, player_chakra, player_max_chakra)
	
	# Draw up to 5 cards
	draw_cards(5)
	
	# Decide enemy intent for this turn
	_plan_enemy_intent()
	
	combo_meter.reset_combo()
	_update_ui()

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

func _spawn_card_in_hand(c_data: AbilityData) -> void:
	var card_ui = CARD_UI_SCENE.instantiate()
	hand_container.add_child(card_ui)
	card_ui.set_card_data(c_data)
	card_ui.card_played.connect(_on_card_played)
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
		var x_pos = start_x + (i * spacing)
		var norm_pos = float(i) / float(maxi(1, total - 1)) - 0.5
		var y_offset = abs(norm_pos) * 20.0
		var rot = norm_pos * 0.15
		card.set_hand_target(Vector2(x_pos, y_offset), rot)
		card.set_playable_state(player_chakra >= card.card_data.chakra_cost)

func _on_card_played(c_data: AbilityData, card_node: Control) -> void:
	if current_state != TurnState.PLAYER_TURN or player_chakra < c_data.chakra_cost:
		_reorganize_hand()
		return
		
	player_chakra -= c_data.chakra_cost
	SoundManager.play_sfx("card_play")
	
	# Remove card from hand
	hand_cards.erase(card_node)
	card_node.queue_free()
	discard_pile.append(c_data)
	
	# Execute Card Logic
	if c_data.ability_type == AbilityData.AbilityType.ULTIMATE:
		pending_ultimate_card = c_data
		current_state = TurnState.QTE_PHASE
		qte_overlay.start_qte(c_data)
		return
		
	_apply_card_effect(c_data, 1.0)
	_reorganize_hand()
	_update_ui()

func _apply_card_effect(c_data: AbilityData, qte_multiplier: float = 1.0) -> void:
	var combo_mult = combo_meter.get_multiplier()
	var final_multiplier = combo_mult * qte_multiplier
	
	# 1. Efeitos Universais Baseados nos Atributos do Resource
	var total_dmg = int(c_data.base_damage * final_multiplier)
	if total_dmg > 0:
		_damage_character(enemy_data, enemy_visual, total_dmg)
		combo_meter.add_combo(c_data.combo_points, c_data.hit_count)
		
	if c_data.base_healing > 0:
		player_data.current_hp = mini(player_data.max_hp, player_data.current_hp + c_data.base_healing)
		player_visual.spawn_floating_text("+%d HP" % c_data.base_healing, Color(0.2, 0.9, 0.3))
		
	if c_data.base_shield > 0:
		player_shield += c_data.base_shield
		SoundManager.play_sfx("chakra_charge")
		player_visual.spawn_floating_text("+%d GUARDA" % c_data.base_shield, Color(0.4, 0.7, 1.0))
		
	if c_data.chakra_gain > 0:
		player_chakra = mini(player_max_chakra + 2, player_chakra + c_data.chakra_gain)
		
	if c_data.draw_cards > 0:
		draw_cards(c_data.draw_cards)
		
	# 2. Efeitos Modulares de Status
	for st in c_data.status_effects:
		if st.get("type", "") == "heal":
			var heal_val = int(st.get("value", 0))
			player_data.current_hp = mini(player_data.max_hp, player_data.current_hp + heal_val)
			player_visual.spawn_floating_text("+%d HP" % heal_val, Color(0.2, 0.9, 0.3))
			
	# 3. Lógica Visual e Estados do Campo por Tipo
	match c_data.ability_type:
		AbilityData.AbilityType.TAIJUTSU, AbilityData.AbilityType.NINJUTSU:
			player_visual.play_attack_animation(enemy_visual, c_data.animation_key)
			
		AbilityData.AbilityType.GENJUTSU:
			pass
				
		AbilityData.AbilityType.TRAP:
			active_trap_card = c_data
			trap_slot.visible = true
			trap_label.text = "🎴 ARMADILHA ATIVA"
			SoundManager.play_sfx("kawarimi")
			
		AbilityData.AbilityType.SUPPORT:
			active_support_card = c_data
			support_slot.visible = true
			support_label.text = "🤝 " + c_data.support_name.to_upper()
				
		AbilityData.AbilityType.ULTIMATE:
			player_visual.play_attack_animation(enemy_visual, c_data.animation_key)

	# Check Scripted Phase triggers or Battle Win
	_check_battle_state()

func _damage_character(target_data: CharacterData, target_visual: Node2D, amount: int) -> void:
	if target_data == enemy_data and enemy_shield > 0:
		if enemy_shield >= amount:
			enemy_shield -= amount
			target_visual.spawn_floating_text("-%d DEF" % amount, Color(0.5, 0.7, 1.0))
			amount = 0
		else:
			amount -= enemy_shield
			enemy_shield = 0
			
	if amount > 0:
		target_data.current_hp = maxi(0, target_data.current_hp - amount)
		target_visual.spawn_floating_text("-%d" % amount, Color(1.0, 0.2, 0.2))
		
	target_visual.update_stats(target_data.current_hp, target_data.max_hp, (player_shield if target_data == player_data else enemy_shield), (player_chakra if target_data == player_data else 0), target_data.max_chakra)

func _on_qte_finished(success: bool, multiplier: float) -> void:
	current_state = TurnState.PLAYER_TURN
	if pending_ultimate_card:
		_apply_card_effect(pending_ultimate_card, multiplier)
		pending_ultimate_card = null
		_reorganize_hand()
		_update_ui()

func _on_end_turn_pressed() -> void:
	if current_state != TurnState.PLAYER_TURN:
		return
		
	# Discard remaining hand
	for c in hand_cards:
		discard_pile.append(c.card_data)
		c.queue_free()
	hand_cards.clear()
	
	_start_enemy_turn()

func _start_enemy_turn() -> void:
	current_state = TurnState.ENEMY_TURN
	turn_banner.text = "TURNO DO OPONENTE"
	turn_banner.modulate = Color(1.0, 0.3, 0.3)
	_animate_turn_banner()
	
	var tw = create_tween()
	tw.tween_interval(0.8)
	tw.tween_callback(_execute_enemy_action)

func _plan_enemy_intent() -> void:
	var enemy_id = enemy_data.id
	match enemy_id:
		"gaara":
			if turn_number % 2 == 1:
				enemy_visual.set_intent("shield", 14)
			else:
				enemy_visual.set_intent("attack", 18)
		"kakashi":
			enemy_visual.set_intent("jutsu", 15)
		"zabuza":
			enemy_visual.set_intent("attack", 16)
		_:
			enemy_visual.set_intent("attack", 10)

func _execute_enemy_action() -> void:
	if enemy_data.current_hp <= 0:
		return
		
	# Check if Player has active Kawarimi Trap!
	if active_trap_card and active_trap_card.id == "kawarimi_trap":
		enemy_visual.play_attack_animation(player_visual, "attack")
		player_visual.trigger_kawarimi_substitution()
		active_trap_card = null
		trap_slot.visible = false
		_finish_enemy_turn()
		return
		
	# Execute Enemy Attack
	enemy_visual.play_attack_animation(player_visual, "attack")
	var dmg = 12
	if enemy_data.id == "gaara":
		dmg = 18
	elif enemy_data.id == "kakashi":
		dmg = 15
		
	# Apply damage to player
	var effective_dmg = dmg
	if player_shield > 0:
		if player_shield >= effective_dmg:
			player_shield -= effective_dmg
			player_visual.spawn_floating_text("BLOQUEADO!", Color(0.4, 0.8, 1.0))
			effective_dmg = 0
		else:
			effective_dmg -= player_shield
			player_shield = 0
			
	if effective_dmg > 0:
		player_data.current_hp = maxi(0, player_data.current_hp - effective_dmg)
		player_visual.spawn_floating_text("-%d" % effective_dmg, Color(1.0, 0.2, 0.2))
		
	player_visual.update_stats(player_data.current_hp, player_data.max_hp, player_shield, player_chakra, player_max_chakra)
	
	_finish_enemy_turn()

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
	# Check scripted phase
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
		player_visual.update_stats(player_data.current_hp, player_data.max_hp, player_shield, player_chakra, player_max_chakra)
		enemy_visual.update_stats(enemy_data.current_hp, enemy_data.max_hp, enemy_shield, 0, enemy_data.max_chakra)
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
	chakra_label.text = "%d / %d" % [player_chakra, player_max_chakra]
	draw_pile_label.text = str(draw_pile.size())
	discard_pile_label.text = str(discard_pile.size())
	player_visual.update_stats(player_data.current_hp, player_data.max_hp, player_shield, player_chakra, player_max_chakra)

func _animate_turn_banner() -> void:
	turn_banner.visible = true
	turn_banner.modulate.a = 0.0
	var tw = create_tween()
	tw.tween_property(turn_banner, "modulate:a", 1.0, 0.2)
	tw.tween_interval(0.8)
	tw.tween_property(turn_banner, "modulate:a", 0.0, 0.3)
	tw.tween_callback(func(): turn_banner.visible = false)
