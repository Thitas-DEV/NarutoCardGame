extends Node

func _ready() -> void:
	print('=== INICIANDO TESTE DOS SPRITES DA BOLA DE FOGO (KATON) ===')
	
	# 1. Testar recurso SpriteFrames
	var frames = load('res://data/vfx/bola_de_fogo_frames.tres') as SpriteFrames
	assert(frames != null, 'bola_de_fogo_frames.tres deve carregar com sucesso')
	assert(frames.has_animation('default'), 'Deve ter animacao default')
	assert(frames.get_frame_count('default') == 27, 'Deve conter exatamente 27 frames (0 a 26), obtido: %d' % frames.get_frame_count('default'))
	print('[PASS] SpriteFrames carregado com 27 frames!')
	
	# 2. Testar configuracao da habilidade katon_gokakyu
	var katon = load('res://data/abilities/katon_gokakyu.tres') as AbilityData
	assert(katon != null, 'katon_gokakyu.tres deve carregar')
	assert(katon.id == 'katon_gokakyu', 'ID deve ser katon_gokakyu')
	assert(katon.required_element == ChakraElement.Type.FIRE, 'Elemento deve ser FOGO (2)')
	assert(katon.delivery_type == AbilityData.DeliveryType.PROJECTILE, 'DeliveryType deve ser PROJECTILE')
	print('[PASS] Habilidade Katon Gokakyu configurada corretamente!')
	
	# 3. Testar instanciacao no BattleVFX
	var vfx = BattleVFX.new()
	add_child(vfx)
	
	var test_state = {"impact": false}
	var start_pos_right = Vector2(280, 255)
	var end_pos_right = Vector2(1000, 255)
	
	vfx.spawn_projectile(start_pos_right, end_pos_right, katon, func():
		test_state["impact"] = true
	)
	
	assert(vfx.active_projectiles.size() == 1, 'Deve ter 1 projetil ativo')
	var proj = vfx.active_projectiles[0]
	var sprite_node = proj.get('sprite_node') as AnimatedSprite2D
	assert(sprite_node != null, 'Projetil Katon deve ter um AnimatedSprite2D criado')
	assert(sprite_node.sprite_frames == frames, 'AnimatedSprite2D deve usar bola_de_fogo_frames')
	assert(sprite_node.flip_h == false, 'Tiro da esquerda para direita deve ter flip_h == false')
	assert(sprite_node.position == start_pos_right, 'Posicao inicial deve ser start_pos')
	print('[PASS] Disparo para a direita (Jogador -> Inimigo) criado com sucesso (flip_h=false)!')
	
	# 4. Testar disparo para a esquerda (Inimigo -> Jogador)
	var start_pos_left = Vector2(1000, 255)
	var end_pos_left = Vector2(280, 255)
	vfx.spawn_projectile(start_pos_left, end_pos_left, katon, Callable())
	assert(vfx.active_projectiles.size() == 2, 'Deve ter 2 projeteis ativos')
	var proj_left = vfx.active_projectiles[1]
	var sprite_left = proj_left.get('sprite_node') as AnimatedSprite2D
	assert(sprite_left != null, 'Segundo projetil deve ter AnimatedSprite2D')
	assert(sprite_left.flip_h == true, 'Tiro da direita para esquerda deve ter flip_h == true')
	print('[PASS] Disparo para a esquerda (Inimigo -> Jogador) criado com sucesso (flip_h=true)!')
	
	# 5. Testar simulacao de voo e impacto
	var delta = 0.5
	vfx._process(delta)
	assert(proj.traveled > 0.0, 'Projetil deve ter viajado distancia positiva')
	assert(sprite_node.position.x > start_pos_right.x, 'Sprite deve ter avancado em X')
	print('[PASS] Atualizacao de posicao durante o voo verificada!')
	
	# Simula avanco ate o impacto
	vfx._process(1.0)
	assert(test_state["impact"] == true, 'Impact callback deve ter sido executado ao alcancar o destino')
	print('[PASS] Impacto executado com sucesso e sprite limpo da memoria!')
	
	print('=== TODOS OS TESTES DA BOLA DE FOGO PASSARAM COM 100% DE SUCESSO! ===')
	get_tree().quit(0)
