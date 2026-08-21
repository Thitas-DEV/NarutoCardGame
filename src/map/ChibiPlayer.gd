# res://src/map/ChibiPlayer.gd
extends Node2D

var bounce_time: float = 0.0

func _process(delta: float) -> void:
	bounce_time += delta * 4.0
	queue_redraw()

func _draw() -> void:
	var b_y = sin(bounce_time) * 4.0
	var hero = GameManager.active_hero
	var main_col = hero.avatar_color if hero else Color(1.0, 0.5, 0.0)
	var sec_col = hero.secondary_color if hero else Color(0.1, 0.3, 0.8)
	
	# Shadow
	draw_circle(Vector2(0, 10), 14, Color(0, 0, 0, 0.4))
	
	# Chibi Tiny Body
	draw_rect(Rect2(-10, -10 + b_y, 20, 16), main_col)
	draw_rect(Rect2(-8, 6 + b_y, 6, 8), sec_col)
	draw_rect(Rect2(2, 6 + b_y, 6, 8), sec_col)
	
	# Chibi Big Head
	draw_circle(Vector2(0, -22 + b_y), 18, Color(1.0, 0.85, 0.72))
	# Hair
	draw_circle(Vector2(0, -32 + b_y), 16, main_col)
	# Forehead protector
	draw_rect(Rect2(-12, -28 + b_y, 24, 6), sec_col)
	draw_rect(Rect2(-5, -27 + b_y, 10, 4), Color(0.85, 0.85, 0.9))
	
	# Cute Big Chibi Eyes
	draw_circle(Vector2(-6, -20 + b_y), 3.5, Color(0.1, 0.1, 0.15))
	draw_circle(Vector2(6, -20 + b_y), 3.5, Color(0.1, 0.1, 0.15))
	draw_circle(Vector2(-5, -21 + b_y), 1.2, Color.WHITE)
	draw_circle(Vector2(7, -21 + b_y), 1.2, Color.WHITE)
	
	# Whiskers (Naruto)
	if hero and hero.id == "naruto":
		draw_line(Vector2(-14, -18 + b_y), Vector2(-8, -18 + b_y), Color(0.3, 0.2, 0.1), 1.5)
		draw_line(Vector2(8, -18 + b_y), Vector2(14, -18 + b_y), Color(0.3, 0.2, 0.1), 1.5)
