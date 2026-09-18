# res://tests/test_story_campaign.gd
extends SceneTree

func _init() -> void:
	print('--- INICIANDO TESTES DO MODO HISTÓRIA ---')
	
	var db_script = load('res://src/autoload/Database.gd')
	var db = Node.new()
	db.set_script(db_script)
	root.add_child(db)
	
	db._ready()
	
	var all_worlds = StoryCampaignData.get_all_worlds()
	assert(all_worlds.size() == 4, 'Devem existir 4 mundos!')
	print('✓ 4 Mundos carregados com sucesso.')
	
	var flat_stages = StoryCampaignData.get_all_stages_flat()
	assert(flat_stages.size() == 24, 'Devem existir 24 fases!')
	print('✓ 24 Fases carregadas com sucesso.')
	
	var all_hero_ids: Dictionary = {}
	var all_enemy_ids: Dictionary = {}
	
	for s in flat_stages:
		for h_id in s.hero_options:
			all_hero_ids[h_id] = true
			var hero_char = db.get_character(h_id)
			assert(hero_char != null, 'Herói ' + h_id + ' na fase ' + s.id + ' não encontrado no Database!')
			assert(hero_char.starting_deck.size() > 0, 'Herói ' + h_id + ' não tem starting_deck!')
			
		var enemy_id = s.enemy_id
		all_enemy_ids[enemy_id] = true
		var enemy_char = db.get_character(enemy_id)
		assert(enemy_char != null, 'Inimigo ' + enemy_id + ' na fase ' + s.id + ' não encontrado no Database!')
		assert(enemy_char.starting_deck.size() > 0, 'Inimigo ' + enemy_id + ' não tem starting_deck!')
	
	print('✓ Todos os heróis (' + str(all_hero_ids.size()) + ') e inimigos (' + str(all_enemy_ids.size()) + ') das 24 fases estão válidos com deck no Database!')
	
	var stage_4_6 = StoryCampaignData.get_stage_by_id('stage_4_6')
	assert(stage_4_6 != null, 'Fase 4.6 deve existir')
	var enemy_for_naruto = StoryCampaignData.resolve_enemy_id(stage_4_6, 'naruto')
	var enemy_for_sasuke = StoryCampaignData.resolve_enemy_id(stage_4_6, 'sasuke')
	assert(enemy_for_naruto == 'sasuke', 'Se Naruto for escolhido, oponente deve ser Sasuke!')
	assert(enemy_for_sasuke == 'naruto', 'Se Sasuke for escolhido, oponente deve ser Naruto!')
	print('✓ Resolução dinâmica da fase 4.6 validada (Naruto vs Sasuke).')
	
	var completed: Array[String] = []
	assert(StoryCampaignData.is_stage_unlocked('stage_1_0', completed) == true, '1.0 deve estar desbloqueada inicialmente')
	assert(StoryCampaignData.is_stage_unlocked('stage_1_1', completed) == false, '1.1 deve estar bloqueada inicialmente')
	
	completed.append('stage_1_0')
	assert(StoryCampaignData.is_stage_unlocked('stage_1_1', completed) == true, '1.1 deve desbloquear após 1.0')
	
	print('✓ Lógica de desbloqueio de fases validada.')
	print('=== TODOS OS TESTES DO MODO HISTÓRIA PASSARAM COM SUCESSO ===')
	quit(0)
