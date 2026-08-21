# res://src/core/StatusEffect.gd
class_name StatusEffect
extends RefCounted

enum Type {
	BURN,       # Takes damage at start/end of turn
	PARALYSIS,  # Reduces chakra or skips action
	BLEED,      # Extra damage on every hit taken
	FOCUS,      # Increases next jutsu damage
	GUARD,      # Temporary shield against hits
	STUN,       # Cannot act next turn
	STRENGTH,   # +Damage to all attacks
	GATES_OPEN  # Rock Lee special: massive damage boost, self-damage per turn
}

static func get_name(type: Type) -> String:
	match type:
		Type.BURN: return "Queimadura"
		Type.PARALYSIS: return "Paralisia"
		Type.BLEED: return "Sangramento"
		Type.FOCUS: return "Foco Ninja"
		Type.GUARD: return "Guarda"
		Type.STUN: return "Atordoado"
		Type.STRENGTH: return "Poder Shinobi"
		Type.GATES_OPEN: return "Portões Abertos"
		_: return "Status"

static func get_color(type: Type) -> Color:
	match type:
		Type.BURN: return Color(1.0, 0.4, 0.1)
		Type.PARALYSIS: return Color(1.0, 0.9, 0.2)
		Type.BLEED: return Color(0.9, 0.1, 0.1)
		Type.FOCUS: return Color(0.2, 0.8, 1.0)
		Type.GUARD: return Color(0.4, 0.7, 1.0)
		Type.STUN: return Color(0.8, 0.8, 0.2)
		Type.STRENGTH: return Color(0.9, 0.2, 0.5)
		Type.GATES_OPEN: return Color(0.1, 0.9, 0.4)
		_: return Color.WHITE
