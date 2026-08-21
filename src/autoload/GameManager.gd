# res://src/autoload/GameManager.gd
extends Node

signal character_changed(character: CharacterData)
signal deck_updated(deck_ids: Array[String])
signal story_progress_updated(node_id: String)

var active_hero: CharacterData
var player_deck_ids: Array[String] = []
var player_collection_ids: Array[String] = []

# Story campaign state
var current_story_act: int = 1
var completed_nodes: Array[String] = []
var current_node_id: String = "node_konoha_training"

# Active battle configuration
var active_encounter_id: String = "kakashi_bell_test"
var active_enemy_data: CharacterData = null
var is_scripted_phase: bool = false
var battle_reward_pool: Array[CardData] = []

func _ready() -> void:
	_init_player()

func _init_player() -> void:
	# Default to Naruto Uzumaki
	active_hero = CharacterData.new()
	active_hero.id = "naruto"
	active_hero.name = "Naruto Uzumaki"
	active_hero.title = "Genin de Konoha"
	active_hero.max_hp = 80
	active_hero.current_hp = 80
	active_hero.max_chakra = 3
	active_hero.avatar_color = Color(1.0, 0.52, 0.05) # Naruto Orange
	active_hero.secondary_color = Color(0.12, 0.35, 0.85) # Blue

	# Initial starting deck
	player_deck_ids = [
		"naruto_punch",
		"naruto_punch",
		"naruto_punch",
		"naruto_kick",
		"naruto_kick",
		"kage_bunshin",
		"kage_bunshin",
		"iron_guard",
		"iron_guard",
		"chakra_focus",
		"kawarimi_trap",
		"rasengan",
		"ougi_rasengan"
	]
	
	player_collection_ids = [
		"naruto_punch", "naruto_kick", "kage_bunshin", "bunshin_taiatari",
		"naruto_combo", "rasengan", "ougi_rasengan", "kawarimi_trap",
		"explosive_tag_trap", "chakra_focus", "iron_guard", "support_sakura",
		"support_kakashi", "sasuke_slash", "katon_goukakyuu", "konoha_senpuu"
	]

func select_hero(hero_id: String) -> void:
	match hero_id:
		"naruto":
			active_hero.id = "naruto"
			active_hero.name = "Naruto Uzumaki"
			active_hero.title = "O Garoto da Raposa"
			active_hero.max_hp = 80
			active_hero.current_hp = 80
			active_hero.max_chakra = 3
			active_hero.avatar_color = Color(1.0, 0.52, 0.05)
			active_hero.secondary_color = Color(0.12, 0.35, 0.85)
			player_deck_ids = [
				"naruto_punch", "naruto_punch", "naruto_kick", "kage_bunshin",
				"kage_bunshin", "bunshin_taiatari", "iron_guard", "chakra_focus",
				"kawarimi_trap", "rasengan", "ougi_rasengan"
			]
		"sasuke":
			active_hero.id = "sasuke"
			active_hero.name = "Sasuke Uchiha"
			active_hero.title = "Prodígio Uchiha"
			active_hero.max_hp = 75
			active_hero.current_hp = 75
			active_hero.max_chakra = 3
			active_hero.avatar_color = Color(0.15, 0.25, 0.75)
			active_hero.secondary_color = Color(0.9, 0.1, 0.15)
			player_deck_ids = [
				"sasuke_slash", "sasuke_slash", "sharingan_dodge", "sharingan_dodge",
				"katon_goukakyuu", "katon_housenka", "chidori", "ougi_chidori",
				"iron_guard", "kawarimi_trap", "chakra_focus"
			]
		"rock_lee":
			active_hero.id = "rock_lee"
			active_hero.name = "Rock Lee"
			active_hero.title = "Gênio do Esforço"
			active_hero.max_hp = 85
			active_hero.current_hp = 85
			active_hero.max_chakra = 2 # Lee relies on pure Taijutsu and Gates!
			active_hero.avatar_color = Color(0.1, 0.75, 0.3)
			active_hero.secondary_color = Color(0.95, 0.5, 0.1)
			player_deck_ids = [
				"konoha_senpuu", "konoha_senpuu", "konoha_reppu", "konoha_reppu",
				"shadow_leaf_dance", "omote_renge", "ura_renge",
				"iron_guard", "iron_guard", "chakra_focus"
			]
			
	character_changed.emit(active_hero)
	deck_updated.emit(player_deck_ids)

func start_story_battle(encounter_id: String) -> void:
	active_encounter_id = encounter_id
	var enemy = CharacterData.new()
	
	match encounter_id:
		"kakashi_bell_test":
			enemy.id = "kakashi"
			enemy.name = "Kakashi Hatake"
			enemy.title = "O Ninja Copiador"
			enemy.max_hp = 70
			enemy.current_hp = 70
			enemy.max_chakra = 4
			enemy.avatar_color = Color(0.45, 0.55, 0.65)
			enemy.secondary_color = Color(0.1, 0.15, 0.2)
			
		"zabuza_mist":
			enemy.id = "zabuza"
			enemy.name = "Zabuza Momochi"
			enemy.title = "Demônio da Névoa Oculta"
			enemy.max_hp = 95
			enemy.current_hp = 95
			enemy.max_chakra = 3
			enemy.avatar_color = Color(0.2, 0.45, 0.55)
			enemy.secondary_color = Color(0.1, 0.1, 0.1)
			
		"gaara_chunin_phase1":
			enemy.id = "gaara"
			enemy.name = "Gaara do Deserto"
			enemy.title = "Defesa Absoluta"
			enemy.max_hp = 120
			enemy.current_hp = 120
			enemy.max_chakra = 4
			enemy.avatar_color = Color(0.75, 0.35, 0.25)
			enemy.secondary_color = Color(0.85, 0.7, 0.45)
			is_scripted_phase = true
			
		_:
			enemy.id = "ninja_renegado"
			enemy.name = "Ninja Renegado"
			enemy.title = "Bandido da Vila Oculta"
			enemy.max_hp = 50
			enemy.current_hp = 50
			enemy.max_chakra = 3
			enemy.avatar_color = Color(0.4, 0.2, 0.5)
			enemy.secondary_color = Color(0.2, 0.2, 0.2)
			
	active_enemy_data = enemy
	get_tree().change_scene_to_file("res://src/battle/BattleField.tscn")

func add_card_to_collection(card_id: String) -> void:
	if not player_collection_ids.has(card_id):
		player_collection_ids.append(card_id)
		
func add_card_to_deck(card_id: String) -> void:
	player_deck_ids.append(card_id)
	deck_updated.emit(player_deck_ids)

func remove_card_from_deck(index: int) -> void:
	if index >= 0 and index < player_deck_ids.size():
		player_deck_ids.remove_at(index)
		deck_updated.emit(player_deck_ids)
