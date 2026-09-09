class_name ChakraElement
extends RefCounted

enum Type {
	NONE,       # Taijutsu / Neutro
	WATER,      # Suiton (Água)
	FIRE,       # Katon (Fogo)
	WIND,       # Fuuton (Vento)
	EARTH,      # Doton (Terra)
	LIGHTNING   # Raiton (Raio)
}

static func get_element_name(type: Type) -> String:
	match type:
		Type.WATER: return "Água (Suiton)"
		Type.FIRE: return "Fogo (Katon)"
		Type.WIND: return "Vento (Fuuton)"
		Type.EARTH: return "Terra (Doton)"
		Type.LIGHTNING: return "Raio (Raiton)"
		_: return "Taijutsu (Neutro)"

static func get_element_short_name(type: Type) -> String:
	match type:
		Type.WATER: return "Suiton"
		Type.FIRE: return "Katon"
		Type.WIND: return "Fuuton"
		Type.EARTH: return "Doton"
		Type.LIGHTNING: return "Raiton"
		_: return "Taijutsu"

static func get_element_icon(type: Type) -> String:
	match type:
		Type.WATER: return "💧"
		Type.FIRE: return "🔥"
		Type.WIND: return "🌪️"
		Type.EARTH: return "⛰️"
		Type.LIGHTNING: return "⚡"
		_: return "🥋"

static func get_element_color(type: Type) -> Color:
	match type:
		Type.WATER: return Color(0.2, 0.6, 1.0)       # Azul
		Type.FIRE: return Color(1.0, 0.35, 0.15)      # Laranja avermelhado
		Type.WIND: return Color(0.25, 0.85, 0.45)     # Verde esmeralda
		Type.EARTH: return Color(0.85, 0.6, 0.25)     # Ocre / Terra
		Type.LIGHTNING: return Color(1.0, 0.85, 0.15) # Amarelo elétrico
		_: return Color(0.9, 0.5, 0.2)                # Laranja Taijutsu
