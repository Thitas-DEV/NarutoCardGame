# res://src/battle/ComboMeter.gd
extends Control

signal combo_level_changed(new_level: int, multiplier: float)

var current_hits: int = 0
var current_level: int = 1
var combo_points: int = 0
var points_for_next_level: int = 4

@onready var hits_label: Label = $VBoxContainer/HitsLabel
@onready var level_label: Label = $VBoxContainer/LevelLabel
@onready var multiplier_label: Label = $VBoxContainer/MultiplierLabel
@onready var progress_bar: ProgressBar = $VBoxContainer/ProgressBar
@onready var flare_effect: Panel = $Flare

func _ready() -> void:
	reset_combo()

func add_combo(points: int, hits: int = 1) -> void:
	current_hits += hits
	combo_points += points
	
	var old_level = current_level
	if combo_points >= 8:
		current_level = 3
	elif combo_points >= 4:
		current_level = 2
	else:
		current_level = 1
		
	progress_bar.value = combo_points % 4
	progress_bar.max_value = 4
	
	if current_level > old_level:
		_trigger_level_up_effect()
		
	_update_display()
	combo_level_changed.emit(current_level, get_multiplier())

func get_multiplier() -> float:
	match current_level:
		1: return 1.0
		2: return 1.25
		3: return 1.50
		_: return 1.0

func reset_combo() -> void:
	current_hits = 0
	combo_points = 0
	current_level = 1
	_update_display()
	combo_level_changed.emit(current_level, 1.0)

func _update_display() -> void:
	hits_label.text = "%d HITS!" % current_hits
	hits_label.visible = current_hits > 0
	
	match current_level:
		1:
			level_label.text = "COMBO: INÍCIO"
			level_label.modulate = Color(0.9, 0.9, 0.9)
			multiplier_label.text = "x1.0 DANO"
		2:
			level_label.text = "STORM PRESSURE! 🔥"
			level_label.modulate = Color(1.0, 0.6, 0.1)
			multiplier_label.text = "x1.25 DANO (+CRÍTICO)"
		3:
			level_label.text = "STORM FINISHER! ⚡⚡"
			level_label.modulate = Color(1.0, 0.15, 0.3)
			multiplier_label.text = "x1.50 DANO (+JUTSU MAX)"

func _trigger_level_up_effect() -> void:
	SoundManager.play_sfx("combo_storm")
	flare_effect.visible = true
	flare_effect.modulate = Color(1.5, 1.2, 0.4, 1.0)
	var tw = create_tween()
	tw.tween_property(flare_effect, "modulate:a", 0.0, 0.4)
	tw.tween_callback(func(): flare_effect.visible = false)
	
	# Bounce scale
	var scale_tw = create_tween()
	scale_tw.tween_property(self, "scale", Vector2(1.2, 1.2), 0.1)
	scale_tw.tween_property(self, "scale", Vector2.ONE, 0.15)
