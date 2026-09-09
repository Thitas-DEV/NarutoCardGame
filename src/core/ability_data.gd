class_name AbilityData
extends Resource

enum AbilityType { TAIJUTSU, NINJUTSU, GENJUTSU, TRAP, SUPPORT, ULTIMATE }
enum TargetType { SINGLE_ENEMY, ALL_ENEMIES, SELF, ALLY, NO_TARGET }
enum DeliveryType {
	MELEE_DASH,       ## Avanço físico até o alvo com golpe direto (ex: Soco, Rasengan, Chidori)
	PROJECTILE,       ## Lançamento de projétil à distância enquanto o ninja permanece no local (ex: Katon, Suiton)
	CELESTIAL_STRIKE, ## Descarga dos céus ou erupção elemental sobre o alvo (ex: Kirin)
	CLONES,           ## Invocação de Clones das Sombras que avançam e desferem múltiplos golpes
	SUMMON,           ## Invocação (Kuchiyose / Selos) de entidade espectral ou besta
	SELF_CAST         ## Habilidades defensivas, canalização ou postura no próprio usuário (ex: Doton, Guarda)
}

@export_group("Informações Básicas")
@export var id: String = ""
@export var name: String = ""
@export_multiline var description: String = ""
@export var icon: Texture2D

@export_group("Natureza de Chakra e Custo")
## Natureza elemental exigida (Água, Fogo, Vento, Terra, Raio). Deixe NONE para Taijutsu neutro.
@export var required_element: ChakraElement.Type = ChakraElement.Type.NONE
## Quantidade de pontos daquela natureza necessários para lançar
@export var element_cost: int = 0
@export var is_exhaust: bool = false
@export var ability_type: AbilityType = AbilityType.TAIJUTSU
@export var target_type: TargetType = TargetType.SINGLE_ENEMY

@export_group("Estratégia de Execução Visual")
## Como a habilidade se manifesta visualmente no campo de batalha
@export var delivery_type: DeliveryType = DeliveryType.MELEE_DASH
## Textura opcional para o projétil (se nulo, usa efeito procedural estilizado)
@export var projectile_texture: Texture2D
## Cor predominante do projétil, brilho ou raio
@export var projectile_color: Color = Color(1.0, 0.5, 0.1)
## Velocidade de deslocamento do projétil em pixels por segundo
@export var projectile_speed: float = 900.0
## Intensidade do tremor de tela (Screen Shake) no momento do impacto
@export var screen_shake_intensity: float = 0.0

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
## Dificuldade do QTE (apenas para Ougi / Ultimate). 0 = Sem QTE.
@export var qte_difficulty: int = 0
@export var support_name: String = ""

@export_group("Restrições de Uso")
## Deixe vazio se for para todos os personagens.
@export var allowed_character_ids: Array[String] = []
## Grupos permitidos (ex: ["ninja_fogo", "suporte"]).
@export var allowed_tags: Array[String] = []

func can_be_used_by(character: CharacterData) -> bool:
	# Taijutsu / Neutro pode ser usado por todos
	if required_element != ChakraElement.Type.NONE:
		if not character.has_affinity(required_element):
			return false
			
	if not allowed_character_ids.is_empty() and not (character.id in allowed_character_ids):
		return false
		
	if not allowed_tags.is_empty():
		var has_matching_tag = false
		for tag in allowed_tags:
			if tag in character.tags:
				has_matching_tag = true
				break
		if not has_matching_tag:
			return false
			
	return true

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
		AbilityType.TAIJUTSU: return Color(0.95, 0.5, 0.2)
		AbilityType.NINJUTSU: return ChakraElement.get_element_color(required_element) if required_element != ChakraElement.Type.NONE else Color(0.2, 0.6, 0.95)
		AbilityType.GENJUTSU: return Color(0.7, 0.3, 0.9)
		AbilityType.TRAP: return Color(0.85, 0.75, 0.2)
		AbilityType.SUPPORT: return Color(0.2, 0.85, 0.4)
		AbilityType.ULTIMATE: return Color(0.95, 0.15, 0.35)
		_: return Color.WHITE

func get_element_color() -> Color:
	return ChakraElement.get_element_color(required_element)

func get_cost_display() -> String:
	if required_element == ChakraElement.Type.NONE or element_cost == 0:
		return "TAIJUTSU (0)"
	var icon = ChakraElement.get_element_icon(required_element)
	var short_name = ChakraElement.get_element_short_name(required_element)
	return "%s %d %s" % [icon, element_cost, short_name.to_upper()]
