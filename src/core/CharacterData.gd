# res://src/core/CharacterData.gd
class_name CharacterData
extends Resource

@export var id: String = "naruto"
@export var name: String = "Naruto Uzumaki"
@export var title: String = "Genin de Konoha"
@export var max_hp: int = 80
@export var current_hp: int = 80
@export var max_chakra: int = 3
@export var base_shield: int = 0
@export var avatar_color: Color = Color(1.0, 0.55, 0.0) # Naruto Orange
@export var secondary_color: Color = Color(0.1, 0.25, 0.7) # Blue

# Starting deck card IDs
@export var starting_deck_ids: Array[String] = []

# Unlocked cards available for deck building
@export var unlocked_card_ids: Array[String] = []

# Special traits & Passives
@export var passive_name: String = "Vontade do Fogo"
@export_multiline var passive_description: String = "Quando o HP cai abaixo de 30%, ganha +1 de Chakra por turno."
@export var transformation_id: String = "" # e.g. "naruto_kyuubi", "rock_lee_gates"

func duplicate_data() -> CharacterData:
	var copy = CharacterData.new()
	copy.id = id
	copy.name = name
	copy.title = title
	copy.max_hp = max_hp
	copy.current_hp = current_hp
	copy.max_chakra = max_chakra
	copy.base_shield = base_shield
	copy.avatar_color = avatar_color
	copy.secondary_color = secondary_color
	copy.starting_deck_ids = starting_deck_ids.duplicate()
	copy.unlocked_card_ids = unlocked_card_ids.duplicate()
	copy.passive_name = passive_name
	copy.passive_description = passive_description
	copy.transformation_id = transformation_id
	return copy
