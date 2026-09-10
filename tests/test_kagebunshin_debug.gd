extends Node

func _ready():
	print("=== RUNNING REPRO TEST FOR KAGEBUNSHIN ===")
	var tex = load("res://assets/characters/naruto/naruto/stansefffs1.png")
	print("Texture stansefffs1.png: ", tex, " size: ", tex.get_size() if tex else "null")
	var smk = load("res://assets/effects/jutsus/clone_smoke/aslfñi1.png")
	print("Smoke texture aslfñi1.png: ", smk, " size: ", smk.get_size() if smk else "null")
	
	var naruto = load("res://data/characters/naruto.tres")
	GameManager.active_hero = naruto
	GameManager.player_deck = naruto.starting_deck.duplicate()
	
	var bf_scene = load("res://src/battle/BattleField.tscn")
	var bf = bf_scene.instantiate()
	add_child(bf)
	
	await get_tree().process_frame
	await get_tree().process_frame
	
	print("Initial turn_number: ", bf.turn_number)
	print("Player chakra pool: ", bf.player_chakra_pool)
	print("Hand cards count: ", bf.hand_cards.size())
	
	# Ensure player has 1 Wind chakra
	bf.player_chakra_pool[ChakraElement.Type.WIND] = 2
	
	# Find kagebunshin in hand or spawn it
	var kb_card = null
	for c in bf.hand_cards:
		if c.card_data.id == "kagebunshin":
			kb_card = c
			break
			
	if not kb_card:
		var kb_data = load("res://data/abilities/kagebunshin.tres")
		bf._spawn_card_in_hand(kb_data)
		kb_card = bf.hand_cards.back()
		
	print("Found kb_card: ", kb_card.card_data.name)
	bf._reorganize_hand()
	print("Card is_playable after reorganize: ", kb_card.is_playable)
	
	print("Has clone before: ", bf.has_player_clone())
	print("player_clone_visual before: ", bf.player_clone_visual)
	
	# Play the card!
	print("Simulating card play via _on_card_played...")
	bf._on_card_played(kb_card.card_data, kb_card)
	
	print("Immediately after _on_card_played:")
	print("Has clone: ", bf.has_player_clone())
	print("player_clone_visual: ", bf.player_clone_visual)
	if bf.player_clone_visual:
		var clone = bf.player_clone_visual
		print("Clone parent: ", clone.get_parent().name)
		print("Clone position: ", clone.position)
		print("Clone global_position: ", clone.global_position)
		print("Clone visible: ", clone.visible)
		print("Clone modulate: ", clone.modulate)
		print("Clone is_clone: ", clone.is_clone)
		print("Clone animated_sprite: ", clone.animated_sprite)
		if clone.animated_sprite:
			print("Sprite visible: ", clone.animated_sprite.visible)
			print("Sprite anim: ", clone.animated_sprite.animation)
			print("Sprite frame: ", clone.animated_sprite.frame)
			print("Sprite modulate: ", clone.animated_sprite.modulate)
		print("Smoke overlay: ", clone.smoke_overlay)
		if clone.smoke_overlay:
			print("Smoke visible: ", clone.smoke_overlay.visible)
			print("Smoke anim: ", clone.smoke_overlay.animation)
			print("Smoke frame: ", clone.smoke_overlay.frame)
			
	for t in range(5):
		await get_tree().create_timer(0.2).timeout
		print("Time elapsed: ", (t+1)*0.2, "s")
		if bf.player_clone_visual:
			var clone = bf.player_clone_visual
			print("  Clone modulate: ", clone.modulate, " visible: ", clone.visible, " is_animating: ", clone.is_animating)
			if clone.animated_sprite:
				print("  Sprite anim: ", clone.animated_sprite.animation, " visible: ", clone.animated_sprite.visible)
		else:
			print("  player_clone_visual IS NULL!")
			
	print("Repro test complete.")
	get_tree().quit(0)
