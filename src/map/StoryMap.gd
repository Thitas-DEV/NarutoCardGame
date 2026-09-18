# res://src/map/StoryMap.gd
extends Control

# UI References - Top Bar
@onready var back_btn: Button = $TopBar/BackButton
@onready var deck_btn: Button = $TopBar/DeckButton
@onready var progress_label: Label = $TopBar/ProgressInfo/ProgressLabel

# UI References - World Navigation & Stages
@onready var world_tabs_container: HBoxContainer = $WorldTabs
@onready var world_title_label: Label = $WorldHeader/WorldTitle
@onready var world_subtitle_label: Label = $WorldHeader/WorldSubtitle
@onready var stages_grid: GridContainer = $StageScroll/StagesGrid

# UI References - Pre-Battle Modal
@onready var prep_modal: Control = $BattlePrepModal
@onready var modal_stage_title: Label = $BattlePrepModal/ModalPanel/Header/StageTitle
@onready var modal_stage_subtitle: Label = $BattlePrepModal/ModalPanel/Header/StageSubtitle
@onready var modal_close_btn: Button = $BattlePrepModal/ModalPanel/Header/CloseBtn

# Hero selection column
@onready var hero_buttons_container: HBoxContainer = $BattlePrepModal/ModalPanel/Body/HeroColumn/HeroButtonsContainer
@onready var hero_name_label: Label = $BattlePrepModal/ModalPanel/Body/HeroColumn/HeroInfoCard/VBox/HeroName
@onready var hero_title_label: Label = $BattlePrepModal/ModalPanel/Body/HeroColumn/HeroInfoCard/VBox/HeroTitle
@onready var hero_stats_label: Label = $BattlePrepModal/ModalPanel/Body/HeroColumn/HeroInfoCard/VBox/HeroStats
@onready var hero_affinities_container: HBoxContainer = $BattlePrepModal/ModalPanel/Body/HeroColumn/HeroInfoCard/VBox/HeroAffinities
@onready var sprite_preview_area: Control = $BattlePrepModal/ModalPanel/Body/HeroColumn/SpritePreviewArea

# Opponent column
@onready var enemy_name_label: Label = $BattlePrepModal/ModalPanel/Body/EnemyColumn/EnemyInfoCard/VBox/EnemyName
@onready var enemy_title_label: Label = $BattlePrepModal/ModalPanel/Body/EnemyColumn/EnemyInfoCard/VBox/EnemyTitle
@onready var enemy_stats_label: Label = $BattlePrepModal/ModalPanel/Body/EnemyColumn/EnemyInfoCard/VBox/EnemyStats
@onready var enemy_affinities_container: HBoxContainer = $BattlePrepModal/ModalPanel/Body/EnemyColumn/EnemyInfoCard/VBox/EnemyAffinities
@onready var stage_desc_label: RichTextLabel = $BattlePrepModal/ModalPanel/Body/EnemyColumn/BriefingBox/StageDesc
@onready var dialogue_container: VBoxContainer = $BattlePrepModal/ModalPanel/Body/EnemyColumn/BriefingBox/DialogueScroll/DialogueContainer

# Deck column
@onready var deck_count_label: Label = $BattlePrepModal/ModalPanel/Body/DeckColumn/DeckHeader/DeckCountLabel
@onready var deck_cards_container: VBoxContainer = $BattlePrepModal/ModalPanel/Body/DeckColumn/DeckScroll/DeckCardsContainer

# Modal footer
@onready var modal_back_btn: Button = $BattlePrepModal/ModalPanel/Footer/BackBtn
@onready var modal_start_btn: Button = $BattlePrepModal/ModalPanel/Footer/StartBattleBtn

# State
var current_world_id: int = 1
var active_stage_data: Dictionary = {}
var selected_hero_id: String = "naruto"
var char_visual_instance: Node2D = null

const CHARACTER_VISUAL_SCENE = preload("res://src/battle/CharacterVisual.tscn")

func _ready() -> void:
	_setup_font_fallbacks()
	_setup_top_bar()
	_setup_modal_events()
	_render_world_tabs()
	_switch_world(GameManager.current_story_world)

func _setup_font_fallbacks() -> void:
	if ResourceLoader.exists("res://assets/UI/fonts/njnaruto.ttf") and ResourceLoader.exists("res://assets/fonts/Oswald/static/Oswald-Bold.ttf"):
		var nj_font = load("res://assets/UI/fonts/njnaruto.ttf") as FontFile
		var fallback_font = load("res://assets/fonts/Oswald/static/Oswald-Bold.ttf") as FontFile
		if nj_font and fallback_font and nj_font.fallbacks.is_empty():
			nj_font.fallbacks = [fallback_font]

func _setup_top_bar() -> void:
	back_btn.pressed.connect(func():
		SoundManager.play_sfx("card_draw")
		get_tree().change_scene_to_file("res://src/ui/MainMenuRefactor.tscn")
	)
	deck_btn.pressed.connect(func():
		SoundManager.play_sfx("card_draw")
		get_tree().change_scene_to_file("res://src/deck_builder/DeckBuilder.tscn")
	)
	_update_progress_display()

func _update_progress_display() -> void:
	var completed = GameManager.completed_stages.size()
	var total = 24
	var pct = int((float(completed) / float(total)) * 100.0)
	progress_label.text = "Fases Concluídas: %d / %d (%d%%)" % [completed, total, pct]

func _setup_modal_events() -> void:
	modal_close_btn.pressed.connect(_close_modal)
	modal_back_btn.pressed.connect(_close_modal)
	modal_start_btn.pressed.connect(_on_start_battle)
	
	sprite_preview_area.gui_input.connect(func(event: InputEvent):
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			if char_visual_instance and char_visual_instance.has_method("play_celebration"):
				char_visual_instance.play_celebration()
	)

func _close_modal() -> void:
	SoundManager.play_sfx("card_draw", 0.9)
	prep_modal.visible = false

func _render_world_tabs() -> void:
	for child in world_tabs_container.get_children():
		child.queue_free()
		
	var worlds = StoryCampaignData.get_all_worlds()
	for w in worlds:
		var w_id = w.get("id", 1)
		var is_unlocked = StoryCampaignData.is_world_unlocked(w_id, GameManager.completed_stages)
		
		var tab_btn = Button.new()
		tab_btn.custom_minimum_size = Vector2(250, 42)
		tab_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		var prefix = ""
		if not is_unlocked:
			prefix = "🔒 "
		else:
			prefix = w.get("icon", "📖") + " "
			
		tab_btn.text = prefix + w.get("title", "Mundo %d" % w_id)
		
		var style = StyleBoxFlat.new()
		style.set_corner_radius_all(6)
		style.set_border_width_all(2)
		
		if w_id == current_world_id:
			style.bg_color = Color(0.2, 0.25, 0.38, 0.95)
			style.border_color = Color(1.0, 0.75, 0.2)
		elif is_unlocked:
			style.bg_color = Color(0.1, 0.13, 0.18, 0.9)
			style.border_color = Color(0.3, 0.4, 0.5)
		else:
			style.bg_color = Color(0.06, 0.08, 0.1, 0.8)
			style.border_color = Color(0.2, 0.2, 0.25)
			
		tab_btn.add_theme_stylebox_override("normal", style)
		
		tab_btn.pressed.connect(func():
			if not is_unlocked:
				SoundManager.play_sfx("hit", 0.6)
				return
			SoundManager.play_sfx("card_draw", 1.1)
			_switch_world(w_id)
		)
		world_tabs_container.add_child(tab_btn)

func _switch_world(world_id: int) -> void:
	current_world_id = world_id
	GameManager.current_story_world = world_id
	var w_data = StoryCampaignData.get_world_by_id(world_id)
	if w_data.is_empty():
		return
		
	world_title_label.text = "%s %s" % [w_data.get("icon", "📖"), w_data.get("title", "")]
	world_subtitle_label.text = w_data.get("subtitle", "")
	
	_render_world_tabs()
	_render_stages(w_data.get("stages", []))

func _render_stages(stages: Array) -> void:
	for child in stages_grid.get_children():
		child.queue_free()
		
	for stage in stages:
		var card = _create_stage_card(stage)
		stages_grid.add_child(card)

func _create_stage_card(stage: Dictionary) -> PanelContainer:
	var stage_id = stage.get("id", "")
	var is_unlocked = StoryCampaignData.is_stage_unlocked(stage_id, GameManager.completed_stages)
	var is_completed = GameManager.completed_stages.has(stage_id)
	
	var container = PanelContainer.new()
	container.custom_minimum_size = Vector2(560, 100)
	container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var style = StyleBoxFlat.new()
	style.set_corner_radius_all(8)
	style.set_border_width_all(2)
	style.content_margin_left = 16
	style.content_margin_right = 16
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	
	if is_completed:
		style.bg_color = Color(0.08, 0.18, 0.12, 0.95)
		style.border_color = Color(0.2, 0.85, 0.4)
	elif is_unlocked:
		style.bg_color = Color(0.12, 0.15, 0.22, 0.95)
		style.border_color = Color(1.0, 0.68, 0.15)
	else:
		style.bg_color = Color(0.07, 0.08, 0.11, 0.75)
		style.border_color = Color(0.25, 0.25, 0.3)
		
	container.add_theme_stylebox_override("panel", style)
	
	var hbox = HBoxContainer.new()
	hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_theme_constant_override("separation", 16)
	container.add_child(hbox)
	
	# Left: Stage Number Badge
	var badge = Panel.new()
	badge.custom_minimum_size = Vector2(64, 64)
	badge.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var b_style = StyleBoxFlat.new()
	b_style.set_corner_radius_all(32)
	if is_completed:
		b_style.bg_color = Color(0.15, 0.4, 0.22)
		b_style.border_color = Color(0.3, 0.9, 0.45)
	elif is_unlocked:
		b_style.bg_color = Color(0.3, 0.2, 0.08)
		b_style.border_color = Color(1.0, 0.7, 0.2)
	else:
		b_style.bg_color = Color(0.15, 0.15, 0.18)
		b_style.border_color = Color(0.3, 0.3, 0.35)
	b_style.set_border_width_all(2)
	badge.add_theme_stylebox_override("panel", b_style)
	
	var num_lbl = Label.new()
	num_lbl.text = stage.get("number", "?")
	num_lbl.set_anchors_preset(Control.PRESET_FULL_RECT)
	num_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	num_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	num_lbl.add_theme_font_size_override("font_size", 16)
	num_lbl.add_theme_color_override("font_color", Color.WHITE)
	badge.add_child(num_lbl)
	hbox.add_child(badge)
	
	# Middle: Titles and details
	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	
	var title_lbl = Label.new()
	title_lbl.text = stage.get("title", "")
	title_lbl.add_theme_font_size_override("font_size", 15)
	if is_completed:
		title_lbl.add_theme_color_override("font_color", Color(0.5, 1.0, 0.6))
	elif is_unlocked:
		title_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	else:
		title_lbl.add_theme_color_override("font_color", Color(0.5, 0.5, 0.55))
	vbox.add_child(title_lbl)
	
	var sub_lbl = Label.new()
	sub_lbl.text = stage.get("subtitle", "")
	sub_lbl.add_theme_font_size_override("font_size", 12)
	sub_lbl.add_theme_color_override("font_color", Color(0.75, 0.75, 0.8) if is_unlocked else Color(0.4, 0.4, 0.45))
	vbox.add_child(sub_lbl)
	
	var heroes_list: Array[String] = []
	for h_id in stage.get("hero_options", []):
		var hero_c = Database.get_character(h_id)
		if hero_c:
			heroes_list.append(hero_c.name)
		else:
			heroes_list.append(h_id.capitalize())
	var heroes_str = ", ".join(heroes_list)
	
	var enemy_c = Database.get_character(stage.get("enemy_id", ""))
	var enemy_str = enemy_c.name if enemy_c else stage.get("enemy_id", "").capitalize()
	
	var match_info = Label.new()
	match_info.text = "Heróis: %s  |  Oponente: %s" % [heroes_str, enemy_str]
	match_info.add_theme_font_size_override("font_size", 11)
	match_info.add_theme_color_override("font_color", Color(0.6, 0.7, 0.8) if is_unlocked else Color(0.35, 0.35, 0.4))
	vbox.add_child(match_info)
	hbox.add_child(vbox)
	
	# Right: Action / Status Button
	var action_btn = Button.new()
	action_btn.custom_minimum_size = Vector2(130, 42)
	action_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var btn_style = StyleBoxFlat.new()
	btn_style.set_corner_radius_all(6)
	
	if is_completed:
		btn_style.bg_color = Color(0.15, 0.35, 0.2)
		action_btn.text = "✓ CONCLUÍDO"
	elif is_unlocked:
		btn_style.bg_color = Color(0.85, 0.45, 0.1)
		action_btn.text = "BATALHAR ⚔️"
	else:
		btn_style.bg_color = Color(0.18, 0.18, 0.22)
		action_btn.text = "🔒 BLOQUEADO"
		action_btn.disabled = true
		
	action_btn.add_theme_stylebox_override("normal", btn_style)
	
	if is_unlocked:
		action_btn.pressed.connect(func():
			SoundManager.play_sfx("card_draw", 1.2)
			_open_stage_modal(stage)
		)
		
	hbox.add_child(action_btn)
	return container

# ==================== PRE-BATTLE MODAL LOGIC ====================

func _open_stage_modal(stage: Dictionary) -> void:
	active_stage_data = stage
	var hero_options = stage.get("hero_options", ["naruto"])
	selected_hero_id = hero_options[0]
	
	modal_stage_title.text = "FASE %s — %s" % [stage.get("number", ""), stage.get("title", "")]
	modal_stage_subtitle.text = stage.get("subtitle", "")
	
	# Render hero selector buttons
	for child in hero_buttons_container.get_children():
		child.queue_free()
		
	for h_id in hero_options:
		var hero_data = Database.get_character(h_id)
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(100, 36)
		btn.text = hero_data.name if hero_data else h_id.capitalize()
		var h_target = h_id
		btn.pressed.connect(func():
			_select_hero(h_target, true)
		)
		hero_buttons_container.add_child(btn)
		
	_select_hero(selected_hero_id, false)
	_render_briefing(stage)
	prep_modal.visible = true

func _select_hero(hero_id: String, play_celebration: bool) -> void:
	selected_hero_id = hero_id
	var hero_data = Database.get_character(hero_id)
	if not hero_data:
		return
		
	# Update Hero Buttons style
	var hero_options = active_stage_data.get("hero_options", [])
	var buttons = hero_buttons_container.get_children()
	for i in range(buttons.size()):
		if i < hero_options.size():
			var b = buttons[i] as Button
			var is_active = (hero_options[i] == hero_id)
			var st = StyleBoxFlat.new()
			st.set_corner_radius_all(6)
			st.set_border_width_all(2)
			if is_active:
				st.bg_color = Color(0.3, 0.2, 0.08, 0.95)
				st.border_color = Color(1.0, 0.75, 0.15)
			else:
				st.bg_color = Color(0.12, 0.14, 0.2, 0.8)
				st.border_color = Color(0.3, 0.35, 0.45)
			b.add_theme_stylebox_override("normal", st)
	
	# Update Hero Stats
	hero_name_label.text = hero_data.name
	hero_title_label.text = hero_data.title
	hero_stats_label.text = "❤️ HP: %d  |  🏃 Vigor: %d" % [hero_data.max_hp, hero_data.max_vigor]
	_render_affinities(hero_affinities_container, hero_data.chakra_affinities)
	
	# Update Character Sprite Preview
	_update_character_preview(hero_data, play_celebration)
	
	# Update Expected Deck
	_render_deck_preview(hero_data)
	
	# Update Enemy Card (handles dynamic 4.6 resolution if needed)
	_update_enemy_display()

func _update_character_preview(hero_data: CharacterData, celebrate: bool) -> void:
	if not char_visual_instance:
		char_visual_instance = CHARACTER_VISUAL_SCENE.instantiate()
		char_visual_instance.is_player = true
		sprite_preview_area.add_child(char_visual_instance)
		
		var ui_c = char_visual_instance.get_node_or_null("UIContainer")
		if ui_c:
			ui_c.visible = false
			
	# Position sprite nicely in the preview container
	var preview_size = sprite_preview_area.size
	if preview_size == Vector2.ZERO:
		preview_size = sprite_preview_area.custom_minimum_size
	char_visual_instance.position = Vector2(preview_size.x / 2.0, preview_size.y - 25.0)
	char_visual_instance.setup_character(hero_data)
	
	if celebrate and char_visual_instance.has_method("play_celebration"):
		char_visual_instance.play_celebration()
	else:
		char_visual_instance.play_custom_animation("idle")

func _render_affinities(container: HBoxContainer, affinities: Array[int]) -> void:
	for c in container.get_children():
		c.queue_free()
		
	if affinities.is_empty():
		var lbl = Label.new()
		lbl.text = "🥋 Taijutsu Puro"
		lbl.add_theme_font_size_override("font_size", 11)
		lbl.add_theme_color_override("font_color", Color(0.95, 0.6, 0.2))
		container.add_child(lbl)
	else:
		for aff in affinities:
			var badge = Panel.new()
			badge.custom_minimum_size = Vector2(28, 20)
			var st = StyleBoxFlat.new()
			st.set_corner_radius_all(4)
			st.bg_color = ChakraElement.get_element_color(aff)
			badge.add_theme_stylebox_override("panel", st)
			
			var lbl = Label.new()
			lbl.text = ChakraElement.get_element_icon(aff)
			lbl.set_anchors_preset(Control.PRESET_FULL_RECT)
			lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			lbl.add_theme_font_size_override("font_size", 11)
			badge.add_child(lbl)
			container.add_child(badge)

func _update_enemy_display() -> void:
	var enemy_id = StoryCampaignData.resolve_enemy_id(active_stage_data, selected_hero_id)
	var enemy_data = Database.get_character(enemy_id)
	if not enemy_data:
		return
		
	enemy_name_label.text = enemy_data.name
	enemy_title_label.text = enemy_data.title
	enemy_stats_label.text = "❤️ HP: %d  |  🏃 Vigor: %d" % [enemy_data.max_hp, enemy_data.max_vigor]
	_render_affinities(enemy_affinities_container, enemy_data.chakra_affinities)

func _render_briefing(stage: Dictionary) -> void:
	stage_desc_label.text = stage.get("desc", "")
	
	for c in dialogue_container.get_children():
		c.queue_free()
		
	var dialogues = stage.get("dialogue", [])
	for entry in dialogues:
		var speaker = entry.get("speaker", "")
		var text = entry.get("text", "")
		
		var d_lbl = RichTextLabel.new()
		d_lbl.fit_content = true
		d_lbl.bbcode_enabled = true
		d_lbl.text = "[color=#f5a623][b]%s:[/b][/color] %s" % [speaker, text]
		dialogue_container.add_child(d_lbl)

func _render_deck_preview(hero_data: CharacterData) -> void:
	for c in deck_cards_container.get_children():
		c.queue_free()
		
	var deck = hero_data.starting_deck
	deck_count_label.text = "(%d CARTAS)" % deck.size()
	
	for card in deck:
		if not card:
			continue
		var row = PanelContainer.new()
		row.custom_minimum_size = Vector2(0, 36)
		
		var st = StyleBoxFlat.new()
		st.set_corner_radius_all(5)
		st.set_border_width_all(1)
		st.bg_color = Color(0.09, 0.11, 0.16, 0.95)
		st.border_color = card.get_element_color()
		st.content_margin_left = 8
		st.content_margin_right = 8
		st.content_margin_top = 4
		st.content_margin_bottom = 4
		row.add_theme_stylebox_override("panel", st)
		
		var hbox = HBoxContainer.new()
		hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hbox.add_theme_constant_override("separation", 8)
		row.add_child(hbox)
		
		# Element color pill
		var elem_pill = Panel.new()
		elem_pill.custom_minimum_size = Vector2(6, 24)
		var p_style = StyleBoxFlat.new()
		p_style.set_corner_radius_all(3)
		p_style.bg_color = card.get_element_color()
		elem_pill.add_theme_stylebox_override("panel", p_style)
		hbox.add_child(elem_pill)
		
		# Name & Type
		var v_info = VBoxContainer.new()
		v_info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		v_info.alignment = BoxContainer.ALIGNMENT_CENTER
		
		var name_lbl = Label.new()
		name_lbl.text = card.name
		name_lbl.add_theme_font_size_override("font_size", 12)
		name_lbl.add_theme_color_override("font_color", Color.WHITE)
		v_info.add_child(name_lbl)
		
		var type_lbl = Label.new()
		type_lbl.text = card.get_type_name()
		type_lbl.add_theme_font_size_override("font_size", 9)
		type_lbl.add_theme_color_override("font_color", card.get_type_color())
		v_info.add_child(type_lbl)
		hbox.add_child(v_info)
		
		# Cost badge
		var cost_lbl = Label.new()
		cost_lbl.text = card.get_cost_full_display()
		cost_lbl.add_theme_font_size_override("font_size", 10)
		cost_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
		cost_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		cost_lbl.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		hbox.add_child(cost_lbl)
		
		deck_cards_container.add_child(row)

func _on_start_battle() -> void:
	if active_stage_data.is_empty():
		return
	SoundManager.play_sfx("chakra_charge", 1.2)
	prep_modal.visible = false
	GameManager.start_story_stage(active_stage_data, selected_hero_id)
