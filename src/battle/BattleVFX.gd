# res://src/battle/BattleVFX.gd
class_name BattleVFX
extends Node2D

## Gerenciador e renderizador de efeitos visuais de batalha na Arena2D.
## Controla projéteis voando, raios celestiais, investidas de clones e invocações.

# Lista de projéteis ativos
var active_projectiles: Array[Dictionary] = []
# Lista de raios celestiais ativos
var active_celestials: Array[Dictionary] = []
# Lista de clones em investida
var active_clones: Array[Dictionary] = []
# Lista de invocações ativas
var active_summons: Array[Dictionary] = []
# Lista de efeitos de impacto / explosões
var active_explosions: Array[Dictionary] = []
# Lista de paredes de terra (Doton)
var active_earth_walls: Array[Dictionary] = []

func _ready() -> void:
	z_index = 20 # Renderiza acima dos personagens

func _process(delta: float) -> void:
	var needs_redraw = false
	
	# 1. Processar Projéteis
	var p_idx = active_projectiles.size() - 1
	while p_idx >= 0:
		needs_redraw = true
		var proj = active_projectiles[p_idx]
		proj.traveled += proj.speed * delta
		var t = clampf(proj.traveled / proj.distance, 0.0, 1.0)
		proj.current_pos = proj.start_pos.lerp(proj.end_pos, t)
		
		# Adicionar ponto ao rastro
		proj.trail.append({"pos": proj.current_pos, "alpha": 1.0, "size": proj.radius * 0.8})
		if proj.trail.size() > 8:
			proj.trail.pop_front()
			
		# Envelhecer rastro existente
		for tr in proj.trail:
			tr.alpha = maxf(0.0, tr.alpha - delta * 4.0)
			tr.size = maxf(2.0, tr.size - delta * 15.0)
			
		if t >= 1.0:
			# Chegou ao destino
			_spawn_explosion(proj.end_pos, proj.color, proj.radius * 2.2)
			if proj.on_impact.is_valid():
				proj.on_impact.call()
			active_projectiles.remove_at(p_idx)
		p_idx -= 1
		
	# 2. Processar Raios Celestiais (Kirin)
	var c_idx = active_celestials.size() - 1
	while c_idx >= 0:
		needs_redraw = true
		var c = active_celestials[c_idx]
		c.time += delta
		c.alpha = clampf(1.0 - (c.time / c.duration), 0.0, 1.0)
		if c.time >= c.impact_time and not c.impact_called:
			c.impact_called = true
			_spawn_explosion(c.target_pos, c.color, 45.0)
			if c.on_impact.is_valid():
				c.on_impact.call()
		if c.time >= c.duration:
			active_celestials.remove_at(c_idx)
		c_idx -= 1

	# 3. Processar Clones das Sombras
	var cl_idx = active_clones.size() - 1
	while cl_idx >= 0:
		needs_redraw = true
		var clone = active_clones[cl_idx]
		clone.delay -= delta
		if clone.delay <= 0.0:
			clone.progress += delta * clone.speed_mult
			var t = clampf(clone.progress, 0.0, 1.0)
			clone.current_pos = clone.start_pos.lerp(clone.end_pos, t)
			if t >= 1.0:
				# Golpe do clone
				_spawn_smoke_puff(clone.end_pos)
				_spawn_explosion(clone.end_pos, Color(1.0, 0.8, 0.4), 18.0)
				SoundManager.play_sfx("hit", randf_range(1.1, 1.4))
				if clone.is_last and clone.on_impact.is_valid():
					clone.on_impact.call()
				active_clones.remove_at(cl_idx)
		cl_idx -= 1

	# 4. Processar Invocações (Shiki Fujin, etc)
	var s_idx = active_summons.size() - 1
	while s_idx >= 0:
		needs_redraw = true
		var s = active_summons[s_idx]
		s.time += delta
		if s.time >= s.strike_time and not s.impact_called:
			s.impact_called = true
			_spawn_explosion(s.target_pos, s.color, 50.0)
			if s.on_impact.is_valid():
				s.on_impact.call()
		if s.time >= s.duration:
			active_summons.remove_at(s_idx)
		s_idx -= 1

	# 5. Processar Explosões e Efeitos de Partícula
	var ex_idx = active_explosions.size() - 1
	while ex_idx >= 0:
		needs_redraw = true
		var ex = active_explosions[ex_idx]
		ex.time += delta
		ex.radius += delta * 60.0
		ex.alpha = clampf(1.0 - (ex.time / ex.duration), 0.0, 1.0)
		if ex.time >= ex.duration:
			active_explosions.remove_at(ex_idx)
		ex_idx -= 1

	# 6. Processar Parede de Terra (Doton)
	var ew_idx = active_earth_walls.size() - 1
	while ew_idx >= 0:
		needs_redraw = true
		var ew = active_earth_walls[ew_idx]
		ew.time += delta
		if ew.time < 0.2:
			# Subindo do solo
			ew.height_ratio = ew.time / 0.2
		elif ew.time > ew.duration - 0.3:
			# Afundando
			ew.height_ratio = maxf(0.0, (ew.duration - ew.time) / 0.3)
		else:
			ew.height_ratio = 1.0
			
		if ew.time >= ew.duration:
			active_earth_walls.remove_at(ew_idx)
		ew_idx -= 1
		
	if needs_redraw:
		queue_redraw()

# ==================== DISPARADORES PÚBLICOS ====================

func spawn_projectile(start_pos: Vector2, end_pos: Vector2, ability: AbilityData, on_impact: Callable) -> void:
	var dist = start_pos.distance_to(end_pos)
	var speed = ability.projectile_speed if ability.projectile_speed > 0 else 900.0
	
	active_projectiles.append({
		"start_pos": start_pos,
		"end_pos": end_pos,
		"current_pos": start_pos,
		"distance": dist,
		"traveled": 0.0,
		"speed": speed,
		"color": ability.projectile_color,
		"texture": ability.projectile_texture,
		"radius": 18.0 if ability.element_cost > 1 else 14.0,
		"element": ability.required_element,
		"trail": [],
		"on_impact": on_impact
	})
	queue_redraw()

func spawn_celestial_strike(target_pos: Vector2, ability: AbilityData, on_impact: Callable) -> void:
	# Gera nós de raio procedural com ramificações
	var bolt_start = Vector2(target_pos.x + randf_range(-40, 40), -80)
	var segments: Array[Vector2] = [bolt_start]
	var current = bolt_start
	var steps = 8
	var dy = (target_pos.y - bolt_start.y) / float(steps)
	
	for i in range(steps - 1):
		current = Vector2(current.x + randf_range(-30, 30), current.y + dy)
		segments.append(current)
	segments.append(target_pos)
	
	active_celestials.append({
		"target_pos": target_pos,
		"segments": segments,
		"color": ability.projectile_color if ability.projectile_color != Color.TRANSPARENT else Color(0.7, 0.9, 1.0),
		"time": 0.0,
		"impact_time": 0.12,
		"impact_called": false,
		"duration": 0.5,
		"alpha": 1.0,
		"on_impact": on_impact
	})
	queue_redraw()

func spawn_clone_rush(start_pos: Vector2, target_pos: Vector2, char_data: CharacterData, on_impact: Callable) -> void:
	_spawn_smoke_puff(start_pos)
	SoundManager.play_sfx("kawarimi")
	
	var clone_count = 3
	for i in range(clone_count):
		var y_off = (i - 1) * 25.0
		active_clones.append({
			"start_pos": start_pos + Vector2(0, y_off * 0.5),
			"end_pos": target_pos + Vector2(-60 if start_pos.x < target_pos.x else 60, y_off),
			"current_pos": start_pos,
			"progress": 0.0,
			"delay": i * 0.14,
			"speed_mult": 4.2,
			"is_last": (i == clone_count - 1),
			"char_data": char_data,
			"on_impact": on_impact
		})
	queue_redraw()

func spawn_summon_strike(target_pos: Vector2, ability: AbilityData, on_impact: Callable) -> void:
	_spawn_smoke_puff(target_pos + Vector2(0, -60))
	active_summons.append({
		"target_pos": target_pos,
		"color": ability.projectile_color if ability.projectile_color != Color.TRANSPARENT else Color(0.6, 0.2, 0.8),
		"time": 0.0,
		"strike_time": 0.25,
		"impact_called": false,
		"duration": 0.7,
		"on_impact": on_impact
	})
	queue_redraw()

func spawn_earth_wall(pos: Vector2) -> void:
	active_earth_walls.append({
		"pos": pos,
		"time": 0.0,
		"duration": 1.4,
		"height_ratio": 0.0
	})
	_spawn_smoke_puff(pos + Vector2(0, 10))
	queue_redraw()

func _spawn_explosion(pos: Vector2, color: Color, radius: float) -> void:
	active_explosions.append({
		"pos": pos,
		"color": color,
		"radius": radius * 0.5,
		"max_radius": radius,
		"time": 0.0,
		"duration": 0.25,
		"alpha": 1.0
	})
	queue_redraw()

func spawn_smoke_puff(pos: Vector2) -> void:
	active_explosions.append({
		"pos": pos,
		"color": Color(0.9, 0.9, 0.95, 0.8),
		"radius": 15.0,
		"max_radius": 35.0,
		"time": 0.0,
		"duration": 0.35,
		"alpha": 0.9
	})
	queue_redraw()

func _spawn_smoke_puff(pos: Vector2) -> void:
	spawn_smoke_puff(pos)
	queue_redraw()

# ==================== RENDERIZAÇÃO VISUAL ====================

func _draw() -> void:
	# 1. Desenhar Paredes de Terra (Doton)
	for ew in active_earth_walls:
		var max_h = 55.0
		var current_h = max_h * ew.height_ratio
		var wall_w = 40.0
		var r = Rect2(ew.pos.x - wall_w * 0.5, ew.pos.y - current_h, wall_w, current_h)
		draw_rect(r, Color(0.48, 0.38, 0.28))
		draw_rect(r, Color(0.32, 0.24, 0.16), false, 2.5)
		# Rachaduras
		if current_h > 20:
			draw_line(Vector2(ew.pos.x - 10, ew.pos.y - current_h + 10), Vector2(ew.pos.x + 5, ew.pos.y - current_h + 25), Color(0.2, 0.15, 0.1), 2.0)
			draw_line(Vector2(ew.pos.x + 5, ew.pos.y - current_h + 25), Vector2(ew.pos.x - 5, ew.pos.y - 5), Color(0.2, 0.15, 0.1), 2.0)

	# 2. Desenhar Projéteis
	for proj in active_projectiles:
		# Rastro de partículas
		for tr in proj.trail:
			var t_col = Color(proj.color.r, proj.color.g, proj.color.b, tr.alpha * 0.6)
			draw_circle(tr.pos, tr.size, t_col)
			
		# Projétil principal
		if proj.texture:
			var tex_size = proj.texture.get_size()
			var dir = (proj.end_pos - proj.start_pos).angle()
			draw_set_transform(proj.current_pos, dir, Vector2.ONE)
			draw_texture(proj.texture, -tex_size * 0.5)
			draw_set_transform(Vector2.ZERO, 0, Vector2.ONE)
		else:
			# Renderização procedural rica por elemento
			match proj.element:
				ChakraElement.Type.FIRE:
					# Esfera de Fogo (Katon) com anel e brilho
					draw_circle(proj.current_pos, proj.radius * 1.3, Color(1.0, 0.2, 0.0, 0.4))
					draw_circle(proj.current_pos, proj.radius, Color(1.0, 0.5, 0.1, 0.9))
					draw_circle(proj.current_pos, proj.radius * 0.6, Color(1.0, 0.95, 0.4, 1.0))
				ChakraElement.Type.WATER:
					# Vórtice / Dragão de Água (Suiton)
					draw_circle(proj.current_pos, proj.radius * 1.2, Color(0.1, 0.4, 0.9, 0.4))
					draw_circle(proj.current_pos, proj.radius, Color(0.2, 0.7, 1.0, 0.85))
					draw_circle(proj.current_pos, proj.radius * 0.5, Color(0.85, 0.95, 1.0, 0.95))
				ChakraElement.Type.WIND:
					# Lâminas de Vento (Fuuton)
					draw_arc(proj.current_pos, proj.radius, -PI*0.4, PI*0.4, 12, Color(0.8, 1.0, 0.8, 0.9), 3.0)
					draw_circle(proj.current_pos, proj.radius * 0.5, Color(0.9, 1.0, 0.9, 0.8))
				ChakraElement.Type.LIGHTNING:
					# Orbe de Raio (Raiton)
					draw_circle(proj.current_pos, proj.radius, Color(0.4, 0.7, 1.0, 0.9))
					for b in range(4):
						var a = randf() * TAU
						var p2 = proj.current_pos + Vector2(cos(a), sin(a)) * (proj.radius * 1.4)
						draw_line(proj.current_pos, p2, Color(1.0, 1.0, 1.0, 0.9), 2.0)
				_:
					# Genérico
					draw_circle(proj.current_pos, proj.radius, proj.color)
					draw_circle(proj.current_pos, proj.radius * 0.6, Color.WHITE)

	# 3. Desenhar Raios Celestiais (Kirin)
	for c in active_celestials:
		var c_col = Color(c.color.r, c.color.g, c.color.b, c.alpha)
		# Linha externa grossa
		for i in range(c.segments.size() - 1):
			draw_line(c.segments[i], c.segments[i+1], Color(c_col.r, c_col.g, c_col.b, c.alpha * 0.5), 9.0)
		# Linha central branca pura brilhante
		for i in range(c.segments.size() - 1):
			draw_line(c.segments[i], c.segments[i+1], Color(1.0, 1.0, 1.0, c.alpha), 3.5)

	# 4. Desenhar Clones das Sombras
	for clone in active_clones:
		if clone.delay <= 0.0:
			var c_col = clone.char_data.avatar_color if clone.char_data else Color(0.9, 0.6, 0.2)
			# Silhueta estilizada do clone correndo
			draw_circle(clone.current_pos + Vector2(0, -32), 12, Color(c_col.r, c_col.g, c_col.b, 0.85))
			draw_rect(Rect2(clone.current_pos + Vector2(-12, -22), Vector2(24, 22)), Color(c_col.r, c_col.g, c_col.b, 0.85))

	# 5. Desenhar Invocações Espectrais (Shiki Fujin)
	for s in active_summons:
		var alpha = clampf(sin((s.time / s.duration) * PI), 0.0, 1.0)
		var center = s.target_pos + Vector2(0, -70)
		# Aura espectral roxa
		draw_circle(center, 40, Color(s.color.r, s.color.g, s.color.b, alpha * 0.45))
		# Silhueta fantasmagórica do Shinigami
		draw_circle(center + Vector2(0, -20), 22, Color(0.9, 0.85, 0.95, alpha * 0.9)) # Máscara/Crânio
		# Olhos sinistros
		draw_circle(center + Vector2(-8, -20), 4, Color(0.6, 0.0, 0.9, alpha))
		draw_circle(center + Vector2(8, -20), 4, Color(0.6, 0.0, 0.9, alpha))
		# Manto espectral
		draw_line(center + Vector2(-25, 0), center + Vector2(25, 0), Color(0.3, 0.1, 0.45, alpha), 8.0)
		draw_line(center, s.target_pos, Color(0.7, 0.2, 0.9, alpha * 0.8), 4.0)

	# 6. Desenhar Explosões
	for ex in active_explosions:
		var ex_col = Color(ex.color.r, ex.color.g, ex.color.b, ex.alpha * 0.7)
		draw_circle(ex.pos, ex.radius, ex_col)
		draw_arc(ex.pos, ex.radius * 1.15, 0, TAU, 16, Color(ex.color.r, ex.color.g, ex.color.b, ex.alpha), 2.5)


