# res://src/autoload/CardDatabase.gd
extends Node

var cards: Dictionary = {}

func _ready() -> void:
	_init_database()

func _init_database() -> void:
	# ==================== NARUTO CARDS ====================
	_add_card("naruto_punch", "Soco Ninja", "Desfere um golpe frontal rápido.", 1, 
		CardData.CardType.TAIJUTSU, CardData.TargetType.SINGLE_ENEMY, CardData.Rarity.COMMON, "Naruto",
		6, 1, 0, 1, 0, 0, [], "attack")
		
	_add_card("naruto_kick", "Chute Espiral", "Golpe com salto que gera 2 pontos de combo.", 1,
		CardData.CardType.TAIJUTSU, CardData.TargetType.SINGLE_ENEMY, CardData.Rarity.COMMON, "Naruto",
		8, 2, 0, 2, 0, 0, [], "attack_kick")
		
	_add_card("kage_bunshin", "Kage Bunshin no Jutsu", "Invoca clones das sombras. Aplica 8 de Guarda e adiciona +1 carta à mão.", 1,
		CardData.CardType.NINJUTSU, CardData.TargetType.SELF, CardData.Rarity.COMMON, "Naruto",
		0, 0, 8, 1, 0, 1, [], "bunshin")

	_add_card("bunshin_taiatari", "Ataque dos Clones", "Seus clones cercam o oponente desferindo múltiplos golpes.", 2,
		CardData.CardType.TAIJUTSU, CardData.TargetType.SINGLE_ENEMY, CardData.Rarity.UNCOMMON, "Naruto",
		15, 4, 0, 3, 0, 0, [], "bunshin_attack")

	_add_card("naruto_combo", "Combo Uzumaki Naruto!", "Uma saraivada de 5 chutes e socos no ar.", 2,
		CardData.CardType.TAIJUTSU, CardData.TargetType.SINGLE_ENEMY, CardData.Rarity.RARE, "Naruto",
		22, 5, 0, 4, 0, 0, [], "naruto_combo")

	_add_card("rasengan", "Rasengan!", "Condensa o Chakra em uma esfera rotativa devassadora. Ignora metade da guarda inimiga.", 3,
		CardData.CardType.NINJUTSU, CardData.TargetType.SINGLE_ENEMY, CardData.Rarity.RARE, "Naruto",
		32, 1, 0, 2, 0, 0, [{"type": "burn", "value": 3, "target": "enemy"}], "rasengan")

	_add_card("ougi_rasengan", "Ougi: Rasengan das Nove Caudas", "Jutsu Secreto Máximo. Exige QTE de sincronia ninja para devastação total.", 4,
		CardData.CardType.ULTIMATE, CardData.TargetType.SINGLE_ENEMY, CardData.Rarity.LEGENDARY, "Naruto",
		55, 6, 0, 5, 0, 0, [{"type": "burn", "value": 5, "target": "enemy"}], "ougi_rasengan", 4)

	# ==================== SASUKE CARDS ====================
	_add_card("sasuke_slash", "Golpe com Kunai", "Corte veloz com kunai com chance de sangramento.", 1,
		CardData.CardType.TAIJUTSU, CardData.TargetType.SINGLE_ENEMY, CardData.Rarity.COMMON, "Sasuke",
		7, 1, 0, 1, 0, 0, [{"type": "bleed", "value": 2, "target": "enemy"}], "attack")

	_add_card("sharingan_dodge", "Sharingan: Percepção", "Lê os movimentos inimigos. Ganha 10 de Guarda e +1 de Chakra no próximo turno.", 1,
		CardData.CardType.GENJUTSU, CardData.TargetType.SELF, CardData.Rarity.UNCOMMON, "Sasuke",
		0, 0, 10, 1, 1, 0, [], "sharingan")

	_add_card("katon_goukakyuu", "Katon: Jutsu Bola de Fogo", "Dispara uma grande esfera de chamas que queima o oponente.", 2,
		CardData.CardType.NINJUTSU, CardData.TargetType.SINGLE_ENEMY, CardData.Rarity.COMMON, "Sasuke",
		16, 1, 0, 1, 0, 0, [{"type": "burn", "value": 4, "target": "enemy"}], "katon")

	_add_card("katon_housenka", "Katon: Jutsu Flor da Fênix", "Dispara 3 projéteis de fogo intercalados com shurikens.", 2,
		CardData.CardType.NINJUTSU, CardData.TargetType.SINGLE_ENEMY, CardData.Rarity.UNCOMMON, "Sasuke",
		18, 3, 0, 3, 0, 0, [{"type": "burn", "value": 2, "target": "enemy"}], "katon_multi")

	_add_card("chidori", "Chidori: Mil Pássaros", "Ataque relâmpago penetrante de altíssima velocidade.", 3,
		CardData.CardType.NINJUTSU, CardData.TargetType.SINGLE_ENEMY, CardData.Rarity.RARE, "Sasuke",
		34, 1, 0, 2, 0, 0, [{"type": "paralysis", "value": 1, "target": "enemy"}], "chidori")

	_add_card("ougi_chidori", "Ougi: Chidori do Selo Amaldiçoado", "Ativa o primeiro estágio da Marca da Maldição e dispara um Chidori sombrio.", 4,
		CardData.CardType.ULTIMATE, CardData.TargetType.SINGLE_ENEMY, CardData.Rarity.LEGENDARY, "Sasuke",
		60, 4, 0, 5, 0, 0, [{"type": "paralysis", "value": 2, "target": "enemy"}], "ougi_chidori", 4)

	# ==================== ROCK LEE CARDS ====================
	_add_card("konoha_senpuu", "Furacão da Folha", "Chute giratório no ar que quebra a guarda.", 1,
		CardData.CardType.TAIJUTSU, CardData.TargetType.SINGLE_ENEMY, CardData.Rarity.COMMON, "Rock Lee",
		9, 2, 0, 2, 0, 0, [], "leaf_hurricane")

	_add_card("konoha_reppu", "Redemoinho da Folha", "Rasteira rápida que desequilibra o adversário.", 1,
		CardData.CardType.TAIJUTSU, CardData.TargetType.SINGLE_ENEMY, CardData.Rarity.COMMON, "Rock Lee",
		7, 1, 0, 2, 0, 0, [], "leaf_hurricane")

	_add_card("shadow_leaf_dance", "Dança da Folha da Sombra", "Lança o oponente no ar e se posiciona para a finalização.", 2,
		CardData.CardType.TAIJUTSU, CardData.TargetType.SINGLE_ENEMY, CardData.Rarity.UNCOMMON, "Rock Lee",
		16, 3, 0, 3, 0, 1, [], "attack_kick")

	_add_card("omote_renge", "Lótus Primária", "Prende o oponente com ataduras e cai em rotação vertical em direção ao solo.", 2,
		CardData.CardType.TAIJUTSU, CardData.TargetType.SINGLE_ENEMY, CardData.Rarity.RARE, "Rock Lee",
		26, 2, 0, 3, 0, 0, [], "lotus")

	_add_card("ura_renge", "Ougi: Lótus Oculta (5 Portões)", "Abre até o 5º Portão da Vida. Movimentos imperceptíveis e destruição incomparável.", 3,
		CardData.CardType.ULTIMATE, CardData.TargetType.SINGLE_ENEMY, CardData.Rarity.LEGENDARY, "Rock Lee",
		65, 8, 0, 6, 0, 0, [{"type": "gates_open", "value": 3, "target": "self"}], "ougi_ura_renge", 5)

	# ==================== UNIVERSAL & TRAPS & SUPPORTS ====================
	_add_card("kawarimi_trap", "Armadilha: Jutsu de Substituição", "Armadilha virada para baixo: Cancela o próximo ataque inimigo recebido e deixa um tronco.", 1,
		CardData.CardType.TRAP, CardData.TargetType.SELF, CardData.Rarity.UNCOMMON, "Universal",
		0, 0, 0, 0, 0, 0, [], "kawarimi", 0, "on_attacked")

	_add_card("explosive_tag_trap", "Armadilha: Papel Bomba Oculto", "Armadilha virada para baixo: Quando o inimigo ataca, explode causando 14 de dano imediato.", 1,
		CardData.CardType.TRAP, CardData.TargetType.SELF, CardData.Rarity.UNCOMMON, "Universal",
		14, 1, 0, 0, 0, 0, [{"type": "burn", "value": 2, "target": "enemy"}], "explosion", 0, "on_attacked")

	_add_card("chakra_focus", "Concentração de Chakra", "Foca o fluxo de chakra. Ganha +2 de Chakra neste turno e compra 1 carta.", 0,
		CardData.CardType.GENJUTSU, CardData.TargetType.SELF, CardData.Rarity.COMMON, "Universal",
		0, 0, 0, 1, 2, 1, [], "chakra_charge")

	_add_card("iron_guard", "Defesa com Kunai", "Posição defensiva. Ganha 7 de Guarda.", 1,
		CardData.CardType.GENJUTSU, CardData.TargetType.SELF, CardData.Rarity.COMMON, "Universal",
		0, 0, 7, 0, 0, 0, [], "guard")

	_add_card("support_sakura", "Suporte: Sakura Haruno", "Sakura entra no campo para aplicar primeiros socorros: Cura 10 de HP e remove Queimadura/Sangramento.", 1,
		CardData.CardType.SUPPORT, CardData.TargetType.SELF, CardData.Rarity.UNCOMMON, "Universal",
		0, 0, 0, 0, 0, 0, [{"type": "heal", "value": 10, "target": "self"}], "support_sakura", 0, "", "Sakura")

	_add_card("support_kakashi", "Suporte: Kakashi Hatake", "Kakashi surge com Raikiri de suporte: Causa 20 de dano e aplica Paralisia no oponente.", 2,
		CardData.CardType.SUPPORT, CardData.TargetType.SINGLE_ENEMY, CardData.Rarity.RARE, "Universal",
		20, 2, 0, 2, 0, 0, [{"type": "paralysis", "value": 1, "target": "enemy"}], "support_kakashi", 0, "", "Kakashi")

	# ==================== ENEMY SPECIFIC CARDS (GAARA, ZABUZA, HAKU) ====================
	_add_card("gaara_sand_shield", "Escudo de Areia", "A areia protege o corpo automaticamente. Ganha 14 de Guarda.", 1,
		CardData.CardType.NINJUTSU, CardData.TargetType.SELF, CardData.Rarity.COMMON, "Gaara",
		0, 0, 14, 0, 0, 0, [], "sand_shield")

	_add_card("gaara_sand_coffin", "Sabaku Kyuu (Caixão de Areia)", "A areia envolve o inimigo imobilizando-o. Causa 18 de dano e atordoa.", 2,
		CardData.CardType.NINJUTSU, CardData.TargetType.SINGLE_ENEMY, CardData.Rarity.RARE, "Gaara",
		18, 1, 0, 0, 0, 0, [{"type": "stun", "value": 1, "target": "enemy"}], "sand_attack")

	_add_card("zabuza_water_dragon", "Suiton: Dragão de Água", "Cria um imenso dragão aquático que colide causando 24 de dano.", 2,
		CardData.CardType.NINJUTSU, CardData.TargetType.SINGLE_ENEMY, CardData.Rarity.RARE, "Zabuza",
		24, 2, 0, 0, 0, 0, [], "water_dragon")

	_add_card("haku_ice_mirrors", "Espelhos Demoníacos de Gelo", "Haku se move entre os espelhos a velocidade da luz. 6 ataques de agulhas senbon.", 2,
		CardData.CardType.NINJUTSU, CardData.TargetType.SINGLE_ENEMY, CardData.Rarity.RARE, "Haku",
		20, 6, 0, 0, 0, 0, [{"type": "bleed", "value": 3, "target": "enemy"}], "ice_mirrors")

func _add_card(id: String, title: String, desc: String, chakra: int, type: CardData.CardType,
	target: CardData.TargetType, rarity: CardData.Rarity, owner: String,
	dmg: int, hits: int, shield: int, combo: int, chakra_g: int, draw: int,
	status: Array[Dictionary], anim_key: String, qte_diff: int = 3, trap_trig: String = "on_attacked",
	supp_name: String = "") -> void:
	
	var c = CardData.new()
	c.id = id
	c.title = title
	c.description = desc
	c.chakra_cost = chakra
	c.card_type = type
	c.target_type = target
	c.rarity = rarity
	c.character_owner = owner
	c.base_damage = dmg
	c.hit_count = hits
	c.base_shield = shield
	c.combo_points = combo
	c.chakra_gain = chakra_g
	c.draw_cards = draw
	c.status_effects = status
	c.animation_key = anim_key
	c.qte_difficulty = qte_diff
	c.trap_trigger = trap_trig
	c.support_name = supp_name
	
	cards[id] = c

func get_card(id: String) -> CardData:
	if cards.has(id):
		return cards[id]
	return null

func get_random_reward_cards(character_name: String, count: int = 3) -> Array[CardData]:
	var eligible: Array[CardData] = []
	for id in cards:
		var c = cards[id]
		if c.character_owner == character_name or c.character_owner == "Universal":
			eligible.append(c)
	eligible.shuffle()
	return eligible.slice(0, mini(count, eligible.size()))
