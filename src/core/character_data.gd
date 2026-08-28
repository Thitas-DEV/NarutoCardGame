class_name CharacterData
extends Resource

@export_group("Identidade")
@export var id: String = ""
@export var name: String = ""
@export var title: String = ""
@export var portrait: Texture2D
## Tags para determinar grupos de habilidades (ex: ["ninja_fogo", "corpo_a_corpo"])
@export var tags: Array[String] = []

@export_group("Status Base")
@export var max_hp: int = 100
@export var current_hp: int = 100
@export var max_yin: int = 3
@export var max_yang: int = 3
@export var attack_modifier: float = 1.0
@export var avatar_color: Color = Color(1, 1, 1)
@export var secondary_color: Color = Color(0.5, 0.5, 0.5)

@export_group("Deck / Habilidades")
## Habilidades iniciais/vinculadas deste personagem
@export var starting_deck: Array[AbilityData] = []
