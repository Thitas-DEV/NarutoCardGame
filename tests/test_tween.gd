extends Node

func _ready():
	print("--- TEST TWEEN ---")
	var node = Node2D.new()
	add_child(node)
	node.modulate = Color(1, 1, 1, 0)
	
	var tw1 = node.create_tween()
	tw1.tween_property(node, "modulate:a", 1.0, 0.2)
	
	# Second tween right after
	var tw2 = node.create_tween()
	tw2.tween_interval(0.5)
	
	print("Immediate modulate:a: ", node.modulate.a)
	print("tw1 valid: ", tw1.is_valid())
	print("tw2 valid: ", tw2.is_valid())
	
	await get_tree().create_timer(0.3).timeout
	print("After 0.3s modulate:a: ", node.modulate.a)
	
	await get_tree().create_timer(0.3).timeout
	print("After 0.6s modulate:a: ", node.modulate.a)
	
	get_tree().quit(0)
