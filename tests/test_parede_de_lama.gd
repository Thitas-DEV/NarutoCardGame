extends Node

func _ready() -> void:
	print("=== INICIANDO TESTE DA PAREDE DE LAMA COMO ARMADILHA DEFENSIVA ===")
	
	# 1. Teste de Configuração da Carta como TRAP
	var doton_card = load("res://data/abilities/doton_wall.tres")
	assert(doton_card != null, "doton_wall.tres deve carregar")
	assert(doton_card.ability_type == AbilityData.AbilityType.TRAP, "doton_wall deve ser do tipo TRAP")
	print("[PASS] doton_wall configurada como carta de ARMADILHA (TRAP)")
	
	# 2. Teste de Inicialização com Kakashi no BattleField
	GameManager.select_hero("kakashi")
	var bf_scene = load("res://src/battle/BattleField.tscn")
	var bf = bf_scene.instantiate()
	add_child(bf)
	
	assert(bf.player_data.id == "kakashi", "Heroi selecionado deve ser Kakashi")
	assert(bf.active_trap_card == null, "Nenhuma armadilha ativa inicialmente")
	print("[PASS] Kakashi instanciado no BattleField sem armadilhas ativas")
	
	# Garante chakra de Terra para a armadilha
	bf.player_chakra_pool[ChakraElement.Type.EARTH] = 2
	
	# 3. Teste de Armação da Armadilha
	var card_ui_scene = load("res://src/battle/CardUI.tscn")
	var card_ui = card_ui_scene.instantiate()
	bf.hand_container.add_child(card_ui)
	card_ui.set_card_data(doton_card)
	
	bf._on_card_played(doton_card, card_ui)
	assert(bf.active_trap_card == doton_card, "active_trap_card deve ser doton_wall")
	assert(bf.trap_slot.visible == true, "trap_slot na UI deve estar visivel")
	assert("PAREDE DE LAMA" in bf.trap_label.text, "trap_label deve exibir PAREDE DE LAMA")
	print("[PASS] Armadilha da Parede de Lama armada no slot com sucesso")
	
	# 4. Teste de Ataque Inimigo Bloqueado pela Parede de Lama
	var initial_hp = bf.player_data.current_hp
	print("HP do Kakashi antes do ataque: %d" % initial_hp)
	
	# Simula golpe inimigo de 30 de dano direto
	bf._damage_character(bf.player_data, bf.player_visual, 30, true)
	
	# Verifica que a armadilha foi gasta/consumida
	assert(bf.active_trap_card == null, "Armadilha deve ter sido consumida pelo ataque")
	assert(bf.trap_slot.visible == false, "trap_slot deve sumir da UI apos ser gasta")
	
	# Verifica que NAO causou dano
	assert(bf.player_data.current_hp == initial_hp, "Kakashi NAO deve ter sofrido dano (HP deve permanecer %d)" % initial_hp)
	print("[PASS] Golpe inimigo de 30 de dano completamente absorvido (0 de dano sofrido)")
	
	# Verifica que NAO executou a animacao damage
	assert(bf.player_visual.animated_sprite.animation != "damage", "Kakashi NAO deve executar a animacao damage ao bloquear com a parede")
	print("[PASS] Animacao 'damage' nao foi executada")
	
	# Verifica que a Parede de Lama animada surgiu no solo
	var vfx = bf.get_node("Arena2D/BattleVFX")
	var wall_node: AnimatedSprite2D = null
	var frames = load("res://data/vfx/parede_de_lama_frames.tres")
	for child in vfx.get_children():
		if child is AnimatedSprite2D and child.sprite_frames == frames:
			wall_node = child
			break
			
	assert(wall_node != null, "A Parede de Lama animada deve ter emergido do solo no BattleVFX")
	assert(wall_node.visible == true, "A Parede de Lama deve estar visivel")
	print("[PASS] Parede de Lama emergiu do solo no momento exato do impacto")
	
	# Aguarda evolucao da parede (rise -> idle)
	await get_tree().create_timer(0.6).timeout
	assert(wall_node.animation == "idle" or wall_node.animation == "rise", "Parede deve estar ereta")
	print("[PASS] Muralha de pedra permaneceu erguida absorvendo o golpe")
	
	print("=== TODOS OS TESTES DA PAREDE DE LAMA COMO ARMADILHA PASSARAM COM 100% SUCESSO! ===")
	get_tree().quit(0)