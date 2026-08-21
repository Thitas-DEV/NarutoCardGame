# res://src/ui/MainMenu.gd
extends Control

@onready var story_btn: Button = $VBoxButtons/StoryModeBtn
@onready var quick_battle_btn: Button = $VBoxButtons/QuickBattleBtn
@onready var deck_builder_btn: Button = $VBoxButtons/DeckBuilderBtn
@onready var hero_naruto_btn: Button = $HeroSelect/HBox/HeroNaruto
@onready var hero_sasuke_btn: Button = $HeroSelect/HBox/HeroSasuke
@onready var hero_lee_btn: Button = $HeroSelect/HBox/HeroLee
@onready var hero_desc_label: RichTextLabel = $HeroSelect/HeroDesc

func _ready() -> void:
	story_btn.pressed.connect(_on_story_pressed)
	quick_battle_btn.pressed.connect(_on_quick_battle_pressed)
	deck_builder_btn.pressed.connect(_on_deck_builder_pressed)
	
	hero_naruto_btn.pressed.connect(func(): _select_hero_ui("naruto"))
	hero_sasuke_btn.pressed.connect(func(): _select_hero_ui("sasuke"))
	hero_lee_btn.pressed.connect(func(): _select_hero_ui("rock_lee"))
	
	_select_hero_ui("naruto")

func _select_hero_ui(hero_id: String) -> void:
	GameManager.select_hero(hero_id)
	SoundManager.play_sfx("card_draw", 1.1)
	
	match hero_id:
		"naruto":
			hero_desc_label.text = "[b][color=#ff9933]NARUTO UZUMAKI[/color][/b]\nEspecialidade: Clones das Sombras, Combos rápidos e Rasengan Devastador.\n[color=#33d6ff]Passiva:[/color] Recupera Chakra ao sofrer pressão."
		"sasuke":
			hero_desc_label.text = "[b][color=#3388ff]SASUKE UCHIHA[/color][/b]\nEspecialidade: Katon Bola de Fogo, Chidori perfurante e esquivas com Sharingan.\n[color=#ff3333]Passiva:[/color] Sangramento e paralisia com jutsus relâmpago."
		"rock_lee":
			hero_desc_label.text = "[b][color=#33dd66]ROCK LEE[/color][/b]\nEspecialidade: Taijutsu puro, acúmulo veloz de Hits Storm 4 e Liberação dos 5 Portões Internos.\n[color=#ffff33]Passiva:[/color] Dano de combo amplificado ao extremo."

func _on_story_pressed() -> void:
	SoundManager.play_sfx("chakra_charge", 1.2)
	get_tree().change_scene_to_file("res://src/map/StoryMap.tscn")

func _on_quick_battle_pressed() -> void:
	SoundManager.play_sfx("combo_storm")
	GameManager.select_hero("rock_lee") # Lee vs Gaara iconic fight
	GameManager.start_story_battle("gaara_chunin_phase1")

func _on_deck_builder_pressed() -> void:
	SoundManager.play_sfx("card_draw")
	get_tree().change_scene_to_file("res://src/deck_builder/DeckBuilder.tscn")
