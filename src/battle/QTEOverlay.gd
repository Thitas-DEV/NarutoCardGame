# res://src/battle/QTEOverlay.gd
extends Control

signal qte_finished(success: bool, multiplier: float)

var target_sequence: Array[String] = []
var current_step: int = 0
var total_steps: int = 4
var time_left: float = 3.0
var max_time: float = 3.0
var is_active: bool = false
var perfect_inputs: int = 0

@onready var prompt_container: HBoxContainer = $CenterContainer/VBoxContainer/PromptContainer
@onready var timer_bar: ProgressBar = $CenterContainer/VBoxContainer/TimerBar
@onready var banner_label: Label = $BannerPanel/BannerLabel
@onready var result_label: Label = $ResultLabel
@onready var ougi_title_label: Label = $BannerPanel/OugiTitleLabel

var key_map = {
	KEY_W: "W", KEY_UP: "W",
	KEY_A: "A", KEY_LEFT: "A",
	KEY_S: "S", KEY_DOWN: "S",
	KEY_D: "D", KEY_RIGHT: "D",
	KEY_SPACE: "SPACE", KEY_ENTER: "SPACE"
}

func start_qte(card: CardData) -> void:
	visible = true
	is_active = true
	ougi_title_label.text = "⚡ " + card.title.to_upper() + " ⚡"
	banner_label.text = "奥義発動 - SINCRONIZE OS SELOS NINJA!"
	result_label.text = ""
	
	total_steps = card.qte_difficulty
	time_left = 3.5
	max_time = 3.5
	current_step = 0
	perfect_inputs = 0
	
	# Generate random sequence from ["W", "A", "S", "D", "SPACE"]
	target_sequence.clear()
	var possible_keys = ["W", "A", "S", "D", "SPACE"]
	for i in range(total_steps):
		target_sequence.append(possible_keys[randi() % possible_keys.size()])
		
	_build_ui_prompts()
	SoundManager.play_sfx("rasengan", 1.2)

func _build_ui_prompts() -> void:
	for child in prompt_container.get_children():
		child.queue_free()
		
	for i in range(target_sequence.size()):
		var key_str = target_sequence[i]
		var panel = Panel.new()
		panel.custom_minimum_size = Vector2(60, 60)
		var style = StyleBoxFlat.new()
		style.set_corner_radius_all(8)
		style.bg_color = Color(0.15, 0.18, 0.25, 0.9)
		style.border_color = Color(0.9, 0.6, 0.2)
		style.set_border_width_all(2)
		panel.add_theme_stylebox_override("panel", style)
		
		var lbl = Label.new()
		lbl.text = key_str
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		lbl.set_anchors_preset(Control.PRESET_FULL_RECT)
		lbl.add_theme_font_size_override("font_size", 20)
		panel.add_child(lbl)
		
		prompt_container.add_child(panel)

func _process(delta: float) -> void:
	if not is_active:
		return
		
	time_left -= delta
	timer_bar.value = (time_left / max_time) * 100.0
	
	if time_left <= 0.0:
		_complete_qte(false)

func _unhandled_input(event: InputEvent) -> void:
	if not is_active:
		return
		
	if event is InputEventKey and event.pressed and not event.echo:
		var pressed_key = ""
		if key_map.has(event.keycode):
			pressed_key = key_map[event.keycode]
			
		if pressed_key != "":
			_check_input(pressed_key)

func _check_input(input_key: String) -> void:
	if current_step >= target_sequence.size():
		return
		
	var expected = target_sequence[current_step]
	if input_key == expected:
		SoundManager.play_sfx("qte_success", 1.0 + (current_step * 0.15))
		# Highlight current prompt green
		var panel = prompt_container.get_child(current_step) as Panel
		var style = panel.get_theme_stylebox("panel") as StyleBoxFlat
		style.bg_color = Color(0.1, 0.8, 0.3, 0.9)
		style.border_color = Color(0.8, 1.0, 0.5)
		
		perfect_inputs += 1
		current_step += 1
		
		if current_step >= target_sequence.size():
			_complete_qte(true)
	else:
		# Wrong key penalty
		SoundManager.play_sfx("hit", 0.6)
		var panel = prompt_container.get_child(current_step) as Panel
		var style = panel.get_theme_stylebox("panel") as StyleBoxFlat
		style.bg_color = Color(0.8, 0.2, 0.2, 0.9)
		time_left = maxf(0.0, time_left - 0.6)

func _complete_qte(success: bool) -> void:
	is_active = false
	var multiplier = 1.0
	
	if success and perfect_inputs == total_steps:
		result_label.text = "🔥 PERFECT! (+50% DANO) 🔥"
		result_label.modulate = Color(1.0, 0.85, 0.1)
		multiplier = 1.5
		SoundManager.play_sfx("combo_storm", 1.1)
	elif perfect_inputs >= int(total_steps * 0.6):
		result_label.text = "⚡ GREAT! (+25% DANO) ⚡"
		result_label.modulate = Color(0.3, 0.9, 1.0)
		multiplier = 1.25
		SoundManager.play_sfx("qte_success", 1.0)
	else:
		result_label.text = "NORMAL"
		result_label.modulate = Color(0.8, 0.8, 0.8)
		multiplier = 1.0
		
	var tw = create_tween()
	tw.tween_interval(0.6)
	tw.tween_callback(func():
		visible = false
		qte_finished.emit(success, multiplier)
	)
