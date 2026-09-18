# res://src/autoload/GameManager.gd
extends Node

signal character_changed(character: CharacterData)
signal deck_updated(deck: Array[AbilityData])
signal story_progress_updated(stage_id: String)

var active_hero: CharacterData
var player_deck: Array[AbilityData] = []
var player_collection: Array[AbilityData] = []

# Story campaign state
var current_story_world: int = 1
var current_story_act: int = 1
var completed_nodes: Array[String] = []
var completed_stages: Array[String] = []
var current_node_id: String = "node_konoha_training"
var active_stage_data: Dictionary = {}

# Active battle configuration
var active_encounter_id: String = "stage_1_0"
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
	var base_hero = Database.get_character(hero_id)
	
	if base_hero:
		active_hero = base_hero.duplicate()
		player_deck = active_hero.starting_deck.duplicate()
		player_collection = active_hero.starting_deck.duplicate()
		
		character_changed.emit(active_hero)
		deck_updated.emit(player_deck)
	else:
		push_warning("Personagem " + hero_id + " não encontrado no banco de dados!")

## Inicia uma fase do novo modo história com o herói escolhido pelo jogador
func start_story_stage(stage_data: Dictionary, selected_hero_id: String) -> void:
	active_stage_data = stage_data
	active_encounter_id = stage_data.get("id", "stage_1_0")
	
	# Configura o herói selecionado
	select_hero(selected_hero_id)
	
	# Determina o oponente (considerando a regra dinâmica da fase 4.6)
	var enemy_id = StoryCampaignData.resolve_enemy_id(stage_data, selected_hero_id)
	var enemy_base = Database.get_character(enemy_id)
	if not enemy_base:
		enemy_base = Database.get_character("ninja_renegado")
		
	if enemy_base:
		active_enemy_data = enemy_base.duplicate()
	else:
		push_error("Inimigo " + enemy_id + " não encontrado no banco de dados!")
		
	# Batalhas com eventos scriptados (Lee vs Gaara, etc)
	if active_encounter_id in ["stage_2_5", "gaara_chunin_phase1"]:
		is_scripted_phase = true
	else:
		is_scripted_phase = false
		
	get_tree().change_scene_to_file("res://src/battle/BattleField.tscn")

## Marca a fase ativa como concluída no progresso
func complete_active_stage() -> void:
	var s_id = active_stage_data.get("id", active_encounter_id)
	if s_id != "" and not completed_stages.has(s_id):
		completed_stages.append(s_id)
		completed_nodes.append(s_id)
		story_progress_updated.emit(s_id)

func start_story_battle(encounter_id: String) -> void:
	active_encounter_id = encounter_id
	
	var enemy_base = null
	match encounter_id:
		"kakashi_bell_test":
			enemy_base = Database.get_character("kakashi")
		"zabuza_mist":
			enemy_base = Database.get_character("zabuza")
		"gaara_chunin_phase1":
			enemy_base = Database.get_character("gaara")
			is_scripted_phase = true
		"valley_of_the_end":
			enemy_base = Database.get_character("sasuke")
		_:
			enemy_base = Database.get_character(encounter_id)
			if not enemy_base:
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
