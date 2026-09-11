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
	
	# Intercepcao de dano com clone
	var initial_hp = bf.player_data.current_hp
	bf._damage_character(bf.player_data, bf.player_visual, 30, true)
	assert(bf.player_data.current_hp == initial_hp, 'Naruto nao deve tomar dano quando clone intercepta')
	assert(not bf.has_player_clone(), 'Clone deve morrer e desvanecer apos interceptar o golpe')
	print('[PASS] Clone interceptou ataque com sucesso e original tomou 0 de dano')
	
	# 6. Verifica carta iron_guard e animação kunai_defense
	var iron_guard = load('res://data/abilities/iron_guard.tres')
	assert(iron_guard != null, 'iron_guard.tres deve carregar com sucesso')
	assert(iron_guard.animation_key == 'kunai_defense', 'iron_guard deve ter animation_key == "kunai_defense"')
	print('[PASS] iron_guard animation_key == "kunai_defense"')
	
	assert(naruto_frames.has_animation('kunai_defense'), 'naruto_frames deve possuir animacao kunai_defense')
	assert(naruto_frames.get_frame_count('kunai_defense') == 3, 'kunai_defense deve ter 3 frames')
	print('[PASS] naruto_frames possui animacao kunai_defense com 3 frames')
	
	# 7. Testa interacao: Clone ativo + Armadilha ativa
	# Clone deve se sacrificar e a armadilha NAO deve ser ativada!
	bf.summon_clone(true)
	assert(bf.has_player_clone(), 'Clone do jogador deve estar ativo')
	
	var kawarimi = load('res://data/abilities/kawarimi_trap.tres')
	assert(kawarimi != null, 'kawarimi_trap.tres deve carregar')
	bf.active_trap_card = kawarimi
	bf.trap_slot.visible = true
	bf.trap_label.text = '🎴 ' + kawarimi.name.to_upper()
	
	# Oponente ataca: o clone deve se sacrificar e a armadilha deve PERMANECER armada!
	bf._damage_character(bf.player_data, bf.player_visual, 25, true)
	assert(not bf.has_player_clone(), 'Clone deve ter se sacrificado')
	assert(bf.active_trap_card == kawarimi, 'Armadilha deve PERMANECER armada e nao ser ativada')
	assert(bf.trap_slot.visible == true, 'Slot de armadilha deve continuar visivel')
	assert(bf.player_data.current_hp == initial_hp, 'Naruto nao deve tomar dano pois o clone se sacrificou')
	print('[PASS] Clone se sacrificou com sucesso e armadilha continuou ativa sem disparar')
	
	# Proximo ataque: agora sem clone, a armadilha deve disparar!
	bf._damage_character(bf.player_data, bf.player_visual, 25, true)
	assert(bf.active_trap_card == null, 'Armadilha deve ter sido consumida agora que nao ha clone')
	assert(bf.trap_slot.visible == false, 'Slot de armadilha deve ficar invisivel')
	assert(bf.player_data.current_hp == initial_hp, 'Naruto protegido pela armadilha de substituicao')
	print('[PASS] Segundo ataque sem clone ativou a armadilha corretamente')
	
	# 8. Testa jogar a carta Kage Bunshin no Jutsu da mao via _on_card_played
	bf.player_chakra_pool[ChakraElement.Type.WIND] = 2
	bf._spawn_card_in_hand(kb)
	var card_node = bf.hand_cards.back()
	assert(card_node != null, 'CardUI do Kage Bunshin deve estar na mao')
	bf._reorganize_hand()
	assert(card_node.is_playable == true, 'CardUI deve ser jogavel com 2 Wind chakra')
	bf._on_card_played(kb, card_node)
	assert(bf.has_player_clone(), 'Clone deve ter sido invocado ao jogar a carta')
	assert(bf.player_clone_visual.visible == true, 'Clone deve estar visivel imediatamente')
	assert(bf.player_clone_visual.modulate.a > 0.9, 'Clone deve ter opacidade total (nao invisivel)')
	assert(bf.player_chakra_pool[ChakraElement.Type.WIND] == 1, 'Chakra de Vento deve ter sido consumido (2 - 1 = 1)')
	print('[PASS] Carta Kage Bunshin jogada com sucesso da mao, consumindo chakra e gerando clone visivel')
	
	print('=== TODOS OS TESTES PASSARAM COM SUCESSO! ===')
	get_tree().quit(0)

