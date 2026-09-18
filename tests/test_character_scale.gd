extends Node

func _ready() -> void:
	print("=== TEST CHARACTER SPRITE SCALING ===")
	var scene = load("res://src/battle/CharacterVisual.tscn")
	var cv = scene.instantiate()
	add_child(cv)
	
	var visual_root = cv.get_node("VisualRoot") as Node2D
	assert(visual_root != null, "VisualRoot deve existir")
	assert(visual_root.scale == Vector2(2.0, 2.0), "VisualRoot scale deve ser Vector2(2, 2), atual: " + str(visual_root.scale))
	assert(visual_root.texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST, "Texture filter deve ser NEAREST (1)")
	print("[PASS] VisualRoot scale e texture_filter configurados corretamente: ", visual_root.scale, " filter: ", visual_root.texture_filter)
	
	var anim_sprite = visual_root.get_node("AnimatedSprite2D") as AnimatedSprite2D
	assert(anim_sprite != null, "AnimatedSprite2D deve existir")
	assert(anim_sprite.position == Vector2(0, -28), "AnimatedSprite2D position deve ser (0, -28)")
	print("[PASS] AnimatedSprite2D position alinhada aos pes: ", anim_sprite.position)
	
	var ui_container = cv.get_node("UIContainer") as Control
	assert(ui_container != null, "UIContainer deve existir")
	assert(ui_container.offset_top == -175.0 and ui_container.offset_bottom == -95.0, "UIContainer deve estar no topo: " + str(ui_container.offset_top) + ", " + str(ui_container.offset_bottom))
	print("[PASS] UIContainer posicionado acima dos sprites ampliados: offset_top=", ui_container.offset_top, " offset_bottom=", ui_container.offset_bottom)
	
	# Test clone setup
	var clone = scene.instantiate()
	add_child(clone)
	var naruto_data = load("res://data/characters/naruto.tres")
	clone.setup_clone(naruto_data, true)
	var clone_root = clone.get_node("VisualRoot") as Node2D
	assert(clone_root.scale == Vector2(2.0, 2.0), "Clone VisualRoot deve ter escala 2.0")
	print("[PASS] Clone mantém a mesma escala de 2.0x")
	
	print("=== TODOS OS TESTES DE ESCALA PASSARAM COM SUCESSO! ===")
	get_tree().quit(0)
