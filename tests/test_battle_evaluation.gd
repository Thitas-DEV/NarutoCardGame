# res://tests/test_battle_evaluation.gd
extends Node

func _ready() -> void:
	print("=== INICIANDO TESTES DA TELA DE AVALIACAO E DESBLOQUEIOS ROGUELIKE ===")
	
	# 1. Limpa histórico para ambiente de teste limpo
	GameManager.roguelike_unlocked_characters.clear()
	GameManager.heroes_played_history.clear()
	GameManager.enemies_defeated_history.clear()
	GameManager.last_battle_stats.clear()
	
	# 2. Configura primeira batalha: Naruto vs Mizuki
	var naruto = Database.get_character("naruto")
	var mizuki = Database.get_character("mizuki")
	assert(naruto != null, "Naruto deve existir no Database")
	assert(mizuki != null, "Mizuki deve existir no Database")
	
	GameManager.active_hero = naruto
	GameManager.active_enemy_data = mizuki
	GameManager.active_stage_data = {
		"id": "stage_1_0",
		"number": "1.0",
		"title": "Naruto e Iruka vs Mizuki"
	}
	
	# 3. Registra 1ª vitória (120 dano causado, 15 sofrido, 3 turnos)
	var stats1 = GameManager.record_battle_result(120, 15, 3)
	assert(stats1["damage_dealt"] == 120, "Dano causado deve ser 120")
	assert(stats1["damage_taken"] == 15, "Dano sofrido deve ser 15")
	assert(stats1["turns_count"] == 3, "Turnos deve ser 3")
	
	var newly1 = stats1["newly_unlocked"]
	assert(newly1.size() == 2, "Devem haver 2 desbloqueios no Rogue Like (Naruto e Mizuki), atual: %d" % newly1.size())
	assert(GameManager.roguelike_unlocked_characters.has("naruto"), "Naruto deve estar nos desbloqueados de Rogue Like")
	assert(GameManager.roguelike_unlocked_characters.has("mizuki"), "Mizuki deve estar nos desbloqueados de Rogue Like")
	print("✓ 1ª Batalha gerou 2 desbloqueios para Rogue Like com sucesso (Herói Naruto + Oponente Mizuki)")
	
	# 4. Registra 2ª vitória com os mesmos participantes (repetição da fase)
	var stats2 = GameManager.record_battle_result(85, 30, 4)
	var newly2 = stats2["newly_unlocked"]
	assert(newly2.is_empty(), "Segunda batalha com mesmos ninjas NÃO deve gerar novos desbloqueios, atual: %d" % newly2.size())
	assert(GameManager.roguelike_unlocked_characters.size() == 2, "Tamanho de desbloqueados deve permanecer 2")
	print("✓ 2ª Batalha com mesmos participantes não gerou falsos novos desbloqueios")
	
	# 5. Registra 3ª batalha com novo herói (Iruka vs Mizuki)
	var iruka = Database.get_character("iruka")
	assert(iruka != null, "Iruka deve existir no Database")
	GameManager.active_hero = iruka
	GameManager.active_enemy_data = mizuki
	
	var stats3 = GameManager.record_battle_result(90, 0, 2)
	var newly3 = stats3["newly_unlocked"]
	assert(newly3.size() == 1, "Apenas Iruka deve ser desbloqueado (Mizuki já foi derrotado antes), atual: %d" % newly3.size())
	assert(newly3[0]["id"] == "iruka", "ID do recém desbloqueado deve ser iruka")
	assert(GameManager.roguelike_unlocked_characters.has("iruka"), "Iruka deve estar agora em roguelike_unlocked_characters")
	assert(GameManager.roguelike_unlocked_characters.size() == 3, "Total de 3 ninjas desbloqueados (naruto, mizuki, iruka)")
	print("✓ 3ª Batalha com Iruka desbloqueou apenas Iruka com precisão")
	
	# 6. Teste de Renderização da Cena BattleEvaluationScreen
	var eval_scene = load("res://src/ui/BattleEvaluationScreen.tscn")
	assert(eval_scene != null, "BattleEvaluationScreen.tscn deve carregar com sucesso")
	var eval_instance = eval_scene.instantiate()
	add_child(eval_instance)
	
	# Valida labels e dados populados na UI
	assert(eval_instance.damage_dealt_label.text == "90", "UI deve exibir 90 de dano causado, atual: " + eval_instance.damage_dealt_label.text)
	assert(eval_instance.damage_taken_label.text == "0", "UI deve exibir 0 de dano sofrido, atual: " + eval_instance.damage_taken_label.text)
	assert(eval_instance.turns_label.text == "2 Turnos", "UI deve exibir 2 Turnos, atual: " + eval_instance.turns_label.text)
	assert(eval_instance.rank_letter_label.text == "S+", "Com 0 dano sofrido, rank deve ser S+, atual: " + eval_instance.rank_letter_label.text)
	assert(eval_instance.hero_name_label.text == "Iruka Umino", "Nome do herói na UI deve ser Iruka Umino, atual: " + eval_instance.hero_name_label.text)
	assert(eval_instance.enemy_name_label.text == "Mizuki", "Nome do oponente na UI deve ser Mizuki, atual: " + eval_instance.enemy_name_label.text)
	assert(eval_instance.unlock_section.visible == true, "Seção de desbloqueio deve estar visível")
	assert(eval_instance.unlock_cards_container.get_child_count() == 1, "Deve exibir 1 card de desbloqueio do Iruka")
	
	# Valida Background de nuvens e pergaminho estilo Storm 4
	var bg_clouds = eval_instance.get_node_or_null("CloudsBackground") as TextureRect
	assert(bg_clouds != null and bg_clouds.texture != null, "CloudsBackground deve ter textura de clouds.png carregada")
	var scroll_frame = eval_instance.get_node_or_null("ScrollFrame") as TextureRect
	assert(scroll_frame != null and scroll_frame.texture != null, "ScrollFrame deve ter textura de pergaminho ninja carregada")
	
	# Valida que o card de desbloqueio possui CharacterVisual em IDLE
	var card_node = eval_instance.unlock_cards_container.get_child(0)
	var char_vis = card_node.find_child("CharacterVisual", true, false)
	assert(char_vis != null, "Card de desbloqueio deve conter o nó CharacterVisual")
	assert(char_vis.animated_sprite.animation == "idle", "CharacterVisual do ninja desbloqueado deve estar tocando a animacao 'idle', atual: " + char_vis.animated_sprite.animation)
	print("✓ Background de nuvens, moldura de pergaminho e sprite em IDLE validados com perfeição")
	print("✓ BattleEvaluationScreen instanciada e todos os dados de UI validados com perfeição")
	
	# 7. Teste de contagem de dano no BattleField
	var bf_scene = load("res://src/battle/BattleField.tscn")
	assert(bf_scene != null, "BattleField.tscn deve existir")
	var bf = bf_scene.instantiate()
	add_child(bf)
	
	assert(bf.battle_damage_dealt == 0, "Dano inicial causado deve ser 0")
	assert(bf.battle_damage_taken == 0, "Dano inicial sofrido deve ser 0")
	
	# Causa dano no inimigo
	bf._damage_character(bf.enemy_data, bf.enemy_visual, 40, false)
	assert(bf.battle_damage_dealt == 40, "Dano causado no inimigo deve ser 40, atual: %d" % bf.battle_damage_dealt)
	assert(bf.battle_damage_taken == 0, "Dano tomado pelo jogador deve continuar 0")
	
	# Causa dano no jogador
	bf._damage_character(bf.player_data, bf.player_visual, 25, true)
	assert(bf.battle_damage_taken == 25, "Dano tomado pelo jogador deve ser 25, atual: %d" % bf.battle_damage_taken)
	assert(bf.battle_damage_dealt == 40, "Dano causado deve continuar 40")
	print("✓ Rastreamento de battle_damage_dealt e battle_damage_taken no BattleField validado")
	
	print("=== TODOS OS TESTES DA TELA DE AVALIACAO E ROGUELIKE PASSARAM COM SUCESSO ===")
	get_tree().quit(0)
