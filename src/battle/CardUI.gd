extends Control

signal card_selected(card_node: Control)
signal card_unselected(card_node: Control)
signal card_played(card_data: AbilityData, card_node: Control)
signal target_drag_moved(card_node: Control, mouse_pos: Vector2)
signal target_drag_ended(card_node: Control, mouse_pos: Vector2)

@export var card_data: AbilityData

var is_hovered: bool = false
var is_dragging: bool = false
var is_playable: bool = false
var is_targeting: bool = false

var original_pos: Vector2
var original_rot: float = 0.0

@onready var title_label: Label = $CardFrame/TitleLabel
@onready var cost_label: Label = $CardFrame/CostContainer/CostLabel
@onready var desc_label: RichTextLabel = $CardFrame/DescLabel
@onready var type_label: Label = $CardFrame/TypeLabel
@onready var frame_panel: Panel = $CardFrame
@onready var illustration_panel: Panel = $CardFrame/Illustration
@onready var glow_panel: Panel = $GlowEffect

func _ready() -> void:
	custom_minimum_size = Vector2(160, 230)
	pivot_offset = size / 2.0
	
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	if card_data:
		update_card_display()

func set_card_data(data: AbilityData) -> void:
	card_data = data
	update_card_display()

func update_card_display() -> void:
	if not is_inside_tree() or not card_data:
		return
		
	title_label.text = card_data.name
	
	var cost_text = ""
	if card_data.yin_cost > 0: cost_text += "%d Yin " % card_data.yin_cost
	if card_data.yang_cost > 0: cost_text += "%d Yang" % card_data.yang_cost
	if cost_text == "": cost_text = "0"
	cost_label.text = cost_text
	
	type_label.text = card_data.get_type_name().to_upper()
	type_label.modulate = card_data.get_type_color()
	desc_label.text = card_data.description

func set_playable_state(playable: bool) -> void:
	is_playable = playable
	if not playable:
		modulate = Color(0.6, 0.6, 0.6)
	else:
		modulate = Color.WHITE

func set_hand_target(pos: Vector2, rot: float) -> void:
	if is_dragging or is_targeting:
		return
		
	original_pos = pos
	original_rot = rot
	
	if not is_hovered:
		var tw = create_tween().set_parallel(true)
		tw.tween_property(self, "position", pos, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.tween_property(self, "rotation", rot, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.tween_property(self, "scale", Vector2.ONE, 0.3)

func _on_mouse_entered() -> void:
	if is_dragging or is_targeting: return
	is_hovered = true
	z_index = 100
	
	var tw = create_tween().set_parallel(true)
	tw.tween_property(self, "scale", Vector2(1.2, 1.2), 0.15).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "position", original_pos + Vector2(0, -50), 0.15).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "rotation", 0.0, 0.15)
	
	SoundManager.play_sfx("card_hover", 0.5)

func _on_mouse_exited() -> void:
	if is_dragging or is_targeting: return
	is_hovered = false
	z_index = 0
	
	var tw = create_tween().set_parallel(true)
	tw.tween_property(self, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "position", original_pos, 0.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "rotation", original_rot, 0.2)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if is_playable:
				if card_data.target_type == AbilityData.TargetType.SINGLE_ENEMY:
					is_targeting = true
					card_selected.emit(self)
				else:
					is_dragging = true
					z_index = 100
					card_selected.emit(self)
		else:
			if is_targeting:
				is_targeting = false
				z_index = 0
				target_drag_ended.emit(self, get_global_mouse_position())
				_return_to_hand()
				
			elif is_dragging:
				is_dragging = false
				z_index = 0
				card_unselected.emit(self)
				
				if global_position.y < get_viewport_rect().size.y / 2:
					card_played.emit(card_data, self)
				else:
					_return_to_hand()
					
	elif event is InputEventMouseMotion:
		if is_targeting:
			target_drag_moved.emit(self, get_global_mouse_position())
		elif is_dragging:
			global_position = get_global_mouse_position() - (size / 2)

func _return_to_hand() -> void:
	is_hovered = false
	var tw = create_tween().set_parallel(true)
	tw.tween_property(self, "position", original_pos, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "rotation", original_rot, 0.3)
	tw.tween_property(self, "scale", Vector2.ONE, 0.3)
