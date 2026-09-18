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

func _ready() -> void:
	_setup_font_fallbacks()
	_update_logo_size()
	
	if not Engine.is_editor_hint():
		get_tree().paused = false
		_setup_button_connections()

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
	GameManager.select_hero("rock_lee")
	GameManager.start_story_battle("gaara_chunin_phase1")

func _on_story_mode_pressed() -> void:
	SoundManager.play_sfx("chakra_charge", 1.2)
	get_tree().change_scene_to_file("res://src/map/StoryMap.tscn")

func _on_deck_pressed() -> void:
	SoundManager.play_sfx("card_draw")
	get_tree().change_scene_to_file("res://src/deck_builder/DeckBuilder.tscn")
