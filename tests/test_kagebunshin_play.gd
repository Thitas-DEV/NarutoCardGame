extends Node

func _ready():
	print("--- TEST PLAY KAGEBUNSHIN ---")
	var bf_scene = load("res://src/battle/BattleField.tscn")
	var bf = bf_scene.instantiate()
	add_child(bf)
	
	# Give player Wind chakra
	bf.player_chakra_pool[ChakraElement.Type.WIND] = 3
	
	var kb = load("res://data/abilities/kagebunshin.tres")
	print("KB id: ", kb.id, " element_cost: ", kb.element_cost, " required_element: ", kb.required_element)
	print("Has clone before: ", bf.has_player_clone())
	
	# Create a dummy card node or find it in hand
	var card_node = null
	for c in bf.hand_cards:
		if c.card_data.id == "kagebunshin":
			card_node = c
			break
	if not card_node:
		# Spawn one
		bf._spawn_card_in_hand(kb)
		card_node = bf.hand_cards.back()
		
	print("Found card_node in hand. Playing it...")
	var initial_wind = bf.player_chakra_pool[ChakraElement.Type.WIND]
	bf._on_card_played(kb, card_node)
	
	print("Wind after: ", bf.player_chakra_pool[ChakraElement.Type.WIND])
	print("Has clone after _on_card_played: ", bf.has_player_clone())
	print("player_clone_visual: ", bf.player_clone_visual)
	if bf.player_clone_visual:
		print("clone is_clone: ", bf.player_clone_visual.is_clone)
		print("clone position: ", bf.player_clone_visual.position)
		print("clone visible: ", bf.player_clone_visual.visible)
		print("clone modulate: ", bf.player_clone_visual.modulate)
		print("clone animated_sprite visible: ", bf.player_clone_visual.animated_sprite.visible if bf.player_clone_visual.animated_sprite else "no sprite")
		print("clone animated_sprite anim: ", bf.player_clone_visual.animated_sprite.animation if bf.player_clone_visual.animated_sprite else "no sprite")
	
	# Wait a bit for tweens
	await get_tree().create_timer(1.0).timeout
	print("After 1.0s:")
	print("Has clone after 1s: ", bf.has_player_clone())
	if bf.player_clone_visual:
		print("clone modulate: ", bf.player_clone_visual.modulate)
		print("clone visible: ", bf.player_clone_visual.visible)
	
	get_tree().quit(0)
