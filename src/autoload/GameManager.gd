# res://src/autoload/GameManager.gd
extends Node

signal character_changed(character: CharacterData)
signal deck_updated(deck: Array[AbilityData])
signal story_progress_updated(node_id: String)

var active_hero: CharacterData
var player_deck: Array[AbilityData] = []
var player_collection: Array[AbilityData] = []

# Story campaign state
var current_story_act: int = 1
var completed_nodes: Array[String] = []
var current_node_id: String = "node_konoha_training"

# Active battle configuration
var active_encounter_id: String = "kakashi_bell_test"
var active_enemy_data: CharacterData = null
var is_scripted_phase: bool = false
var battle_reward_pool: Array[AbilityData] = []

func _ready() -> void:
	# Atrasamos um pouco o init para garantir que o Database carregue antes
	call_deferred("_init_player")

func _init_player() -> void:
	# Default to Naruto
	select_hero("naruto")

func select_hero(hero_id: String) -> void:
	# Buscamos o hero base do Database
	var base_hero = Database.get_character(hero_id)
	
	if base_hero:
		# Duplicamos para que as modificações de HP/Deck não afetem a base
		active_hero = base_hero.duplicate()
		player_deck = active_hero.starting_deck.duplicate()
		player_collection = active_hero.starting_deck.duplicate()
		
		# Emite sinais de que a seleção mudou
		character_changed.emit(active_hero)
		deck_updated.emit(player_deck)
	else:
		push_warning("Personagem " + hero_id + " não encontrado no banco de dados!")

func start_story_battle(encounter_id: String) -> void:
	active_encounter_id = encounter_id
	
	# Usamos a base de inimigos criados como recursos
	var enemy_base = null
	
	match encounter_id:
		"kakashi_bell_test":
			enemy_base = Database.get_character("kakashi")
		"zabuza_mist":
			enemy_base = Database.get_character("zabuza")
		"gaara_chunin_phase1":
			enemy_base = Database.get_character("gaara")
			is_scripted_phase = true
		_:
			enemy_base = Database.get_character("ninja_renegado")
			
	if enemy_base:
		active_enemy_data = enemy_base.duplicate()
	else:
		push_error("Inimigo do encontro " + encounter_id + " não encontrado!")
		
	get_tree().change_scene_to_file("res://src/battle/BattleField.tscn")

func add_ability_to_collection(ability: AbilityData) -> void:
	if not player_collection.has(ability):
		player_collection.append(ability)
		
func add_ability_to_deck(ability: AbilityData) -> void:
	player_deck.append(ability)
	deck_updated.emit(player_deck)

func remove_ability_from_deck(index: int) -> void:
	if index >= 0 and index < player_deck.size():
		player_deck.remove_at(index)
		deck_updated.emit(player_deck)
