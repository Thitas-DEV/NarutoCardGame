extends Node

func _ready():
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
	
	# 2. Verifica Naruto SpriteFrames e novas animações
	var naruto_frames = load('res://data/characters/naruto_frames.tres')
	assert(naruto_frames != null, 'naruto_frames.tres deve carregar')
	assert(naruto_frames.has_animation('chakra_pose_clone'), 'chakra_pose_clone deve existir')
	assert(naruto_frames.get_frame_count('chakra_pose_clone') == 4, 'chakra_pose_clone deve ter 4 frames')
	assert(naruto_frames.has_animation('rasengan_clone_generate'), 'rasengan_clone_generate deve existir')
	assert(naruto_frames.get_frame_count('rasengan_clone_generate') == 2, 'rasengan_clone_generate deve ter 2 frames')
	assert(naruto_frames.has_animation('naruto_holding_rasengan'), 'naruto_holding_rasengan deve existir')
	assert(naruto_frames.get_frame_count('naruto_holding_rasengan') == 4, 'naruto_holding_rasengan deve ter 4 frames')
	assert(naruto_frames.has_animation('naruto_attack_rasengan'), 'naruto_attack_rasengan deve existir')
	assert(naruto_frames.get_frame_count('naruto_attack_rasengan') == 9, 'naruto_attack_rasengan deve ter 9 frames')
	print('[PASS] Todas as 4 novas animacoes do Naruto estao presentes no SpriteFrames')
	
	# 3. Verifica VFX SpriteFrames
	var smoke_vfx = load('res://data/vfx/clone_smoke_frames.tres')
	assert(smoke_vfx != null and smoke_vfx.get_frame_count('default') == 7, 'clone_smoke_frames deve ter 7 frames')
	var running_vfx = load('res://data/vfx/rasengan_running_frames.tres')
	assert(running_vfx != null and running_vfx.get_frame_count('default') == 3, 'rasengan_running_frames deve ter 3 frames')
	var explode_vfx = load('res://data/vfx/rasengan_explode_frames.tres')
	assert(explode_vfx != null and explode_vfx.get_frame_count('default') == 5, 'rasengan_explode_frames deve ter 5 frames')
	print('[PASS] Todos os 3 arquivos de VFX SpriteFrames possuem as contagens exatas de frames')
	
	# 4. Verifica Naruto
	var naruto = load('res://data/characters/naruto.tres')
	assert(naruto != null, 'Naruto deve carregar com sucesso')
	var has_kb = false
	for ability in naruto.starting_deck:
		if ability.id == 'kagebunshin':
			has_kb = true
			break
	assert(has_kb, 'Starting deck do Naruto deve conter Kage Bunshin')
	print('[PASS] Naruto possui Kage Bunshin no starting deck')
	
	# 5. Testa logica de BattleField
	var bf_scene = load('res://src/battle/BattleField.tscn')
	assert(bf_scene != null, 'BattleField.tscn deve carregar com sucesso')
	var bf = bf_scene.instantiate()
	add_child(bf)
	
	assert(not bf.has_player_clone(), 'Inicialmente nao deve haver clone')
	print('[PASS] Estado inicial sem clone')
	
	# Invocacao de clone
	bf.summon_clone(true)
	assert(bf.has_player_clone(), 'Clone do jogador deve existir apos invocacao')
	assert(bf.player_clone_visual.is_clone == true, 'Clone visual deve ter flag is_clone == true')
	assert(bf.player_clone_visual.smoke_overlay != null, 'Clone deve possuir smoke_overlay')
	print('[PASS] Clone invocado com sucesso e possui SmokeOverlay')
	
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
	get_tree().quit(0)
