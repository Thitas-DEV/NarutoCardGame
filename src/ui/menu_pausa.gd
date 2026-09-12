extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_resume_pressed() -> void:
	visible = false
	get_tree().paused = false

func _on_sair_pressed() -> void:
	get_tree().quit()

func _unhandled_input(event: InputEvent):
	if event.is_action("ui_cancel"):
		visible = true
		get_tree().paused = true

func _on_menu_principal_pressed() -> void:
	get_tree().change_scene_to_file("res://src/ui/MainMenu.tscn")
