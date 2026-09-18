@tool
extends Control

@export_group("Logo do Título")
## Fator de escala da logo do título (1.0 = 100%, 1.2 = 120%, 0.8 = 80%).
## Altere este valor para redimensionar a logo de forma simplificada e em tempo real!
@export_range(0.2, 3.0, 0.05) var logo_scale: float = 1.0:
	set(value):
		logo_scale = value
		_update_logo_size()

## Tamanho base de referência da logo (largura x altura em pixels, proporção nativa ~3.6:1)
@export var logo_base_size: Vector2 = Vector2(480, 133):
	set(value):
		logo_base_size = value
		_update_logo_size()

@onready var title_logo: TextureRect = $VBoxContainer/TitleLogo if has_node("VBoxContainer/TitleLogo") else null
@onready var quick_battle_btn: Button = $GameModes/QuickBattleButton if has_node("GameModes/QuickBattleButton") else null
@onready var story_mode_btn: Button = $GameModes/StoryModeButton if has_node("GameModes/StoryModeButton") else null
@onready var deck_btn: Button = $GameModes/Deck if has_node("GameModes/Deck") else null

var hero_select_btn: OptionButton
var infinite_mana_btn: CheckButton

func _ready() -> void:
	_setup_font_fallbacks()
	_update_logo_size()
	
	if Engine.is_editor_hint():
		# Forçar a criação das cartas da Sakura via ResourceSaver para garantir UIDs e sintaxe correta do Godot 4
		var AbilityDataClass = load("res://src/core/ability_data.gd")
		if AbilityDataClass:
			var punch = AbilityDataClass.new()
			punch.id = "sakura_punch"
			punch.name = "Soco Certeiro"
			punch.description = "Um soco direto."
			punch.vigor_cost = 10
			punch.animation_key = "attack"
			punch.screen_shake_intensity = 3.0
			punch.scripts = [{"combo": 1, "effect": "damage", "hits": 1, "trigger": "on_play", "value": 6}]
			ResourceSaver.save(punch, "res://data/abilities/sakura_punch.tres")
			
			var kunai = AbilityDataClass.new()
			kunai.id = "sakura_kunai_slice"
			kunai.name = "Corte Rápido"
			kunai.description = "Ataque rápido com kunai."
			kunai.vigor_cost = 8
			kunai.animation_key = "attack2"
			kunai.screen_shake_intensity = 2.0
			kunai.scripts = [{"combo": 1, "effect": "damage", "hits": 1, "trigger": "on_play", "value": 4}]
			ResourceSaver.save(kunai, "res://data/abilities/sakura_kunai_slice.tres")
			
			var kick = AbilityDataClass.new()
			kick.id = "sakura_kick"
			kick.name = "Chute Frontal"
			kick.description = "Um chute com força média."
			kick.vigor_cost = 15
			kick.animation_key = "attack3"
			kick.screen_shake_intensity = 4.0
			kick.scripts = [{"combo": 1, "effect": "damage", "hits": 1, "trigger": "on_play", "value": 8}]
			ResourceSaver.save(kick, "res://data/abilities/sakura_kick.tres")
			
			var flying_kick = AbilityDataClass.new()
			flying_kick.id = "sakura_flying_kick"
			flying_kick.name = "Chute Voador"
			flying_kick.description = "Golpe poderoso que causa alto dano."
			flying_kick.vigor_cost = 25
			flying_kick.animation_key = "attack4"
			flying_kick.screen_shake_intensity = 6.0
			flying_kick.scripts = [{"combo": 1, "effect": "damage", "hits": 1, "trigger": "on_play", "value": 15}]
			ResourceSaver.save(flying_kick, "res://data/abilities/sakura_flying_kick.tres")
			
			var healing = AbilityDataClass.new()
			healing.id = "sakura_healing"
			healing.name = "Ninjutsu Médico"
			healing.description = "Cura um pouco de HP."
			healing.vigor_cost = 15
			healing.element_cost = 1
			healing.required_element = 4
			healing.delivery_type = 5 # SELF_CAST
			healing.animation_key = "healing"
			healing.screen_shake_intensity = 0.0
			healing.scripts = [{"effect": "heal", "trigger": "on_play", "value": 10}]
			ResourceSaver.save(healing, "res://data/abilities/sakura_healing.tres")
			print("Cartas da Sakura recriadas com sucesso via Godot Editor!")
	
	if not Engine.is_editor_hint():
		get_tree().paused = false
		call_deferred("_setup_dev_ui")
		_setup_button_connections()

func _setup_dev_ui() -> void:
	if not quick_battle_btn: return
	var parent = quick_battle_btn.get_parent()
	
	hero_select_btn = OptionButton.new()
	hero_select_btn.custom_minimum_size = Vector2(0, 40)
	parent.add_child(hero_select_btn)
	parent.move_child(hero_select_btn, quick_battle_btn.get_index())
	
	var chars = Database.characters_db.values()
	var idx = 0
	for c in chars:
		hero_select_btn.add_item(c.name, idx)
		hero_select_btn.set_item_metadata(idx, c.id)
		if c.id == "sakura":
			hero_select_btn.select(idx)
		idx += 1
		
	infinite_mana_btn = CheckButton.new()
	infinite_mana_btn.text = "Mana Infinita (Testes)"
	parent.add_child(infinite_mana_btn)
	parent.move_child(infinite_mana_btn, quick_battle_btn.get_index())

func _update_logo_size() -> void:
	var logo = title_logo
	if not logo and has_node("VBoxContainer/TitleLogo"):
		logo = $VBoxContainer/TitleLogo as TextureRect
	if logo:
		logo.custom_minimum_size = logo_base_size * logo_scale

func _setup_font_fallbacks() -> void:
	# njnaruto.ttf não possui acentuação nativa (á, ó, ç, ã).
	# Registramos Oswald como fallback para exibir qualquer acento sem erros visuais.
	if ResourceLoader.exists("res://assets/UI/fonts/njnaruto.ttf") and ResourceLoader.exists("res://assets/fonts/Oswald/static/Oswald-Bold.ttf"):
		var nj_font = load("res://assets/UI/fonts/njnaruto.ttf") as FontFile
		var fallback_font = load("res://assets/fonts/Oswald/static/Oswald-Bold.ttf") as FontFile
		if nj_font and fallback_font and nj_font.fallbacks.is_empty():
			nj_font.fallbacks = [fallback_font]

func _setup_button_connections() -> void:
	if quick_battle_btn and not quick_battle_btn.pressed.is_connected(_on_quick_battle_pressed):
		quick_battle_btn.pressed.connect(_on_quick_battle_pressed)
	if story_mode_btn and not story_mode_btn.pressed.is_connected(_on_story_mode_pressed):
		story_mode_btn.pressed.connect(_on_story_mode_pressed)
	if deck_btn and not deck_btn.pressed.is_connected(_on_deck_pressed):
		deck_btn.pressed.connect(_on_deck_pressed)

func _on_quick_battle_pressed() -> void:
	SoundManager.play_sfx("combo_storm")
	
	if hero_select_btn and hero_select_btn.selected >= 0:
		GameManager.select_hero(hero_select_btn.get_item_metadata(hero_select_btn.selected))
	else:
		GameManager.select_hero("rock_lee")
		
	if infinite_mana_btn:
		GameManager.infinite_mana_mode = infinite_mana_btn.button_pressed
		
	GameManager.start_story_battle("gaara_chunin_phase1")

func _on_story_mode_pressed() -> void:
	SoundManager.play_sfx("chakra_charge", 1.2)
	get_tree().change_scene_to_file("res://src/map/StoryMap.tscn")

func _on_deck_pressed() -> void:
	SoundManager.play_sfx("card_draw")
	get_tree().change_scene_to_file("res://src/deck_builder/DeckBuilder.tscn")
