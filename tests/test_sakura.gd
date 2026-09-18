extends Node

func _ready() -> void:
	print("=== INICIANDO TESTES DA SAKURA HARUNO ===")
	
	# 1. Carregar CharacterData
	var sakura = load("res://data/characters/sakura.tres")
	assert(sakura != null, "Falha ao carregar res://data/characters/sakura.tres")
	print("[PASS] sakura.tres carregado com sucesso!")
	print("       Nome: ", sakura.name)
	print("       ID: ", sakura.id)
	print("       HP: ", sakura.current_hp, "/", sakura.max_hp)
	print("       Vigor: ", sakura.current_vigor, "/", sakura.max_vigor)
	assert(sakura.id == "sakura")
	assert(sakura.sprite_frames != null, "sakura.sprite_frames não deve ser nulo")
	
	# 2. Validar SpriteFrames
	var frames = sakura.sprite_frames as SpriteFrames
	assert(frames != null, "sprite_frames deve ser SpriteFrames")
	print("[PASS] sprite_frames (sakura_frames.tres) associado corretamente")
	
	for anim in ["idle", "attack", "attack2", "attack3", "attack4", "healing", "defense", "damage"]:
		assert(frames.has_animation(anim), "Faltando animacao: " + anim)
		assert(frames.get_frame_count(anim) > 0, "Animacao sem frames: " + anim)
		print("       [OK] Animacao '%s': %d frames" % [anim, frames.get_frame_count(anim)])
	
	# 3. Validar Deck Inicial
	assert(sakura.starting_deck.size() > 0, "Baralho inicial da Sakura nao deve ser vazio")
	print("[PASS] Baralho inicial possui %d cartas:" % sakura.starting_deck.size())
	for card in sakura.starting_deck:
		assert(card != null, "Carta invalida no deck")
		print("       - %s (ID: %s, Vigor: %d)" % [card.name, card.id, card.vigor_cost])
		
	# 4. Instanciar CharacterVisual no grafo da cena
	var cv_scene = load("res://src/battle/CharacterVisual.tscn")
	var cv = cv_scene.instantiate()
	add_child(cv)
	cv.setup_character(sakura)
	
	assert(cv.name_label.text == "Sakura Haruno", "Nome visual incorreto")
	assert(cv.animated_sprite.visible == true, "AnimatedSprite2D deve estar visivel")
	assert(cv.animated_sprite.sprite_frames == frames, "Frames visuais devem ser da Sakura")
	print("[PASS] CharacterVisual configurado com sucesso para a Sakura!")
	
	# Testar reprodução de animações
	cv.play_custom_animation("attack")
	assert(cv.animated_sprite.animation == "attack", "Deveria tocar attack")
	cv.play_custom_animation("healing")
	assert(cv.animated_sprite.animation == "healing", "Deveria tocar healing")
	print("[PASS] Animações 'attack' e 'healing' tocadas perfeitamente!")
	
	print("=== TODOS OS TESTES DA SAKURA PASSARAM COM 100% DE SUCESSO! ===")
	get_tree().quit(0)
