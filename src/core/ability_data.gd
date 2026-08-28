class_name AbilityData
extends Resource

enum AbilityType { TAIJUTSU, NINJUTSU, GENJUTSU, TRAP, SUPPORT, ULTIMATE }
enum TargetType { SINGLE_ENEMY, ALL_ENEMIES, SELF, ALLY, NO_TARGET }

@export_group("Informações Básicas")
@export var id: String = ""
@export var name: String = ""
@export_multiline var description: String = ""
@export var icon: Texture2D

@export_group("Custos e Alvo")
@export var yin_cost: int = 0
@export var yang_cost: int = 0
@export var is_exhaust: bool = false
@export var ability_type: AbilityType = AbilityType.TAIJUTSU
@export var target_type: TargetType = TargetType.SINGLE_ENEMY

@export_group("Motor de Triggers")
## Lista de tarefas a serem executadas.
## Formato: {"trigger": "on_play", "effect": "damage", "value": 15, "combo": 1, "hits": 1}
@export var scripts: Array[Dictionary] = []

@export_group("Visual e Áudio")
## Chave para a animação do personagem (ex: "attack", "rasengan", "kawarimi")
@export var animation_key: String = "attack"
## Animação em sprites reproduzida ao lançar o ataque (VFX extra)
@export var vfx_sprite_frames: SpriteFrames
@export var sfx_sound: AudioStream

@export_group("Mecânicas Específicas")
@export var qte_difficulty: int = 0
@export var support_name: String = ""

@export_group("Restrições de Uso")
## Deixe vazio se for para todos os personagens.
@export var allowed_character_ids: Array[String] = []
## Grupos permitidos (ex: ["ninja_fogo", "suporte"]).
@export var allowed_tags: Array[String] = []

func can_be_used_by(character: CharacterData) -> bool:
	if allowed_character_ids.is_empty() and allowed_tags.is_empty():
		return true
	if character.id in allowed_character_ids:
		return true
	for tag in allowed_tags:
		if tag in character.tags:
			return true
	return false

func get_type_name() -> String:
	match ability_type:
		AbilityType.TAIJUTSU: return "Taijutsu"
		AbilityType.NINJUTSU: return "Ninjutsu"
		AbilityType.GENJUTSU: return "Genjutsu"
		AbilityType.TRAP: return "Armadilha"
		AbilityType.SUPPORT: return "Suporte"
		AbilityType.ULTIMATE: return "Jutsu Secreto (Ougi)"
		_: return "Geral"

func get_type_color() -> Color:
	match ability_type:
		AbilityType.TAIJUTSU: return Color(0.95, 0.45, 0.2)
		AbilityType.NINJUTSU: return Color(0.2, 0.6, 0.95)
		AbilityType.GENJUTSU: return Color(0.7, 0.3, 0.9)
		AbilityType.TRAP: return Color(0.85, 0.75, 0.2)
		AbilityType.SUPPORT: return Color(0.2, 0.85, 0.4)
		AbilityType.ULTIMATE: return Color(0.95, 0.15, 0.35)
		_: return Color.WHITE
