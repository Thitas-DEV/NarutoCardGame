# res://src/battle/CharacterVisual.gd
extends Node2D

signal animation_finished(anim_name: String)

@export var is_player: bool = true
@export var is_clone: bool = false
@export var character_name: String = "Naruto"

var character_data: CharacterData
var target_pos: Vector2
var base_pos: Vector2
var is_animating: bool = false
var is_substituting: bool = false
var damage_tween: Tween = null

# Visual state
var breathing_time: float = 0.0
var aura_pulse: float = 0.0
var aura_active: bool = false
var aura_color: Color = Color(0.2, 0.6, 1.0, 0.4)
var current_vfx: String = ""
var vfx_progress: float = 0.0
var clone_offsets: Array[Vector2] = []
var floating_texts: Array[Dictionary] = []

# Status effects display
var status_dict: Dictionary = {} # { "burn": 2, "bleed": 1 }

# Sprites & Visual nodes
@onready var animated_sprite: AnimatedSprite2D = $VisualRoot/AnimatedSprite2D if has_node("VisualRoot/AnimatedSprite2D") else null
@onready var sprite_2d: Sprite2D = $VisualRoot/Sprite2D if has_node("VisualRoot/Sprite2D") else null
@onready var smoke_overlay: AnimatedSprite2D = $VisualRoot/SmokeOverlay if has_node("VisualRoot/SmokeOverlay") else null
@onready var running_effect: AnimatedSprite2D = $VisualRoot/RunningEffect if has_node("VisualRoot/RunningEffect") else null
@onready var impact_explosion: AnimatedSprite2D = $VisualRoot/ImpactExplosion if has_node("VisualRoot/ImpactExplosion") else null

# UI elements
@onready var hp_bar: ProgressBar = $UIContainer/HPBar
@onready var hp_label: Label = $UIContainer/HPBar/HPLabel
@onready var shield_bar: ProgressBar = $UIContainer/ShieldBar
@onready var name_label: Label = $UIContainer/NameLabel
@onready var chakra_container: HBoxContainer = $UIContainer/ChakraContainer
@onready var status_container: HBoxContainer = $UIContainer/StatusContainer
@onready var intent_container: HBoxContainer = $UIContainer/IntentContainer
@onready var intent_label: Label = $UIContainer/IntentContainer/IntentLabel
@onready var body_sprite: CanvasItem = $VisualRoot

func _ready() -> void:
	base_pos = position
	_setup_sprite_nodes()
	queue_redraw()

func _setup_sprite_nodes() -> void:
	# Check if animated sprite exists or needs creation
	if not animated_sprite and not sprite_2d:
		if has_node("VisualRoot/AnimatedSprite2D"):
			animated_sprite = $VisualRoot/AnimatedSprite2D as AnimatedSprite2D
		elif has_node("VisualRoot/Sprite2D"):
			sprite_2d = $VisualRoot/Sprite2D as Sprite2D
			
	if not smoke_overlay and has_node("VisualRoot/SmokeOverlay"):
		smoke_overlay = $VisualRoot/SmokeOverlay as AnimatedSprite2D
	if not running_effect and has_node("VisualRoot/RunningEffect"):
		running_effect = $VisualRoot/RunningEffect as AnimatedSprite2D
	if not impact_explosion and has_node("VisualRoot/ImpactExplosion"):
		impact_explosion = $VisualRoot/ImpactExplosion as AnimatedSprite2D
			
	if animated_sprite:
		animated_sprite.play("idle")
		animated_sprite.flip_h = not is_player
	elif sprite_2d:
		sprite_2d.flip_h = not is_player
		
	if smoke_overlay:
		smoke_overlay.flip_h = not is_player
		smoke_overlay.visible = false
	if running_effect:
		running_effect.flip_h = not is_player
		running_effect.position.x = -20 if is_player else 20
		running_effect.visible = false
	if impact_explosion:
		impact_explosion.flip_h = not is_player
		impact_explosion.visible = false

func setup_character(data: CharacterData) -> void:
	character_data = data
	name_label.text = data.name
	_setup_character_animations(data)
	update_stats(data.current_hp, data.max_hp, 0, {})
	queue_redraw()

func play_smoke_overlay(on_finished: Callable = Callable()) -> void:
	if not smoke_overlay:
		if on_finished.is_valid():
			on_finished.call()
		return
	smoke_overlay.visible = true
	smoke_overlay.frame = 0
	smoke_overlay.play("default")
	SoundManager.play_sfx("kawarimi")
	
	var tw = create_tween()
	tw.tween_interval(0.5)
	tw.tween_callback(func():
		smoke_overlay.visible = false
		if on_finished.is_valid():
			on_finished.call()
	)

func set_running_vfx_active(active: bool) -> void:
	if running_effect:
		running_effect.visible = active
		if active:
			running_effect.frame = 0
			running_effect.play("default")
		else:
			running_effect.stop()

func play_impact_explosion(on_finished: Callable = Callable()) -> void:
	if not impact_explosion:
		if on_finished.is_valid():
			on_finished.call()
		return
	impact_explosion.visible = true
	impact_explosion.frame = 0
	impact_explosion.play("default")
	
	var tw = create_tween()
	tw.tween_interval(0.35)
	tw.tween_callback(func():
		impact_explosion.visible = false
		if on_finished.is_valid():
			on_finished.call()
	)

func setup_clone(data: CharacterData, on_player_side: bool) -> void:
	is_clone = true
	is_player = on_player_side
	character_data = data
	base_pos = position
	_setup_sprite_nodes()
	name_label.text = "Clone das Sombras"
	_setup_character_animations(data)
	hp_bar.max_value = 1
	hp_bar.value = 1
	hp_label.text = "1 / 1"
	shield_bar.visible = false
	chakra_container.visible = false
	if intent_container:
		intent_container.visible = false
	spawn_floating_text("CLONE!", Color(1.0, 0.85, 0.2))
	modulate = Color(1.0, 1.0, 1.0, 0.0)
	var tw = create_tween()
	tw.tween_property(self, "modulate:a", 0.95, 0.2)
	play_smoke_overlay()
	queue_redraw()

func dissipate_clone(on_complete: Callable = Callable()) -> void:
	is_animating = true
	spawn_floating_text("POOF!", Color(0.85, 0.85, 0.85))
	play_custom_animation("damage")
	play_smoke_overlay()
	var tw = create_tween()
	tw.tween_property(self, "modulate:a", 0.0, 0.35)
	tw.tween_callback(func():
		is_animating = false
		if on_complete.is_valid():
			on_complete.call()
		queue_free()
	)

func _setup_character_animations(data: CharacterData) -> void:
	if not animated_sprite:
		return
		
	# 1. Se o CharacterData tiver um SpriteFrames exclusivo configurado
	if data.sprite_frames:
		animated_sprite.sprite_frames = data.sprite_frames
		animated_sprite.visible = true
		animated_sprite.flip_h = not is_player
		play_custom_animation("idle")
	# 2. Convenção automática em res://data/characters/<id>_frames.tres
	elif ResourceLoader.exists("res://data/characters/%s_frames.tres" % data.id):
		var frames = load("res://data/characters/%s_frames.tres" % data.id)
		if frames:
			animated_sprite.sprite_frames = frames
			animated_sprite.visible = true
			animated_sprite.flip_h = not is_player
			play_custom_animation("idle")
	# 3. Convenção automática em res://assets/characters/<id>/<id>_frames.tres
	elif ResourceLoader.exists("res://assets/characters/%s/%s_frames.tres" % [data.id, data.id]):
		var frames = load("res://assets/characters/%s/%s_frames.tres" % [data.id, data.id])
		if frames:
			animated_sprite.sprite_frames = frames
			animated_sprite.visible = true
			animated_sprite.flip_h = not is_player
			play_custom_animation("idle")
	# 4. Naruto usa as animações padrões embutidas na cena
	elif data.id == "naruto":
		animated_sprite.visible = true
		animated_sprite.flip_h = not is_player
		play_custom_animation("idle")
	# 5. Caso ainda não haja sprites para o ninja, usa o desenho procedural estilizado
	else:
		animated_sprite.visible = false

func play_custom_animation(anim_name: String) -> void:
	if not animated_sprite or not animated_sprite.visible or not animated_sprite.sprite_frames:
		return
	if animated_sprite.sprite_frames.has_animation(anim_name) and animated_sprite.sprite_frames.get_frame_count(anim_name) > 0:
		animated_sprite.play(anim_name)
	elif anim_name != "damage" and anim_name != "idle" and animated_sprite.sprite_frames.has_animation("attack") and animated_sprite.sprite_frames.get_frame_count("attack") > 0:
		animated_sprite.play("attack")

func update_stats(hp: int, max_hp: int, shield: int, chakra_pool: Dictionary = {}) -> void:
	hp_bar.max_value = max_hp
	hp_bar.value = hp
	hp_label.text = "%d / %d" % [hp, max_hp]
	
	shield_bar.max_value = max_hp
	shield_bar.value = shield
	shield_bar.visible = shield > 0
	
	# Update chakra orbs / badges
	for child in chakra_container.get_children():
		child.queue_free()
		
	if character_data:
		if character_data.chakra_affinities.is_empty():
			var lbl = Label.new()
			lbl.text = "🥋 Taijutsu"
			lbl.add_theme_font_size_override("font_size", 10)
			lbl.modulate = Color(0.95, 0.6, 0.3)
			chakra_container.add_child(lbl)
		else:
			for aff in character_data.chakra_affinities:
				var count = chakra_pool.get(aff, 0)
				var badge = Panel.new()
				badge.custom_minimum_size = Vector2(30, 18)
				var style = StyleBoxFlat.new()
				style.set_corner_radius_all(4)
				style.bg_color = ChakraElement.get_element_color(aff)
				badge.add_theme_stylebox_override("panel", style)
				
				var lbl = Label.new()
				lbl.text = "%s %d" % [ChakraElement.get_element_icon(aff), count]
				lbl.set_anchors_preset(Control.PRESET_FULL_RECT)
				lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
				lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
				lbl.add_theme_font_size_override("font_size", 9)
				lbl.add_theme_color_override("font_color", Color.WHITE)
				badge.add_child(lbl)
				chakra_container.add_child(badge)

func set_intent(intent_type: String, value: int) -> void:
	if is_player:
		intent_container.visible = false
		return
		
	intent_container.visible = true
	match intent_type:
		"attack":
			intent_label.text = "⚔️ %d DMG" % value
			intent_label.modulate = Color(1.0, 0.3, 0.3)
		"shield":
			intent_label.text = "🛡️ +%d DEF" % value
			intent_label.modulate = Color(0.4, 0.7, 1.0)
		"jutsu":
			intent_label.text = "⚡ JUTSU (%d)" % value
			intent_label.modulate = Color(1.0, 0.8, 0.2)
		"buff":
			intent_label.text = "✨ FOCO"
			intent_label.modulate = Color(0.3, 1.0, 0.5)

func _process(delta: float) -> void:
	breathing_time += delta * 2.5
	if aura_active:
		aura_pulse += delta * 5.0
		
	if vfx_progress > 0.0:
		vfx_progress = maxf(0.0, vfx_progress - delta)
		
	# Process floating text animations
	var i = floating_texts.size() - 1
	while i >= 0:
		var ft = floating_texts[i]
		ft.time += delta
		ft.pos.y -= delta * 40.0
		ft.alpha = clampf(1.0 - (ft.time / ft.max_time), 0.0, 1.0)
		if ft.time >= ft.max_time:
			floating_texts.remove_at(i)
		i -= 1
		
	queue_redraw()

func spawn_floating_text(text: String, color: Color) -> void:
	floating_texts.append({
		"text": text,
		"pos": Vector2(0, -60),
		"color": color,
		"time": 0.0,
		"max_time": 1.2,
		"alpha": 1.0
	})

# ==================== COMBAT ANIMATIONS ====================

func execute_ability(ability: AbilityData, target_character: Node2D, on_hit: Callable = Callable()) -> void:
	if not ability:
		return
		
	is_animating = true
	match ability.delivery_type:
		AbilityData.DeliveryType.MELEE_DASH:
			_execute_melee_dash(ability, target_character, on_hit)
		AbilityData.DeliveryType.PROJECTILE:
			_execute_projectile(ability, target_character, on_hit)
		AbilityData.DeliveryType.CELESTIAL_STRIKE:
			_execute_celestial_strike(ability, target_character, on_hit)
		AbilityData.DeliveryType.CLONES:
			_execute_clones(ability, target_character, on_hit)
		AbilityData.DeliveryType.SUMMON:
			_execute_summon(ability, target_character, on_hit)
		AbilityData.DeliveryType.SELF_CAST:
			_execute_self_cast(ability, on_hit)
		_:
			_execute_melee_dash(ability, target_character, on_hit)

func play_attack_animation(target_character: Node2D, anim_key: String) -> void:
	# Fallback para chamadas legadas que passam apenas string
	var fake_ability = AbilityData.new()
	fake_ability.animation_key = anim_key
	if anim_key in ["katon", "katon_multi"]:
		fake_ability.delivery_type = AbilityData.DeliveryType.PROJECTILE
		fake_ability.required_element = ChakraElement.Type.FIRE
	elif anim_key in ["chidori", "ougi_chidori"]:
		fake_ability.delivery_type = AbilityData.DeliveryType.MELEE_DASH
		fake_ability.required_element = ChakraElement.Type.LIGHTNING
	elif anim_key in ["bunshin", "bunshin_attack"]:
		fake_ability.delivery_type = AbilityData.DeliveryType.CLONES
	else:
		fake_ability.delivery_type = AbilityData.DeliveryType.MELEE_DASH
	execute_ability(fake_ability, target_character)

func _execute_melee_dash(ability: AbilityData, target_character: Node2D, on_hit: Callable) -> void:
	var anim_key = ability.animation_key
	var tw = create_tween()
	var dest = target_character.global_position + (Vector2(-70, 0) if is_player else Vector2(70, 0))
	match anim_key:
		"rasengan", "ougi_rasengan":
			var bf = _get_battlefield()
			var clone = (bf.player_clone_visual if is_player else bf.enemy_clone_visual) if bf else null
			
			# Sequência Cinematográfica do Rasengan Clássico:
			
			# 1. Clone executa a fumaça e "some" momentaneamente
			if clone and is_instance_valid(clone):
				clone.play_smoke_overlay()
				clone.visible = false
			else:
				play_smoke_overlay()
				
			tw.tween_interval(0.2)
			
			# 2. Animação do naruto ao lado do clone conjurando rasengan
			tw.tween_callback(func():
				play_custom_animation("rasengan_clone_generate")
				SoundManager.play_sfx("rasengan")
			)
			tw.tween_interval(0.65)
			
			# 3. Clone executa a fumaça e volta para o local original & Naruto com rasengan pronto
			tw.tween_callback(func():
				play_custom_animation("naruto_holding_rasengan")
				if clone and is_instance_valid(clone):
					clone.visible = true
					clone.play_smoke_overlay()
					clone.play_custom_animation("idle")
			)
			tw.tween_interval(0.35)
			
			# 4. Naruto executa a animação de corrida com rasengan
			tw.tween_callback(func():
				play_custom_animation("naruto_attack_rasengan")
				set_running_vfx_active(true)
			)
			tw.tween_property(self, "global_position", dest, 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
			
			# 5. Impacto e explosão no oponente
			tw.tween_callback(func():
				set_running_vfx_active(false)
				if target_character.has_method("play_impact_explosion"):
					target_character.play_impact_explosion()
				if on_hit.is_valid():
					on_hit.call()
				else:
					target_character.play_damage_animation()
				SoundManager.play_sfx("hit", 1.2)
				_trigger_screen_shake(ability.screen_shake_intensity if ability.screen_shake_intensity > 0 else 10.0)
			)
			
			tw.tween_interval(0.25)
			
			# 6. Retorno à base
			tw.tween_property(self, "global_position", base_pos, 0.25).set_trans(Tween.TRANS_SINE)
			tw.tween_callback(func():
				is_animating = false
				play_custom_animation("idle")
				animation_finished.emit(anim_key)
			)
			
		"chidori", "ougi_chidori":
			play_custom_animation(anim_key)
			aura_active = true
			aura_color = Color(0.3, 0.6, 1.0, 0.9)
			SoundManager.play_sfx("chidori")
			current_vfx = "chidori"
			vfx_progress = 1.0
			tw.tween_property(self, "global_position", dest, 0.18).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
			tw.tween_callback(func():
				if on_hit.is_valid():
					on_hit.call()
				else:
					target_character.play_damage_animation()
				SoundManager.play_sfx("hit", 1.3)
				_trigger_screen_shake(ability.screen_shake_intensity if ability.screen_shake_intensity > 0 else 8.0)
			)
			tw.tween_interval(0.25)
			tw.tween_property(self, "global_position", base_pos, 0.2).set_trans(Tween.TRANS_QUAD)
			tw.tween_callback(func():
				aura_active = false
				current_vfx = ""
				is_animating = false
				play_custom_animation("idle")
				animation_finished.emit(anim_key)
			)
			
		"leaf_hurricane", "naruto_combo", "lotus":
			play_custom_animation(anim_key)
			tw.tween_property(self, "global_position", dest, 0.2).set_trans(Tween.TRANS_BACK)
			tw.tween_callback(func():
				if on_hit.is_valid():
					on_hit.call()
				else:
					target_character.play_damage_animation()
				SoundManager.play_sfx("hit", 1.1)
				_trigger_screen_shake(ability.screen_shake_intensity if ability.screen_shake_intensity > 0 else 5.0)
			)
			tw.tween_interval(0.15)
			tw.tween_property(self, "global_position", base_pos, 0.2)
			tw.tween_callback(func():
				is_animating = false
				play_custom_animation("idle")
				animation_finished.emit(anim_key)
			)
			
		_:
			# Ataque físico simples (Soco simples / Taijutsu básico)
			# 1. Inicia animação de corrida "run" e corre até o adversário
			play_custom_animation("run")
			tw.tween_property(self, "global_position", dest, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
			# 2. Ao alcançar o alvo, executa a animação "attack" (soco) e aplica impacto
			tw.tween_callback(func():
				play_custom_animation("attack")
				if on_hit.is_valid():
					on_hit.call()
				else:
					target_character.play_damage_animation()
				SoundManager.play_sfx("hit")
				_trigger_screen_shake(ability.screen_shake_intensity if ability.screen_shake_intensity > 0 else 3.0)
			)
			# 3. Intervalo de impacto do golpe
			tw.tween_interval(0.25)
			# 4. Retorna para a posição base
			tw.tween_property(self, "global_position", base_pos, 0.2).set_trans(Tween.TRANS_QUAD)
			# 5. Volta à animação "idle" e finaliza estado de animação
			tw.tween_callback(func():
				is_animating = false
				play_custom_animation("idle")
				animation_finished.emit(anim_key)
			)

func _execute_projectile(ability: AbilityData, target_character: Node2D, on_hit: Callable) -> void:
	var anim_key = ability.animation_key if ability.animation_key != "" else "attack"
	play_custom_animation(anim_key)
	
	# O ninja permanece na base em pose de conjuração!
	var vfx = _get_battle_vfx()
	var flip = 1.0 if is_player else -1.0
	var start_pos = global_position + Vector2(35 * flip, -35)
	var end_pos = target_character.global_position + Vector2(0, -35)
	
	if vfx:
		vfx.spawn_projectile(start_pos, end_pos, ability, func():
			if on_hit.is_valid():
				on_hit.call()
			else:
				target_character.play_damage_animation()
			SoundManager.play_sfx("hit", 0.9)
			_trigger_screen_shake(ability.screen_shake_intensity if ability.screen_shake_intensity > 0 else 6.0)
		)
	else:
		if on_hit.is_valid():
			on_hit.call()
		else:
			target_character.play_damage_animation()
		
	var tw = create_tween()
	tw.tween_interval(0.45)
	tw.tween_callback(func():
		is_animating = false
		play_custom_animation("idle")
		animation_finished.emit(anim_key)
	)

func _execute_celestial_strike(ability: AbilityData, target_character: Node2D, on_hit: Callable) -> void:
	var anim_key = ability.animation_key if ability.animation_key != "" else "chidori"
	play_custom_animation(anim_key)
	
	aura_active = true
	aura_color = Color(0.4, 0.7, 1.0, 0.9)
	SoundManager.play_sfx("chidori", 0.8)
	
	var vfx = _get_battle_vfx()
	var target_pos = target_character.global_position + Vector2(0, -10)
	
	if vfx:
		vfx.spawn_celestial_strike(target_pos, ability, func():
			if on_hit.is_valid():
				on_hit.call()
			else:
				target_character.play_damage_animation()
			SoundManager.play_sfx("hit", 1.4)
			_trigger_screen_shake(ability.screen_shake_intensity if ability.screen_shake_intensity > 0 else 14.0, 0.4)
		)
	else:
		if on_hit.is_valid():
			on_hit.call()
		else:
			target_character.play_damage_animation()
		
	var tw = create_tween()
	tw.tween_interval(0.6)
	tw.tween_callback(func():
		aura_active = false
		is_animating = false
		play_custom_animation("idle")
		animation_finished.emit(anim_key)
	)

func _execute_clones(ability: AbilityData, target_character: Node2D, on_hit: Callable) -> void:
	var anim_key = ability.animation_key if ability.animation_key != "" else "attack"
	play_custom_animation(anim_key)
	
	var vfx = _get_battle_vfx()
	if vfx:
		vfx.spawn_clone_rush(global_position, target_character.global_position, character_data, func():
			if on_hit.is_valid():
				on_hit.call()
			else:
				target_character.play_damage_animation()
			_trigger_screen_shake(ability.screen_shake_intensity if ability.screen_shake_intensity > 0 else 5.0)
		)
	else:
		if on_hit.is_valid():
			on_hit.call()
		else:
			target_character.play_damage_animation()
		
	var tw = create_tween()
	tw.tween_interval(0.65)
	tw.tween_callback(func():
		is_animating = false
		play_custom_animation("idle")
		animation_finished.emit(anim_key)
	)

func _execute_summon(ability: AbilityData, target_character: Node2D, on_hit: Callable) -> void:
	var anim_key = ability.animation_key if ability.animation_key != "" else "attack"
	play_custom_animation(anim_key)
	SoundManager.play_sfx("kawarimi")
	
	var vfx = _get_battle_vfx()
	if vfx:
		vfx.spawn_summon_strike(target_character.global_position, ability, func():
			if on_hit.is_valid():
				on_hit.call()
			else:
				target_character.play_damage_animation()
			SoundManager.play_sfx("hit", 0.7)
			_trigger_screen_shake(ability.screen_shake_intensity if ability.screen_shake_intensity > 0 else 10.0, 0.3)
		)
	else:
		if on_hit.is_valid():
			on_hit.call()
		else:
			target_character.play_damage_animation()
		
	var tw = create_tween()
	tw.tween_interval(0.75)
	tw.tween_callback(func():
		is_animating = false
		play_custom_animation("idle")
		animation_finished.emit(anim_key)
	)

func _execute_self_cast(ability: AbilityData, on_hit: Callable) -> void:
	if ability.id == "kawarimi_trap":
		# O ninja apenas prepara a armadilha no slot! A animação de Kawarimi NÃO toca agora!
		play_custom_animation("idle")
		spawn_floating_text("ARMADILHA PREPARADA!", Color(0.95, 0.8, 0.2))
		SoundManager.play_sfx("card_play")
		if on_hit.is_valid():
			on_hit.call()
		var tw_trap = create_tween()
		tw_trap.tween_interval(0.3)
		tw_trap.tween_callback(func():
			is_animating = false
			animation_finished.emit("trap_set")
		)
		return

	var anim_key = ability.animation_key if ability.animation_key != "" else "guard"
	play_custom_animation(anim_key)
	
	match ability.id:
		"doton_wall":
			var vfx = _get_battle_vfx()
			if vfx:
				var flip = 1.0 if is_player else -1.0
				vfx.spawn_earth_wall(global_position + Vector2(40 * flip, 0))
				SoundManager.play_sfx("hit", 0.6)
			_trigger_screen_shake(ability.screen_shake_intensity if ability.screen_shake_intensity > 0 else 4.0)
		"kagebunshin":
			SoundManager.play_sfx("kawarimi")
		_:
			aura_active = true
			aura_color = Color(0.3, 0.8, 0.4, 0.6)
			SoundManager.play_sfx("card_play")
			
	if on_hit.is_valid():
		on_hit.call()
		
	var tw = create_tween()
	var cast_duration = 0.8 if ability.id == "kagebunshin" else 0.4
	tw.tween_interval(cast_duration)
	tw.tween_callback(func():
		aura_active = false
		is_animating = false
		play_custom_animation("idle")
		animation_finished.emit(anim_key)
	)

func _get_battle_vfx() -> BattleVFX:
	if get_parent():
		var vfx = get_parent().get_node_or_null("BattleVFX") as BattleVFX
		if vfx:
			return vfx
	if get_tree() and get_tree().root:
		return get_tree().root.find_child("BattleVFX", true, false) as BattleVFX
	return null

func _get_battlefield() -> Node:
	var cur = get_parent()
	while cur:
		if cur.has_method("shake_arena"):
			return cur
		cur = cur.get_parent()
	return null

func _trigger_screen_shake(intensity: float, duration: float = 0.25) -> void:
	if intensity <= 0.0:
		return
	var bf = _get_battlefield()
	if bf:
		bf.shake_arena(intensity, duration)

func play_hit_reaction(hit_type: String = "normal") -> void:
	play_damage_animation()

func play_damage_animation() -> void:
	if is_substituting:
		return
		
	play_custom_animation("damage")
	
	# Calcula a duração para a animação "damage" rodar os seus frames por completo
	var anim_duration = 0.5
	if animated_sprite and animated_sprite.sprite_frames and animated_sprite.sprite_frames.has_animation("damage"):
		var frame_count = animated_sprite.sprite_frames.get_frame_count("damage")
		if frame_count > 0:
			var spd = animated_sprite.sprite_frames.get_animation_speed("damage")
			if spd > 0.0:
				anim_duration = float(frame_count) / spd
	anim_duration = clampf(anim_duration, 0.4, 1.2)
	
	# Efeito de recuo físico ao levar dano
	var tw = create_tween()
	var push_dir = Vector2(-25, 0) if is_player else Vector2(25, 0)
	tw.tween_property(self, "position", base_pos + push_dir, 0.08)
	tw.tween_property(self, "position", base_pos, 0.12)
	
	# Flash vermelho de impacto
	modulate = Color(1.8, 0.4, 0.4)
	var flash_tw = create_tween()
	flash_tw.tween_property(self, "modulate", Color.WHITE, 0.25)
	
	# Retorna para a animação idle após a duração completa dos frames de dano
	if damage_tween and damage_tween.is_valid():
		damage_tween.kill()
	damage_tween = create_tween()
	damage_tween.tween_interval(anim_duration)
	damage_tween.tween_callback(func():
		if not is_animating and not is_substituting:
			play_custom_animation("idle")
	)

func is_busy() -> bool:
	return is_animating or is_substituting or (damage_tween != null and damage_tween.is_valid())

func trigger_kawarimi_substitution() -> void:
	is_substituting = true
	SoundManager.play_sfx("kawarimi")
	spawn_floating_text("SUBSTITUIÇÃO!", Color(1.0, 0.9, 0.2))
	
	# Garante que o corpo e o AnimatedSprite estejam totalmente visíveis
	modulate = Color.WHITE
	if body_sprite:
		body_sprite.modulate.a = 1.0
	if animated_sprite:
		animated_sprite.visible = true
		
	# Dá play na animação de sprite "kawarimi"
	play_custom_animation("kawarimi")
	
	# Calcula a duração para tocar a sequência de frames do Jutsu de Substituição
	var anim_duration = 0.8
	if animated_sprite and animated_sprite.sprite_frames and animated_sprite.sprite_frames.has_animation("kawarimi"):
		var frame_count = animated_sprite.sprite_frames.get_frame_count("kawarimi")
		var spd = animated_sprite.sprite_frames.get_animation_speed("kawarimi")
		if spd > 0.0:
			anim_duration = float(frame_count) / spd
		else:
			anim_duration = 0.8
	
	# Limita para uma duração dinâmica adequada em combate
	anim_duration = clampf(anim_duration, 0.5, 3.0)
	
	var tw = create_tween()
	tw.tween_interval(anim_duration)
	tw.tween_callback(func():
		is_substituting = false
		play_custom_animation("idle")
	)

func _draw() -> void:
	var char_col = character_data.avatar_color if character_data else Color(1.0, 0.5, 0.0)
	var sec_col = character_data.secondary_color if character_data else Color(0.1, 0.3, 0.8)
	var flip = 1.0 if is_player else -1.0
	
	var breath_y = sin(breathing_time) * 3.0
	
	# Draw Aura if charging Jutsu or Gates
	if aura_active:
		var aura_radius = 45.0 + sin(aura_pulse) * 6.0
		draw_circle(Vector2(0, -35 + breath_y), aura_radius, aura_color)
		draw_arc(Vector2(0, -35 + breath_y), aura_radius + 4, 0, TAU, 16, Color(aura_color.r, aura_color.g, aura_color.b, 0.9), 2.5)
	
	# Draw Shadow on floor
	draw_ellipse(Vector2(0, 5), 32, 10, Color(0, 0, 0, 0.35))
	
	# Draw Clones if active
	if clone_offsets.size() > 0:
		for offset in clone_offsets:
			_draw_ninja_silhouette(offset + Vector2(0, breath_y), char_col * 0.85, sec_col, flip)
			
	# Draw Main Ninja Character (Only if no sprite texture is active and visible)
	if not (animated_sprite and animated_sprite.visible and animated_sprite.sprite_frames) and not (sprite_2d and sprite_2d.visible and sprite_2d.texture):
		_draw_ninja_figure(Vector2(0, breath_y), char_col, sec_col, flip)
	
	# Draw VFX (Rasengan, Chidori, Fireball, Kawarimi Log)
	if current_vfx == "rasengan":
		var r_pos = Vector2(35 * flip, -35 + breath_y)
		var r_rot = breathing_time * 20.0
		draw_circle(r_pos, 16, Color(0.2, 0.8, 1.0, 0.85))
		draw_circle(r_pos, 10, Color(0.8, 0.95, 1.0, 0.95))
		for a in range(4):
			var ang = r_rot + a * (PI / 2.0)
			var spiral_end = r_pos + Vector2(cos(ang), sin(ang)) * 22.0
			draw_line(r_pos, spiral_end, Color(1.0, 1.0, 1.0, 0.8), 2.0)
			
	elif current_vfx == "chidori":
		var c_pos = Vector2(35 * flip, -35 + breath_y)
		draw_circle(c_pos, 14, Color(0.4, 0.7, 1.0, 0.9))
		for b in range(6):
			var angle = randf() * TAU
			var p1 = c_pos + Vector2(cos(angle), sin(angle)) * randf_range(5, 12)
			var p2 = c_pos + Vector2(cos(angle + 0.3), sin(angle + 0.3)) * randf_range(16, 28)
			draw_line(p1, p2, Color(0.9, 0.95, 1.0, 1.0), 2.0)
	# Draw Floating text
	for ft in floating_texts:
		var font = ThemeDB.fallback_font
		var col = Color(ft.color.r, ft.color.g, ft.color.b, ft.alpha)
		draw_string(font, ft.pos, ft.text, HORIZONTAL_ALIGNMENT_CENTER, -1, 18, col)

func _draw_ninja_figure(pos: Vector2, main_col: Color, sub_col: Color, flip: float) -> void:
	# Legs
	draw_rect(Rect2(pos + Vector2(-14, -20), Vector2(10, 22)), sub_col)
	draw_rect(Rect2(pos + Vector2(4, -20), Vector2(10, 22)), sub_col)
	# Ninja Shoes
	draw_rect(Rect2(pos + Vector2(-15, 0), Vector2(12, 6)), Color(0.1, 0.1, 0.15))
	draw_rect(Rect2(pos + Vector2(3, 0), Vector2(12, 6)), Color(0.1, 0.1, 0.15))
	
	# Torso / Ninja Outfit
	var torso_rect = Rect2(pos + Vector2(-18, -50), Vector2(36, 32))
	draw_rect(torso_rect, main_col)
	draw_rect(torso_rect, Color(0.1, 0.1, 0.1), false, 2.0)
	
	# Collar / Vest details
	draw_line(pos + Vector2(-10, -50), pos + Vector2(0, -32), sub_col, 3.0)
	draw_line(pos + Vector2(10, -50), pos + Vector2(0, -32), sub_col, 3.0)
	
	# Arms
	draw_rect(Rect2(pos + Vector2(-24, -48), Vector2(8, 24)), main_col)
	draw_rect(Rect2(pos + Vector2(16, -48), Vector2(8, 24)), main_col)
	
	# Head
	draw_circle(pos + Vector2(0, -62), 16, Color(1.0, 0.85, 0.72)) # Skin
	
	# Hair (Spiky / Style according to character)
	if character_data and character_data.id == "sasuke":
		# Dark spiky hair
		draw_circle(pos + Vector2(-4, -72), 12, Color(0.1, 0.1, 0.2))
		draw_circle(pos + Vector2(4, -72), 12, Color(0.1, 0.1, 0.2))
	elif character_data and character_data.id == "rock_lee":
		# Bowl cut
		draw_circle(pos + Vector2(0, -68), 16, Color(0.05, 0.05, 0.05))
	else:
		# Naruto Spiky Blonde
		draw_circle(pos + Vector2(0, -72), 15, Color(1.0, 0.85, 0.1))
		draw_circle(pos + Vector2(-10 * flip, -74), 10, Color(1.0, 0.85, 0.1))
		draw_circle(pos + Vector2(10 * flip, -74), 10, Color(1.0, 0.85, 0.1))
		
	# Konoha Forehead Protector (Hitai-ate)
	draw_rect(Rect2(pos + Vector2(-14, -68), Vector2(28, 7)), sub_col)
	draw_rect(Rect2(pos + Vector2(-7, -67), Vector2(14, 5)), Color(0.85, 0.88, 0.92)) # Metal plate
	
	# Eyes
	var eye_x = 4 * flip
	draw_circle(pos + Vector2(eye_x, -60), 2.5, Color(0.1, 0.1, 0.15))

func _draw_ninja_silhouette(pos: Vector2, col: Color, sub: Color, flip: float) -> void:
	draw_circle(pos + Vector2(0, -62), 15, Color(col.r, col.g, col.b, 0.6))
	draw_rect(Rect2(pos + Vector2(-16, -48), Vector2(32, 28)), Color(col.r, col.g, col.b, 0.6))
