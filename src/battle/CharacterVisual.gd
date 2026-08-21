# res://src/battle/CharacterVisual.gd
extends Node2D

signal animation_finished(anim_name: String)

@export var is_player: bool = true
@export var character_name: String = "Naruto"

var character_data: CharacterData
var target_pos: Vector2
var base_pos: Vector2
var is_animating: bool = false

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
			
	if animated_sprite:
		animated_sprite.play("idle")
		animated_sprite.flip_h = not is_player
	elif sprite_2d:
		sprite_2d.flip_h = not is_player

func setup_character(data: CharacterData) -> void:
	character_data = data
	name_label.text = data.name
	update_stats(data.current_hp, data.max_hp, data.base_shield, data.max_chakra, data.max_chakra)
	queue_redraw()

func update_stats(hp: int, max_hp: int, shield: int, chakra: int, max_chakra: int) -> void:
	hp_bar.max_value = max_hp
	hp_bar.value = hp
	hp_label.text = "%d / %d" % [hp, max_hp]
	
	shield_bar.max_value = max_hp
	shield_bar.value = shield
	shield_bar.visible = shield > 0
	
	# Update chakra orbs
	for child in chakra_container.get_children():
		child.queue_free()
		
	for i in range(max_chakra):
		var orb = Panel.new()
		orb.custom_minimum_size = Vector2(14, 14)
		var style = StyleBoxFlat.new()
		style.set_corner_radius_all(7)
		if i < chakra:
			style.bg_color = Color(0.2, 0.8, 1.0, 0.9) # Glowing cyan
			style.shadow_color = Color(0.1, 0.6, 1.0, 0.7)
			style.shadow_size = 4
		else:
			style.bg_color = Color(0.2, 0.2, 0.3, 0.5) # Dim empty
		orb.add_theme_stylebox_override("panel", style)
		chakra_container.add_child(orb)

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

func play_attack_animation(target_character: Node2D, anim_key: String) -> void:
	is_animating = true
	var tw = create_tween()
	var dest = target_character.global_position + (Vector2(-70, 0) if is_player else Vector2(70, 0))
	
	match anim_key:
		"rasengan":
			aura_active = true
			aura_color = Color(0.1, 0.8, 1.0, 0.7)
			SoundManager.play_sfx("rasengan")
			current_vfx = "rasengan"
			vfx_progress = 1.0
			tw.tween_property(self, "global_position", dest, 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
			tw.tween_callback(func():
				target_character.play_hit_reaction("heavy")
				SoundManager.play_sfx("hit", 0.8)
			)
			tw.tween_interval(0.2)
			tw.tween_property(self, "global_position", base_pos, 0.25).set_trans(Tween.TRANS_SINE)
			tw.tween_callback(func():
				aura_active = false
				current_vfx = ""
				is_animating = false
				animation_finished.emit(anim_key)
			)
			
		"chidori", "ougi_chidori":
			aura_active = true
			aura_color = Color(0.3, 0.6, 1.0, 0.9)
			SoundManager.play_sfx("chidori")
			current_vfx = "chidori"
			vfx_progress = 1.0
			# Flash forward instant dash
			tw.tween_property(self, "global_position", dest, 0.18).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
			tw.tween_callback(func():
				target_character.play_hit_reaction("lightning")
				SoundManager.play_sfx("hit", 1.3)
			)
			tw.tween_interval(0.25)
			tw.tween_property(self, "global_position", base_pos, 0.2).set_trans(Tween.TRANS_QUAD)
			tw.tween_callback(func():
				aura_active = false
				current_vfx = ""
				is_animating = false
				animation_finished.emit(anim_key)
			)
			
		"bunshin", "bunshin_attack":
			SoundManager.play_sfx("kawarimi")
			clone_offsets = [Vector2(-30, -20), Vector2(30, -20), Vector2(-15, 25)]
			current_vfx = "bunshin"
			vfx_progress = 1.2
			tw.tween_property(self, "global_position", dest, 0.25).set_trans(Tween.TRANS_QUAD)
			tw.tween_callback(func():
				target_character.play_hit_reaction("combo")
				SoundManager.play_sfx("hit")
			)
			tw.tween_interval(0.2)
			tw.tween_property(self, "global_position", base_pos, 0.2)
			tw.tween_callback(func():
				clone_offsets.clear()
				current_vfx = ""
				is_animating = false
				animation_finished.emit(anim_key)
			)
			
		"katon", "katon_multi":
			aura_active = true
			aura_color = Color(1.0, 0.4, 0.1, 0.8)
			current_vfx = "fireball"
			vfx_progress = 0.8
			tw.tween_interval(0.3)
			tw.tween_callback(func():
				target_character.play_hit_reaction("burn")
				SoundManager.play_sfx("hit", 0.9)
			)
			tw.tween_interval(0.3)
			tw.tween_callback(func():
				aura_active = false
				current_vfx = ""
				is_animating = false
				animation_finished.emit(anim_key)
			)
			
		"leaf_hurricane", "naruto_combo", "lotus":
			tw.tween_property(self, "global_position", dest, 0.2).set_trans(Tween.TRANS_BACK)
			tw.tween_callback(func():
				target_character.play_hit_reaction("combo")
				SoundManager.play_sfx("hit", 1.1)
			)
			tw.tween_interval(0.15)
			tw.tween_property(self, "global_position", base_pos, 0.2)
			tw.tween_callback(func():
				is_animating = false
				animation_finished.emit(anim_key)
			)
			
		_:
			# Standard punch/kick
			tw.tween_property(self, "global_position", dest, 0.18).set_trans(Tween.TRANS_QUAD)
			tw.tween_callback(func():
				target_character.play_hit_reaction("normal")
				SoundManager.play_sfx("hit")
			)
			tw.tween_property(self, "global_position", base_pos, 0.18).set_trans(Tween.TRANS_QUAD)
			tw.tween_callback(func():
				is_animating = false
				animation_finished.emit(anim_key)
			)

func play_hit_reaction(hit_type: String = "normal") -> void:
	var tw = create_tween()
	var push_dir = Vector2(-25, 0) if is_player else Vector2(25, 0)
	tw.tween_property(self, "position", base_pos + push_dir, 0.08)
	tw.tween_property(self, "position", base_pos, 0.12)
	
	# Red flash on body
	modulate = Color(1.8, 0.4, 0.4)
	var flash_tw = create_tween()
	flash_tw.tween_property(self, "modulate", Color.WHITE, 0.25)

func trigger_kawarimi_substitution() -> void:
	SoundManager.play_sfx("kawarimi")
	current_vfx = "kawarimi_log"
	vfx_progress = 0.9
	spawn_floating_text("SUBSTITUIÇÃO!", Color(1.0, 0.9, 0.2))
	# Disappear and reappear
	modulate.a = 0.0
	var tw = create_tween()
	tw.tween_interval(0.4)
	tw.tween_property(self, "modulate:a", 1.0, 0.3)

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
			
	# Draw Main Ninja Character (Only if no sprite texture is set)
	if not (animated_sprite and animated_sprite.sprite_frames) and not (sprite_2d and sprite_2d.texture):
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
			
	elif current_vfx == "kawarimi_log":
		# Draw wooden log with cut marks
		var log_rect = Rect2(-18, -50, 36, 50)
		draw_rect(log_rect, Color(0.55, 0.35, 0.15))
		draw_rect(log_rect, Color(0.35, 0.2, 0.08), false, 2.0)
		draw_circle(Vector2(0, -50), 18, Color(0.7, 0.5, 0.3))
		# Smoke ring
		draw_circle(Vector2(0, -25), 35, Color(0.9, 0.9, 0.95, vfx_progress * 0.7))
		
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
