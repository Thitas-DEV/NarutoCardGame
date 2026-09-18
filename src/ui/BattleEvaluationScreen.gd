# res://src/ui/BattleEvaluationScreen.gd
extends Control

const CHARACTER_VISUAL_SCENE = preload("res://src/battle/CharacterVisual.tscn")

@onready var stage_title_label: Label = %StageTitleLabel
@onready var mission_status_label: Label = %MissionStatusLabel

# Combatants labels
@onready var hero_name_label: Label = %HeroNameLabel
@onready var hero_title_label: Label = %HeroTitleLabel
@onready var enemy_name_label: Label = %EnemyNameLabel
@onready var enemy_title_label: Label = %EnemyTitleLabel

# Performance stats labels
@onready var damage_dealt_label: Label = %DamageDealtValue
@onready var damage_taken_label: Label = %DamageTakenValue
@onready var turns_label: Label = %TurnsValue
@onready var rank_letter_label: Label = %RankLetterLabel
@onready var rank_title_label: Label = %RankTitleLabel

# Roguelike Unlocks container
@onready var unlock_section: Control = %UnlockSection
@onready var unlock_section_title: Label = %UnlockSectionTitle
@onready var unlock_cards_container: VBoxContainer = %UnlockCardsContainer

# Action button
@onready var continue_btn: Button = %ContinueButton

var nj_font: FontFile = null

func _ready() -> void:
	continue_btn.pressed.connect(_on_continue_pressed)
	_setup_naruto_fonts()
	_populate_evaluation()

func _setup_naruto_fonts() -> void:
	if ResourceLoader.exists("res://assets/UI/fonts/njnaruto.ttf"):
		nj_font = load("res://assets/UI/fonts/njnaruto.ttf") as FontFile
		if ResourceLoader.exists("res://assets/fonts/Oswald/static/Oswald-Bold.ttf"):
			var fallback_font = load("res://assets/fonts/Oswald/static/Oswald-Bold.ttf") as FontFile
			if nj_font and fallback_font and nj_font.fallbacks.is_empty():
				nj_font.fallbacks = [fallback_font]
				
	if nj_font:
		_apply_naruto_font(self)

func _apply_naruto_font(node: Node) -> void:
	if node is Label:
		node.add_theme_font_override("font", nj_font)
		node.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.95))
		node.add_theme_constant_override("shadow_offset_x", 2)
		node.add_theme_constant_override("shadow_offset_y", 2)
		node.add_theme_color_override("font_outline_color", Color(0.08, 0.04, 0.01, 1.0))
		node.add_theme_constant_override("outline_size", 3)
	elif node is Button:
		node.add_theme_font_override("font", nj_font)
		node.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.95))
		node.add_theme_constant_override("shadow_offset_x", 2)
		node.add_theme_constant_override("shadow_offset_y", 2)
		node.add_theme_color_override("font_outline_color", Color(0.12, 0.04, 0.0, 1.0))
		node.add_theme_constant_override("outline_size", 4)
		
	for child in node.get_children():
		_apply_naruto_font(child)

func _populate_evaluation() -> void:
	var stats = GameManager.last_battle_stats
	
	var damage_dealt: int = stats.get("damage_dealt", 0)
	var damage_taken: int = stats.get("damage_taken", 0)
	var turns_count: int = stats.get("turns_count", 1)
	var hero: CharacterData = stats.get("hero", GameManager.active_hero)
	var enemy: CharacterData = stats.get("enemy", GameManager.active_enemy_data)
	var stage_title: String = stats.get("stage_title", "Batalha Ninja")
	var stage_num: String = stats.get("stage_number", "")
	var newly_unlocked: Array = stats.get("newly_unlocked", [])
	
	# Cabeçalho
	if stage_num != "":
		stage_title_label.text = "FASE %s — %s" % [stage_num, stage_title.to_upper()]
	else:
		stage_title_label.text = stage_title.to_upper()
	mission_status_label.text = "★ MISSÃO CONCLUÍDA COM SUCESSO! ★"
	
	# Combatentes
	if hero:
		hero_name_label.text = hero.name
		hero_title_label.text = hero.title if hero.title != "" else "Shinobi Aliado"
	else:
		hero_name_label.text = "Ninja Aliado"
		hero_title_label.text = "Herói"
		
	if enemy:
		enemy_name_label.text = enemy.name
		enemy_title_label.text = (enemy.title if enemy.title != "" else "Oponente") + " [DERROTADO 💀]"
	else:
		enemy_name_label.text = "Inimigo"
		enemy_title_label.text = "Oponente [DERROTADO 💀]"
		
	# Estatísticas de Batalha
	damage_dealt_label.text = "%d" % damage_dealt
	damage_taken_label.text = "%d" % damage_taken
	turns_label.text = "%d Turnos" % turns_count
	
	# Avaliação do Rank Shinobi Estilo Storm 4
	var rank_info = _calculate_rank(damage_taken, turns_count)
	rank_letter_label.text = rank_info["letter"]
	rank_letter_label.modulate = rank_info["color"]
	rank_title_label.text = rank_info["title"]
	rank_title_label.modulate = rank_info["color"]
	
	# Desbloqueios do Modo Rogue Like com sprite IDLE
	_render_roguelike_unlocks(newly_unlocked, hero, enemy)
	
	# Efeito sonoro de vitória
	SoundManager.play_sfx("qte_success", 1.2)

func _calculate_rank(damage_taken: int, turns: int) -> Dictionary:
	if damage_taken == 0:
		return {
			"letter": "S+",
			"title": "IMPECÁVEL (SEM DANOS)",
			"color": Color(1.0, 0.95, 0.25)
		}
	elif damage_taken <= 20 and turns <= 6:
		return {
			"letter": "S",
			"title": "LENDÁRIO (MESTRE SHINOBI)",
			"color": Color(1.0, 0.85, 0.2)
		}
	elif damage_taken <= 45 and turns <= 8:
		return {
			"letter": "A",
			"title": "EXCELENTE (NÍVEL JOUNIN)",
			"color": Color(0.2, 0.85, 1.0)
		}
	elif damage_taken <= 80:
		return {
			"letter": "B",
			"title": "BOM (NÍVEL CHUNIN)",
			"color": Color(0.3, 0.9, 0.4)
		}
	else:
		return {
			"letter": "C",
			"title": "CONCLUÍDO (NÍVEL GENIN)",
			"color": Color(0.95, 0.6, 0.2)
		}

func _create_idle_sprite(char_data: CharacterData) -> Control:
	var box = Control.new()
	box.custom_minimum_size = Vector2(95, 90)
	box.clip_contents = false
	
	var char_vis = CHARACTER_VISUAL_SCENE.instantiate()
	char_vis.is_player = true
	box.add_child(char_vis)
	if not char_vis.is_node_ready():
		char_vis._ready()
	
	var ui_c = char_vis.get_node_or_null("UIContainer")
	if ui_c:
		ui_c.visible = false
		
	# Centraliza o sprite no box de preview
	char_vis.position = Vector2(48.0, 72.0)
	char_vis.setup_character(char_data)
	char_vis.play_custom_animation("idle")
	
	return box

func _render_roguelike_unlocks(unlocked_list: Array, current_hero: CharacterData, current_enemy: CharacterData) -> void:
	for child in unlock_cards_container.get_children():
		child.queue_free()
		
	if not unlocked_list.is_empty():
		unlock_section_title.text = "✨ NOVO PERSONAGEM DESBLOQUEADO PARA O MODO ROGUE LIKE! ✨"
		unlock_section.visible = true
		
		for u in unlocked_list:
			var c_data = u.get("character_data") as CharacterData
			if not c_data:
				c_data = Database.get_character(u.get("id", ""))
			if not c_data:
				continue
				
			var card = _build_unlock_card(c_data, u.get("reason", "hero"), true)
			unlock_cards_container.add_child(card)
	else:
		# Se já estava tudo desbloqueado, apresenta o herói participante em IDLE
		unlock_section_title.text = "✓ SHINOBIS DESTA BATALHA NO MODO ROGUE LIKE"
		unlock_section.visible = true
		if current_hero:
			var card = _build_unlock_card(current_hero, "hero", false)
			unlock_cards_container.add_child(card)

func _build_unlock_card(char_data: CharacterData, reason: String, is_new: bool) -> PanelContainer:
	var panel = PanelContainer.new()
	var p_style = StyleBoxFlat.new()
	p_style.bg_color = Color(0.1, 0.08, 0.06, 0.92) if is_new else Color(0.08, 0.1, 0.14, 0.85)
	p_style.border_color = Color(1.0, 0.85, 0.25, 0.95) if is_new else Color(0.3, 0.45, 0.6, 0.7)
	p_style.border_width_left = 2
	p_style.border_width_right = 2
	p_style.border_width_top = 2
	p_style.border_width_bottom = 2
	p_style.set_corner_radius_all(8)
	p_style.content_margin_left = 14.0
	p_style.content_margin_right = 14.0
	p_style.content_margin_top = 8.0
	p_style.content_margin_bottom = 8.0
	panel.add_theme_stylebox_override("panel", p_style)
	
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 16)
	
	# 1. Sprite do Personagem em IDLE
	var sprite_box = _create_idle_sprite(char_data)
	hbox.add_child(sprite_box)
	
	# 2. Informações e Textos do Desbloqueio
	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	
	var title_lbl = Label.new()
	var char_title = char_data.title if char_data.title != "" else "Shinobi"
	title_lbl.text = "%s (%s)" % [char_data.name, char_title]
	title_lbl.add_theme_font_size_override("font_size", 16)
	title_lbl.add_theme_color_override("font_color", Color(1.0, 0.9, 0.3) if is_new else Color(0.85, 0.9, 1.0))
	if nj_font:
		title_lbl.add_theme_font_override("font", nj_font)
	title_lbl.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.9))
	title_lbl.add_theme_constant_override("shadow_offset_x", 2)
	title_lbl.add_theme_constant_override("shadow_offset_y", 2)
	title_lbl.add_theme_color_override("font_outline_color", Color(0.1, 0.05, 0.0, 1.0))
	title_lbl.add_theme_constant_override("outline_size", 3)
	vbox.add_child(title_lbl)
	
	var desc_lbl = Label.new()
	if is_new:
		if reason == "hero":
			desc_lbl.text = "🌟 DESBLOQUEADO PARA O MODO ROGUE LIKE! (1ª Vitória com este Herói)"
		else:
			desc_lbl.text = "⚔️ DESBLOQUEADO PARA O MODO ROGUE LIKE! (1ª Vitória contra este Oponente)"
		desc_lbl.add_theme_color_override("font_color", Color(0.4, 1.0, 0.5))
	else:
		desc_lbl.text = "✓ Personagem já disponível na seleção do Modo Rogue Like."
		desc_lbl.add_theme_color_override("font_color", Color(0.7, 0.8, 0.9))
		
	desc_lbl.add_theme_font_size_override("font_size", 12)
	if nj_font:
		desc_lbl.add_theme_font_override("font", nj_font)
	desc_lbl.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.9))
	desc_lbl.add_theme_constant_override("shadow_offset_x", 1)
	desc_lbl.add_theme_constant_override("shadow_offset_y", 1)
	vbox.add_child(desc_lbl)
	
	# 3. Naturezas de Chakra / Badges
	var affinities_box = HBoxContainer.new()
	affinities_box.add_theme_constant_override("separation", 6)
	if char_data.chakra_affinities.is_empty():
		var tai_lbl = Label.new()
		tai_lbl.text = "🥋 Especialista em Taijutsu"
		tai_lbl.add_theme_font_size_override("font_size", 11)
		tai_lbl.add_theme_color_override("font_color", Color(0.95, 0.6, 0.2))
		if nj_font:
			tai_lbl.add_theme_font_override("font", nj_font)
		affinities_box.add_child(tai_lbl)
	else:
		for aff in char_data.chakra_affinities:
			var badge = Panel.new()
			badge.custom_minimum_size = Vector2(26, 18)
			var b_st = StyleBoxFlat.new()
			b_st.set_corner_radius_all(4)
			b_st.bg_color = ChakraElement.get_element_color(aff)
			badge.add_theme_stylebox_override("panel", b_st)
			var b_lbl = Label.new()
			b_lbl.text = ChakraElement.get_element_icon(aff)
			b_lbl.set_anchors_preset(Control.PRESET_FULL_RECT)
			b_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			b_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			b_lbl.add_theme_font_size_override("font_size", 10)
			badge.add_child(b_lbl)
			affinities_box.add_child(badge)
			
	vbox.add_child(affinities_box)
	hbox.add_child(vbox)
	panel.add_child(hbox)
	return panel

func _on_continue_pressed() -> void:
	SoundManager.play_sfx("card_play")
	GameManager.complete_active_stage()
	if GameManager.active_hero:
		GameManager.active_hero.current_hp = GameManager.active_hero.max_hp
	get_tree().change_scene_to_file("res://src/map/StoryMap.tscn")
