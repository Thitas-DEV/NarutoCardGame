# Database.gd (Adicionado em Project Settings -> Autoload)
extends Node

var abilities_db: Dictionary = {} # id -> AbilityData
var characters_db: Dictionary = {} # id -> CharacterData

func _ready() -> void:
	load_all_abilities("res://data/abilities/")
	load_all_characters("res://data/characters/")

func load_all_abilities(path: String) -> void:
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tres") or file_name.ends_with(".remap"):
				var res_path = path + file_name.trim_suffix(".remap")
				var ability: AbilityData = load(res_path)
				if ability:
					abilities_db[ability.id] = ability
			file_name = dir.get_next()

func load_all_characters(path: String) -> void:
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tres") or file_name.ends_with(".remap"):
				var res_path = path + file_name.trim_suffix(".remap")
				var character: CharacterData = load(res_path)
				if character:
					characters_db[character.id] = character
			file_name = dir.get_next()

## Retorna todas as cartas disponíveis para um personagem específico
func get_available_abilities_for(character: CharacterData) -> Array[AbilityData]:
	var result: Array[AbilityData] = []
	for ability in abilities_db.values():
		if ability.can_be_used_by(character):
			result.append(ability)
	return result

func get_character(id: String) -> CharacterData:
	if characters_db.has(id):
		return characters_db[id]
	return null

func get_ability(id: String) -> AbilityData:
	if abilities_db.has(id):
		return abilities_db[id]
	return null

func get_random_reward_cards(character: CharacterData, count: int = 3) -> Array[AbilityData]:
	var eligible = get_available_abilities_for(character)
	eligible.shuffle()
	var result: Array[AbilityData] = []
	var limit = mini(count, eligible.size())
	for i in range(limit):
		result.append(eligible[i])
	return result
