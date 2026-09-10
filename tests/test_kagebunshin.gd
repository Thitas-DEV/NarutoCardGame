extends SceneTree

func _init():
	print('=== INICIANDO TESTES DO KAGE BUNSHIN E RASENGAN ===')
	
	# 1. Verifica dados de cartas
	var rasengan = load('res://data/abilities/rasengan.tres')
	assert(rasengan != null, 'Rasengan deve carregar com sucesso')
	assert(rasengan.requires_clone == true, 'Rasengan deve ter requires_clone == true')
	print('[PASS] Rasengan requires_clone == true')
	
	var ougi = load('res://data/abilities/ougi_rasengan.tres')
	assert(ougi != null, 'Ougi Rasengan deve carregar com sucesso')
	assert(ougi.requires_clone == true, 'Ougi Rasengan deve ter requires_clone == true')
	print('[PASS] Ougi Rasengan requires_clone == true')
	
	var kb = load('res://data/abilities/kagebunshin.tres')
	assert(kb != null, 'Kage Bunshin deve carregar com sucesso')
	assert(kb.requires_clone == false, 'Kage Bunshin nao requer clone')
	assert(kb.scripts.size() > 0, 'Kage Bunshin deve ter script de invocacao')
	assert(kb.scripts[0].get('effect') == 'summon_clone', 'Efeito deve ser summon_clone')
	print('[PASS] Kage Bunshin configurado corretamente')
	
	# 2. Verifica Naruto
	var naruto = load('res://data/characters/naruto.tres')
	assert(naruto != null, 'Naruto deve carregar com sucesso')
	var has_kb = false
	for ability in naruto.starting_deck:
		if ability.id == 'kagebunshin':
			has_kb = true
			break
	assert(has_kb, 'Starting deck do Naruto deve conter Kage Bunshin')
	print('[PASS] Naruto possui Kage Bunshin no starting deck')
	
	# 3. Testa logica de BattleField
	var bf_scene = load('res://src/battle/BattleField.tscn')
	assert(bf_scene != null, 'BattleField.tscn deve carregar com sucesso')
	var bf = bf_scene.instantiate()
	root.add_child(bf)
	
	assert(not bf.has_player_clone(), 'Inicialmente nao deve haver clone')
	print('[PASS] Estado inicial sem clone')
	
	# Invocacao de clone
	bf.summon_clone(true)
	assert(bf.has_player_clone(), 'Clone do jogador deve existir apos invocacao')
	assert(bf.player_clone_visual.is_clone == true, 'Clone visual deve ter flag is_clone == true')
	print('[PASS] Clone invocado com sucesso')
	
	# Limite de 1 clone
	var first_clone = bf.player_clone_visual
	bf.summon_clone(true)
	assert(bf.player_clone_visual == first_clone, 'Nao deve permitir criar um segundo clone simultaneo')
	print('[PASS] Limite maximo de 1 clone respeitado')
	
	# Intercepcao de dano
	var initial_hp = bf.player_data.current_hp
	bf._damage_character(bf.player_data, bf.player_visual, 30, true)
	assert(bf.player_data.current_hp == initial_hp, 'Naruto nao deve tomar dano quando clone intercepta')
	assert(not bf.has_player_clone(), 'Clone deve morrer e desvanecer apos interceptar o golpe')
	print('[PASS] Clone interceptou ataque com sucesso e original tomou 0 de dano')
	
	print('=== TODOS OS TESTES PASSARAM COM SUCESSO! ===')
	quit(0)
