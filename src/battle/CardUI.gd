extends Control

signal card_selected(card_node: Control)
signal card_unselected(card_node: Control)
signal card_played(card_data: AbilityData, card_node: Control)
signal target_drag_moved(card_node: Control, mouse_pos: Vector2)
signal target_drag_ended(card_node: Control, mouse_pos: Vector2)
signal holder_unslot_requested(unslotted_data: AbilityData, holder_card_node: Control)

@export var card_data: AbilityData

## Cartas encaixadas caso esta carta seja um Holder
var slotted_cards: Array[AbilityData] = []

var is_hovered: bool = false
var is_dragging: bool = false
var is_playable: bool = false
var is_targeting: bool = false

var original_pos: Vector2
var original_rot: float = 0.0

@onready var title_label: Label = $CardFrame/TitleLabel
@onready var cost_label: Label = $CardFrame/CostContainer/HBox/CostLabel if has_node("CardFrame/CostContainer/HBox/CostLabel") else ($CardFrame/CostContainer/CostLabel if has_node("CardFrame/CostContainer/CostLabel") else null)
@onready var cost_container: Panel = $CardFrame/CostContainer if has_node("CardFrame/CostContainer") else null
@onready var desc_label: RichTextLabel = $CardFrame/DescLabel
@onready var type_label: Label = $CardFrame/TypeLabel
@onready var frame_panel: Panel = $CardFrame
@onready var illustration_panel: Panel = $CardFrame/Illustration
@onready var icon_rect: TextureRect = $CardFrame/Illustration/Icon if has_node("CardFrame/Illustration/Icon") else null
@onready var element_icon_rect: TextureRect = $CardFrame/CostContainer/HBox/ElementIcon if has_node("CardFrame/CostContainer/HBox/ElementIcon") else ($CardFrame/ElementIcon if has_node("CardFrame/ElementIcon") else null)
@onready var glow_panel: Panel = $GlowEffect

func _ready() -> void:
	custom_minimum_size = Vector2(160, 230)
	pivot_offset = custom_minimum_size / 2.0
	
	if not mouse_entered.is_connected(_on_mouse_entered):
		mouse_entered.connect(_on_mouse_entered)
	if not mouse_exited.is_connected(_on_mouse_exited):
		mouse_exited.connect(_on_mouse_exited)
	
	if card_data:
		update_card_display()

func is_holder() -> bool:
	return card_data != null and (card_data.is_holder or card_data.ability_type == AbilityData.AbilityType.HOLDER)

func can_add_card() -> bool:
	return is_holder() and slotted_cards.size() < card_data.holder_capacity

func add_slotted_card(card: AbilityData) -> void:
	slotted_cards.append(card)
	update_card_display()

func remove_slotted_card(card: AbilityData) -> void:
	slotted_cards.erase(card)
	update_card_display()

func get_total_holder_vigor() -> int:
	var tot = 0
	for c in slotted_cards:
		tot += int(round(c.vigor_cost * 0.9))
	return tot

func set_card_data(data: AbilityData) -> void:
	card_data = data
	update_card_display()

func update_card_display() -> void:
	if not is_inside_tree() or not card_data:
		return
		
	title_label.text = card_data.name
	if cost_label:
		if is_holder():
			cost_label.text = str(get_total_holder_vigor()) if slotted_cards.size() > 0 else "COMBO"
		else:
			cost_label.text = card_data.get_cost_display()
	
	var elem_color = card_data.get_element_color()
	
	# Estiliza o selo de custo com a cor do elemento/vigor
	if cost_container:
		var cost_sb = cost_container.get_theme_stylebox("panel")
		if cost_sb is StyleBoxFlat:
			var new_cost_sb = cost_sb.duplicate() as StyleBoxFlat
			new_cost_sb.bg_color = elem_color
			cost_container.add_theme_stylebox_override("panel", new_cost_sb)
			
	# Atualiza a cor da borda da carta com a cor do elemento ou dourado de holder
	if frame_panel:
		var frame_sb = frame_panel.get_theme_stylebox("panel")
		if frame_sb is StyleBoxFlat:
			var new_frame_sb = frame_sb.duplicate() as StyleBoxFlat
			new_frame_sb.border_color = Color(1.0, 0.85, 0.2) if is_holder() else elem_color
			frame_panel.add_theme_stylebox_override("panel", new_frame_sb)
	
	# Exibe o tipo e elemento na etiqueta de categoria
	var base_type = card_data.get_type_name().to_upper()
	if card_data.required_element != ChakraElement.Type.NONE:
		base_type = "%s • %s" % [base_type, ChakraElement.get_element_short_name(card_data.required_element).to_upper()]
	elif card_data.vigor_cost > 0:
		base_type = "%s • 🏃 %d VIGOR" % [base_type, card_data.vigor_cost]
	
	if is_holder():
		type_label.text = "🥋 HOLDER (%d/%d)" % [slotted_cards.size(), card_data.holder_capacity]
		type_label.modulate = Color(1.0, 0.85, 0.2)
		
		var desc = "[color=#ffd700][b]🥋 HOLDER DE COMBO[/b][/color]\n"
		desc += "Capacidade: [b]%d/%d[/b] golpes\n" % [slotted_cards.size(), card_data.holder_capacity]
		desc += "[color=#2ecc71]Bônus: -10%% Vigor | +10%% Dano[/color]\n\n"
		for s in range(card_data.holder_capacity):
			if s < slotted_cards.size():
				var sc = slotted_cards[s]
				var disc_vig = int(round(sc.vigor_cost * 0.9))
				var accum = (s + 1) * 10
				desc += "[color=#ffffff][b]%d.[/b] %s[/color] [color=#2ecc71](%dV/+%d%%)[/color]\n" % [s + 1, sc.name, disc_vig, accum]
			else:
				desc += "[color=#888888][b]%d.[/b] [Vazio: solte Taijutsu][/color]\n" % [s + 1]
		if slotted_cards.size() >= 2:
			desc += "\n[color=#ffd700][b]▶ PRONTO PARA LANÇAR![/b][/color]"
		elif slotted_cards.size() == 1:
			desc += "\n[color=#aaaaaa]Encaixe mais 1 golpe![/color]"
		desc_label.text = desc
	else:
		if card_data.requires_clone:
			type_label.text = "%s (👥 CLONE)" % base_type
			desc_label.text = "[color=#ffd24d][b]👥 Requer Clone[/b][/color]\n" + card_data.description
		else:
			type_label.text = base_type
			desc_label.text = card_data.description
		type_label.modulate = card_data.get_type_color()
	
	# Ícone do elemento no CostContainer junto ao custo
	if element_icon_rect:
		var elem_tex = card_data.get_element_texture()
		if elem_tex and not is_holder():
			element_icon_rect.texture = elem_tex
			element_icon_rect.visible = true
		else:
			element_icon_rect.visible = false
	
	# Ilustração central (exibe apenas a arte própria da carta, sem imagens de elemento)
	if icon_rect:
		if card_data.icon:
			icon_rect.texture = card_data.icon
			icon_rect.visible = true
		else:
			icon_rect.texture = null
			icon_rect.visible = false

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
	
	var is_in_container = get_parent() is Container
	var tw = create_tween().set_parallel(true)
	tw.tween_property(self, "scale", Vector2(1.15, 1.15), 0.15).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	if not is_in_container:
		tw.tween_property(self, "position", original_pos + Vector2(0, -50), 0.15).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tw.tween_property(self, "rotation", 0.0, 0.15)
	
	SoundManager.play_sfx("card_hover", 0.5)

func _on_mouse_exited() -> void:
	if is_dragging or is_targeting: return
	is_hovered = false
	z_index = 0
	
	var is_in_container = get_parent() is Container
	var tw = create_tween().set_parallel(true)
	tw.tween_property(self, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	if not is_in_container:
		tw.tween_property(self, "position", original_pos, 0.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tw.tween_property(self, "rotation", original_rot, 0.2)

func _gui_input(event: InputEvent) -> void:
	# Clique com botão direito em Holder com cartas desencaixa a última carta
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		if is_holder() and slotted_cards.size() > 0:
			var removed_card = slotted_cards.pop_back()
			update_card_display()
			holder_unslot_requested.emit(removed_card, self)
			return
			
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var bf = get_tree().current_scene
			if bf and bf.has_method("are_animations_running") and bf.are_animations_running():
				return
			if is_holder():
				if slotted_cards.size() >= 2 and is_playable:
					is_targeting = true
					card_selected.emit(self)
				elif slotted_cards.size() < 2:
					var bf_scene = get_tree().current_scene
					if bf_scene and bf_scene.has_node("Arena2D/PlayerVisual"):
						bf_scene.get_node("Arena2D/PlayerVisual").spawn_floating_text("Encaixe 2+ golpes no Holder!", Color(1.0, 0.85, 0.2))
			elif is_playable:
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
				
				# Emite target_drag_ended para verificar se foi solto sobre um Holder na mão
				target_drag_ended.emit(self, get_global_mouse_position())
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
	if not (get_parent() is Container):
		tw.tween_property(self, "position", original_pos, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.tween_property(self, "rotation", original_rot, 0.3)
	tw.tween_property(self, "scale", Vector2.ONE, 0.3)
