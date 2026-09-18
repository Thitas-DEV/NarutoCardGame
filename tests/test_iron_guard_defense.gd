extends Node

func _ready() -> void:
	print("=== INICIANDO TESTES DA ANIMACAO DEFENSE (IRON GUARD) ===")
	
	# 1. Carrega o recurso da habilidade
	var iron_guard: AbilityData = load("res://data/abilities/iron_guard.tres")
	assert(iron_guard != null, "iron_guard.tres deve existir e carregar")
	assert(iron_guard.animation_key == "defense", "iron_guard.tres deve ter animation_key == defense, atual: " + str(iron_guard.animation_key))
	print("[PASS] iron_guard.tres possui animation_key == defense")
	
	# 2. Verifica animacao no SpriteFrames do Iruka
	var iruka_frames: SpriteFrames = load("res://data/characters/iruka_frames.tres")
	assert(iruka_frames != null, "iruka_frames.tres deve carregar")
	assert(iruka_frames.has_animation("defense"), "iruka_frames deve ter animacao defense")
	assert(iruka_frames.get_frame_count("defense") >= 2, "iruka_frames defense deve ter pelo menos 2 frames")
	print("[PASS] iruka_frames possui animacao defense com " + str(iruka_frames.get_frame_count("defense")) + " frames")
	
	# 3. Testa CharacterVisual com Iruka frames
	var char_vis_scene = load("res://src/battle/CharacterVisual.tscn")
	var vis = char_vis_scene.instantiate()
	add_child(vis)
	vis.animated_sprite.visible = true
	
	vis.animated_sprite.sprite_frames = iruka_frames
	vis.play_custom_animation(iron_guard.animation_key)
	assert(vis.animated_sprite.animation == "defense", "Iruka deve executar defense ao chamar animacao defense, atual: " + str(vis.animated_sprite.animation))
	print("[PASS] Iruka CharacterVisual executou defense com sucesso")
	
	# 4. Testa fallback do Naruto (que possui kunai_defense)
	var naruto_frames: SpriteFrames = load("res://data/characters/naruto_frames.tres")
	vis.animated_sprite.sprite_frames = naruto_frames
	vis.play_custom_animation(iron_guard.animation_key)
	assert(vis.animated_sprite.animation == "kunai_defense", "Naruto deve fallback para kunai_defense, atual: " + str(vis.animated_sprite.animation))
	print("[PASS] Naruto CharacterVisual fez fallback para kunai_defense com sucesso")
	
	# 5. Testa fallback de personagem sem defesa (Sasuke faz fallback para attack)
	var sasuke_frames: SpriteFrames = load("res://data/characters/sasuke_frames.tres")
	vis.animated_sprite.sprite_frames = sasuke_frames
	vis.play_custom_animation(iron_guard.animation_key)
	assert(vis.animated_sprite.animation == "attack", "Sasuke deve fallback para attack, atual: " + str(vis.animated_sprite.animation))
	print("[PASS] Sasuke CharacterVisual fez fallback para attack com sucesso")
	
	# 6. Testa Kakashi (que possui defense)
	var kakashi_frames: SpriteFrames = load("res://data/characters/kakashi_frames.tres")
	vis.animated_sprite.sprite_frames = kakashi_frames
	vis.play_custom_animation(iron_guard.animation_key)
	assert(vis.animated_sprite.animation == "defense", "Kakashi deve executar defense, atual: " + str(vis.animated_sprite.animation))
	print("[PASS] Kakashi CharacterVisual executou defense com sucesso")
	
	# 7. Testa execute_ability com iron_guard no Iruka
	vis.animated_sprite.sprite_frames = iruka_frames
	vis.execute_ability(iron_guard, null)
	assert(vis.animated_sprite.animation == "defense", "Ao executar iron_guard, Iruka deve estar na animacao defense")
	print("[PASS] execute_ability(iron_guard) tocou animacao defense no Iruka")
	
	print("=== TODOS OS TESTES DE DEFESA DE KUNAI PASSARAM COM SUCESSO ===")
	get_tree().quit(0)

