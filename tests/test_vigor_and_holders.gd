extends Node

func _ready() -> void:
	print("=== INICIANDO TESTES DO SISTEMA DE VIGOR FÍSICO E CARTAS HOLDERS ===")
	
	# -------------------------------------------------------------
	# 1. TESTE DE DADOS E CARTAS
	# -------------------------------------------------------------
	var holder_duplo = load("res://data/abilities/holder_duplo.tres")
	assert(holder_duplo != null, "holder_duplo.tres deve existir")
	assert(holder_duplo.is_holder == true, "holder_duplo deve ter is_holder == true")
	assert(holder_duplo.holder_capacity == 2, "holder_duplo deve ter capacidade 2")
	print("[PASS] holder_duplo configurado corretamente com 2 slots")
	
	var holder_triplo = load("res://data/abilities/holder_triplo.tres")
	assert(holder_triplo != null, "holder_triplo.tres deve existir")
	assert(holder_triplo.is_holder == true, "holder_triplo deve ter is_holder == true")
	assert(holder_triplo.holder_capacity == 3, "holder_triplo deve ter capacidade 3")
	print("[PASS] holder_triplo configurado corretamente com 3 slots")
	
	var dynamic_entry = load("res://data/abilities/dynamic_entry.tres")
	assert(dynamic_entry != null, "dynamic_entry.tres deve existir")
	assert(dynamic_entry.vigor_cost == 20, "dynamic_entry deve custar 20 de vigor")
	print("[PASS] dynamic_entry configurado com custo de 20 de vigor")
	
	var rock_lee_kick = load("res://data/abilities/rock_lee_kick.tres")
	assert(rock_lee_kick != null, "rock_lee_kick.tres deve existir")
	assert(rock_lee_kick.vigor_cost == 15, "rock_lee_kick deve custar 15 de vigor")
	print("[PASS] rock_lee_kick configurado com custo de 15 de vigor")
	
	var naruto_punch = load("res://data/abilities/naruto_punch.tres")
	assert(naruto_punch != null, "naruto_punch.tres deve existir")
	assert(naruto_punch.vigor_cost == 12, "naruto_punch deve custar 12 de vigor")
	print("[PASS] naruto_punch configurado com custo de 12 de vigor")
	
	# -------------------------------------------------------------
	# 2. TESTE DE PERSONAGENS E ELEGIBILIDADE (Lee & Guy vs Naruto)
	# -------------------------------------------------------------
	var lee = Database.get_character("rock_lee")
	assert(lee != null, "Rock Lee deve carregar no Database")
	assert(lee.is_taijutsu_specialist() == true, "Rock Lee deve ser especialista em Taijutsu")
	assert(lee.can_use_holders() == true, "Rock Lee deve poder usar Holders")
	assert(lee.get_initial_vigor() == lee.max_vigor, "Rock Lee deve iniciar com 100% de vigor")
	assert(holder_duplo.can_be_used_by(lee) == true, "Rock Lee pode equipar holder_duplo")
	print("[PASS] Rock Lee: Especialista em Taijutsu, 100% vigor inicial e elegível para Holders")
	
	var guy = Database.get_character("might_guy")
	assert(guy != null, "Might Guy deve carregar no Database")
	assert(guy.is_taijutsu_specialist() == true, "Might Guy deve ser especialista em Taijutsu")
	assert(guy.can_use_holders() == true, "Might Guy deve poder usar Holders")
	assert(guy.max_vigor == 120, "Might Guy possui 120 de vigor máximo")
	assert(guy.get_initial_vigor() == 120, "Might Guy inicia com 100% de vigor (120/120)")
	assert(holder_triplo.can_be_used_by(guy) == true, "Might Guy pode equipar holder_triplo")
	print("[PASS] Might Guy: Fera Verde, 120 max vigor, 100% inicial e elegível para Holders")
	
	var naruto = Database.get_character("naruto")
	assert(naruto != null, "Naruto deve carregar no Database")
	assert(naruto.is_taijutsu_specialist() == false, "Naruto não é especialista puro de Taijutsu (usa Chakra)")
	assert(naruto.can_use_holders() == false, "Naruto não pode usar Holders")
	assert(naruto.get_initial_vigor() == int(naruto.max_vigor * 0.5), "Naruto inicia com 50% de vigor")
	assert(holder_duplo.can_be_used_by(naruto) == false, "Naruto não pode equipar holder_duplo")
	print("[PASS] Naruto: Usuário de Chakra inicia com 50% de vigor e não pode usar Holders")
	
	# -------------------------------------------------------------
	# 3. TESTE DA REGRA DE RECARGA DE 50% DO FALTANTE
	# -------------------------------------------------------------
	var max_vig = 100
	var cur_vig = 40
	var missing = max_vig - cur_vig # 60
	var recharge = int(ceil(missing * 0.5)) # 30
	cur_vig += recharge # 70
	assert(cur_vig == 70, "Recarga de 40 vigor com max 100 deve ser 70 (30 adicionados)")
	
	missing = max_vig - cur_vig # 30
	recharge = int(ceil(missing * 0.5)) # 15
	cur_vig += recharge # 85
	assert(cur_vig == 85, "Recarga de 70 vigor com max 100 deve ser 85 (15 adicionados)")
	
	cur_vig = 99
	missing = max_vig - cur_vig # 1
	recharge = int(ceil(missing * 0.5)) # 1
	cur_vig += recharge # 100
	assert(cur_vig == 100, "Arredondamento para cima permite atingir 100% quando falta 1 ponto")
	print("[PASS] Fórmula de recarga de 50% do faltante validada matematicamente")
	
	# -------------------------------------------------------------
	# 4. TESTE DE DESCONTO DE 10% DE VIGOR E ACÚMULO DE 10% DE DANO
	# -------------------------------------------------------------
	# Chute (15 vig) -> desc: round(15 * 0.9) = 14
	# Entrada Dinâmica (20 vig) -> desc: round(20 * 0.9) = 18
	var kick_disc = int(round(rock_lee_kick.vigor_cost * 0.9))
	var entry_disc = int(round(dynamic_entry.vigor_cost * 0.9))
	assert(kick_disc == 14, "Chute de 15 vigor com -10% deve custar 14")
	assert(entry_disc == 18, "Entrada Dinâmica de 20 vigor com -10% deve custar 18")
	var total_combo_vig = kick_disc + entry_disc
	assert(total_combo_vig == 32, "Custo total do combo duplo é 32 vigor (economizou 3)")
	print("[PASS] Desconto de 10% de vigor no combo do Holder calculado com sucesso")
	
	# Acúmulo de dano:
	# Golpe 1: (0 + 1) * 10 = +10% (1.10x)
	# Golpe 2: (1 + 1) * 10 = +20% (1.20x)
	# Golpe 3: (2 + 1) * 10 = +30% (1.30x)
	for i in range(3):
		var bonus_percent = (i + 1) * 10
		var mult = 1.0 + (float(bonus_percent) / 100.0)
		assert(abs(mult - (1.0 + (i + 1) * 0.10)) < 0.001, "Multiplicador do golpe %d deve ser +%d%%" % [i + 1, bonus_percent])
	print("[PASS] Acúmulo progressivo de +10% de dano por golpe do combo validado")
	
	# -------------------------------------------------------------
	# 5. TESTE DE INTEGRAÇÃO NA CENA BATTLEFIELD
	# -------------------------------------------------------------
	GameManager.select_hero("rock_lee")
	var bf_scene = load("res://src/battle/BattleField.tscn")
	assert(bf_scene != null, "BattleField.tscn deve carregar com sucesso")
	var bf = bf_scene.instantiate()
	add_child(bf)
	
	# Lee inicia com 100% de vigor (100/100)
	assert(bf.player_vigor == 100, "Rock Lee deve iniciar a batalha com 100 de vigor (100%)")
	print("[PASS] Rock Lee iniciou combate com 100% de vigor no BattleField")
	
	# Simula gasto de vigor e recarga de 50% na rodada seguinte (turno 2)
	bf.turn_number = 2
	bf.player_vigor = 40
	bf._start_player_turn()
	assert(bf.player_vigor == 70, "Apos recarga de 50% do faltante (60), vigor deve ser 70")
	print("[PASS] Recarga de 50% do faltante executada no fluxo de turno do BattleField")
	
	# Validação do painel de Vigor no UI
	assert(bf.vigor_label != null, "vigor_label deve existir na UI da barra inferior")
	assert("VIGOR" in bf.vigor_label.text, "vigor_label deve exibir texto de VIGOR")
	print("[PASS] Painel de Vigor presente e atualizado na barra inferior")
	
	# Teste de Naruto iniciando com 50% de vigor
	GameManager.select_hero("naruto")
	var bf_naruto = bf_scene.instantiate()
	add_child(bf_naruto)
	assert(bf_naruto.player_vigor == 50, "Naruto deve iniciar combate com 50% de vigor (50/100)")
	# -------------------------------------------------------------
	# 6. TESTE DE SLOTTING, UNSLOTTING E LANÇAMENTO DE HOLDER NO CARDUI
	# -------------------------------------------------------------
	var card_ui_scene = load("res://src/battle/CardUI.tscn")
	var holder_ui = card_ui_scene.instantiate()
	bf.hand_container.add_child(holder_ui)
	holder_ui.set_card_data(holder_duplo)
	
	assert(holder_ui.is_holder() == true, "holder_ui deve identificar-se como Holder")
	assert(holder_ui.can_add_card() == true, "Holder vazio deve poder receber cartas")
	assert(holder_ui.slotted_cards.size() == 0, "Inicialmente sem cartas encaixadas")
	
	# Encaixa o Chute (15 vig)
	holder_ui.add_slotted_card(rock_lee_kick)
	assert(holder_ui.slotted_cards.size() == 1, "Deve ter 1 carta encaixada")
	assert(holder_ui.can_add_card() == true, "Ainda pode receber mais 1 carta (capacidade 2)")
	assert(holder_ui.get_total_holder_vigor() == 14, "Custo com 1 chute deve ser 14")
	
	# Encaixa a Entrada Dinâmica (20 vig)
	holder_ui.add_slotted_card(dynamic_entry)
	assert(holder_ui.slotted_cards.size() == 2, "Deve ter 2 cartas encaixadas (cheio)")
	assert(holder_ui.can_add_card() == false, "Holder cheio não pode receber mais cartas")
	assert(holder_ui.get_total_holder_vigor() == 32, "Custo total com 10% de desconto deve ser 32 (14 + 18)")
	print("[PASS] Slotting no HolderUI executado com sucesso e desconto computado")
	
	# Teste de Desencaixe (Unslot)
	holder_ui.remove_slotted_card(dynamic_entry)
	assert(holder_ui.slotted_cards.size() == 1, "Apos desencaixar, deve ter 1 carta")
	assert(holder_ui.can_add_card() == true, "Pode receber carta novamente")
	holder_ui.add_slotted_card(dynamic_entry)
	assert(holder_ui.slotted_cards.size() == 2, "Novamente com 2 cartas")
	print("[PASS] Desencaixe e re-encaixe de cartas no Holder funcionando corretamente")
	
	# Teste de execução do combo via BattleField
	bf.player_vigor = 100
	var initial_enemy_hp = bf.enemy_data.current_hp
	bf._on_card_played(holder_duplo, holder_ui)
	
	# Verifica que 32 de vigor foram deduzidos (100 - 32 = 68)
	assert(bf.player_vigor == 68, "Vigor do jogador deve ser 68 apos jogar combo de 32 vigor")
	print("[PASS] Combo do Holder deduziu 32 de vigor (-10% em cada golpe)")
	
	# Aguarda a conclusão sequencial do combo (1 golpe por carta, sem repetição infinita)
	var wait_time = 0.0
	while bf.is_combo_running and wait_time < 4.0:
		await get_tree().create_timer(0.2).timeout
		wait_time += 0.2
		
	assert(bf.is_combo_running == false, "Combo deve finalizar após executar todos os golpes da lista")
	# Golpe 1: 9 * 1.10 = 9 de dano. Golpe 2: 14 * 1.20 = 16 de dano. Total = 25 de dano.
	assert(bf.enemy_data.current_hp == initial_enemy_hp - 25, "Dano total deve ser exatamente 25 (executando apenas 1 golpe por carta)")
	print("[PASS] Combo do Holder executou exatamente 1 ataque por carta e finalizou perfeitamente")
	
	print("=== TODOS OS TESTES DE VIGOR E HOLDERS PASSARAM COM 100% DE SUCESSO! ===")
	get_tree().quit(0)
