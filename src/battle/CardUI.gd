# res://src/battle/CardUI.gd
extends Control

signal card_selected(card_node: Control)
signal card_unselected(card_node: Control)
signal card_played(card_data: CardData, card_node: Control)

@export var card_data: CardData

var is_hovered: bool = false
var is_dragging: bool = false
var is_playable: bool = true
var target_pos: Vector2 = Vector2.ZERO
var target_rot: float = 0.0
var base_scale: Vector2 = Vector2.ONE
var drag_start_mouse: Vector2 = Vector2.ZERO

@onready var title_label: Label = $CardFrame/TitleLabel
@onready var cost_label: Label = $CardFrame/CostContainer/CostLabel
@onready var type_label: Label = $CardFrame/TypeLabel
@onready var desc_label: RichTextLabel = $CardFrame/DescLabel
@onready var frame_panel: Panel = $CardFrame
@onready var illustration_panel: Panel = $CardFrame/Illustration
@onready var glow_panel: Panel = $GlowEffect

func _ready() -> void:
	custom_minimum_size = Vector2(160, 230)
	pivot_offset = size / 2.0
	if card_data:
		update_card_display()

func set_card_data(data: CardData) -> void:
	card_data = data
	update_card_display()

func update_card_display() -> void:
	if not is_inside_tree() or not card_data:
		return
		
	title_label.text = card_data.title
	cost_label.text = str(card_data.chakra_cost)
	type_label.text = card_data.get_type_name().to_upper()
	type_label.modulate = card_data.get_type_color()
	
	var desc_text = card_data.description
	# Highlight keywords
	desc_text = desc_text.replace("Guarda", "[color=#66b3ff]Guarda[/color]")
	desc_text = desc_text.replace("Chakra", "[color=#33d6ff]Chakra[/color]")
	desc_text = desc_text.replace("Queimadura", "[color=#ff6633]Queimadura[/color]")
	desc_text = desc_text.replace("Paralisia", "[color=#ffff66]Paralisia[/color]")
	desc_text = desc_text.replace("QTE", "[color=#ff3366]QTE[/color]")
	desc_label.text = desc_text

	# Frame color based on Card Type
	var border_style = StyleBoxFlat.new()
	border_style.bg_color = Color(0.12, 0.14, 0.18, 0.95)
	border_style.border_color = card_data.get_type_color()
	border_style.set_border_width_all(3)
	border_style.set_corner_radius_all(10)
	border_style.shadow_color = Color(0, 0, 0, 0.6)
	border_style.shadow_size = 6
	frame_panel.add_theme_stylebox_override("panel", border_style)

func set_playable_state(can_play: bool) -> void:
	is_playable = can_play
	if not is_playable and not is_hovered:
		modulate = Color(0.65, 0.65, 0.7, 0.8)
	else:
		modulate = Color.WHITE

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if is_playable:
				is_dragging = true
				drag_start_mouse = get_global_mouse_position()
				z_index = 50
				card_selected.emit(self)
		else:
			if is_dragging:
				is_dragging = false
				z_index = 0
				card_unselected.emit(self)
				# Check if dragged high enough into the arena to trigger play
				if global_position.y < 460.0:
					card_played.emit(card_data, self)
				else:
					# Return smoothly
					_animate_to_target()

func _on_mouse_entered() -> void:
	is_hovered = true
	SoundManager.play_sfx("card_draw", 1.2)
	z_index = 30
	var tw = create_tween().set_parallel(true)
	tw.tween_property(self, "scale", Vector2(1.2, 1.2), 0.12).set_trans(Tween.TRANS_SINE)
	tw.tween_property(self, "position:y", target_pos.y - 45.0, 0.12).set_trans(Tween.TRANS_SINE)
	tw.tween_property(self, "rotation", 0.0, 0.12)
	glow_panel.visible = true

func _on_mouse_exited() -> void:
	is_hovered = false
	if not is_dragging:
		z_index = 0
		glow_panel.visible = false
		_animate_to_target()

func _process(delta: float) -> void:
	if is_dragging:
		global_position = get_global_mouse_position() - (size / 2.0)
		rotation = lerpf(rotation, 0.0, delta * 15.0)

func set_hand_target(pos: Vector2, rot: float) -> void:
	target_pos = pos
	target_rot = rot
	if not is_hovered and not is_dragging:
		_animate_to_target()

func _animate_to_target() -> void:
	var tw = create_tween().set_parallel(true)
	tw.tween_property(self, "position", target_pos, 0.22).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "rotation", target_rot, 0.22).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "scale", Vector2.ONE, 0.22)
