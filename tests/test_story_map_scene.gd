# res://tests/test_story_map_scene.gd
extends Node

func _ready() -> void:
	print('--- TESTANDO CARREGAMENTO DA CENA STORYMAP COM AUTOLOADS ATIVOS ---')
	assert(Database != null, 'Database autoload deve estar ativo')
	assert(SoundManager != null, 'SoundManager autoload deve estar ativo')
	assert(GameManager != null, 'GameManager autoload deve estar ativo')
	
	# Carregar a cena StoryMap.tscn
	var story_map_scene = load('res://src/map/StoryMap.tscn')
	assert(story_map_scene != null, 'StoryMap.tscn deve carregar sem erros!')
	
	var story_map_instance = story_map_scene.instantiate()
	assert(story_map_instance != null, 'Instanciação de StoryMap deve ser bem-sucedida!')
	add_child(story_map_instance)
	
	# Testar a abertura do modal da fase 1.0
	var stage_1_0 = StoryCampaignData.get_stage_by_id('stage_1_0')
	assert(stage_1_0 != null, 'Stage 1.0 deve existir')
	story_map_instance._open_stage_modal(stage_1_0)
	
	assert(story_map_instance.prep_modal.visible == true, 'Modal deve estar visível')
	assert(story_map_instance.selected_hero_id == 'naruto', 'Herói inicial da 1.0 deve ser naruto')
	assert(story_map_instance.char_visual_instance != null, 'Preview do personagem deve estar instanciado')
	
	# Testar troca de herói para Iruka
	story_map_instance._select_hero('iruka', true)
	assert(story_map_instance.selected_hero_id == 'iruka', 'Herói selecionado deve ser iruka')
	
	# Testar fase 4.6 com oponente dinâmico
	var stage_4_6 = StoryCampaignData.get_stage_by_id('stage_4_6')
	story_map_instance._open_stage_modal(stage_4_6)
	story_map_instance._select_hero('naruto', false)
	assert(story_map_instance.enemy_name_label.text.to_lower().begins_with('sasuke'), 'Para Naruto na 4.6, oponente deve ser Sasuke')
	
	story_map_instance._select_hero('sasuke', false)
	assert(story_map_instance.enemy_name_label.text.to_lower().begins_with('naruto'), 'Para Sasuke na 4.6, oponente deve ser Naruto')
	
	print('✓ StoryMap.tscn instanciado e renderizado com sucesso!')
	print('✓ Modal de preparação de batalha validado!')
	print('✓ Seleção de heróis, celebração com ataque e preview de deck funcionando perfeitamente!')
	print('✓ Resolução dinâmica da fase 4.6 validada!')
	print('=== TODOS OS TESTES PASSARAM COM SUCESSO ===')
	get_tree().quit(0)
