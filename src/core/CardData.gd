# res://src/core/CardData.gd
class_name CardData
extends Resource

enum CardType {
	TAIJUTSU,   # Attack / Combo builder
	NINJUTSU,   # High damage / elemental skills
	GENJUTSU,   # Debuff / Posture break / Shield
	TRAP,       # Face-down counter (e.g. Kawarimi)
	SUPPORT,    # Assist partner (Sakura, Kakashi, etc.)
	ULTIMATE    # Ougi / Secret Jutsu with QTE
}

enum TargetType {
	SINGLE_ENEMY,
	ALL_ENEMIES,
	SELF,
	ALLY
}

enum Rarity {
	COMMON,
	UNCOMMON,
	RARE,
	LEGENDARY
}

@export var id: String = ""
@export var title: String = ""
@export_multiline var description: String = ""
@export var chakra_cost: int = 1
@export var card_type: CardType = CardType.TAIJUTSU
@export var target_type: TargetType = TargetType.SINGLE_ENEMY
@export var rarity: Rarity = Rarity.COMMON
@export var character_owner: String = "Naruto" # Character who owns this or "Universal"

# Combat values
@export var base_damage: int = 0
@export var hit_count: int = 1
@export var base_shield: int = 0
@export var combo_points: int = 1 # Points added to Storm combo meter
@export var chakra_gain: int = 0
@export var draw_cards: int = 0

# Status effects applied to target or self: [{"type": "burn", "value": 2, "target": "enemy"}]
@export var status_effects: Array[Dictionary] = []

# Jutsu & Animation data
@export var animation_key: String = "attack" # "rasengan", "chidori", "bunshin", "leaf_hurricane", "kawarimi", etc.
@export var qte_difficulty: int = 3 # Number of QTE inputs for Ultimate
@export var trap_trigger: String = "on_attacked" # Trigger condition for traps
@export var support_name: String = "" # Name of the assist partner

func get_type_name() -> String:
	match card_type:
		CardType.TAIJUTSU: return "Taijutsu"
		CardType.NINJUTSU: return "Ninjutsu"
		CardType.GENJUTSU: return "Genjutsu"
		CardType.TRAP: return "Armadilha"
		CardType.SUPPORT: return "Suporte"
		CardType.ULTIMATE: return "Jutsu Secreto (Ougi)"
		_: return "Geral"

func get_type_color() -> Color:
	match card_type:
		CardType.TAIJUTSU: return Color(0.95, 0.45, 0.2) # Orange/Red
		CardType.NINJUTSU: return Color(0.2, 0.6, 0.95) # Cyan/Blue
		CardType.GENJUTSU: return Color(0.7, 0.3, 0.9)  # Purple
		CardType.TRAP: return Color(0.85, 0.75, 0.2)     # Gold/Amber
		CardType.SUPPORT: return Color(0.2, 0.85, 0.4)   # Green
		CardType.ULTIMATE: return Color(0.95, 0.15, 0.35)# Crimson Red
		_: return Color.WHITE
