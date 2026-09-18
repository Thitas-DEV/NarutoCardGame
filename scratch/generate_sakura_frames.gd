extends SceneTree

func _init():
	print("--- GENERATING SAKURA_FRAMES.TRES ---")
	var frames = SpriteFrames.new()
	if frames.has_animation("default"):
		frames.remove_animation("default")

	var anims = {
		"idle": ["0-0.png", "0-1.png", "0-2.png"],
		"walk": ["20-0.png", "20-1.png", "20-2.png", "20-3.png", "20-5.png"],
		"run": ["4-0.png", "4-1.png", "4-2.png", "4-3.png", "4-4.png", "4-5.png"],
		"defense": ["120-0.png", "120-2.png", "122-0.png", "122-1.png", "122-2.png"],
		"guard": ["120-0.png", "120-2.png"],
		"damage": ["5000-0.png", "5000-11.png", "5000-20.png"],
		"attack": ["200-0.png", "200-1.png", "200-2.png", "200-4.png"],
		"attack2": ["200-5.png", "200-6.png", "200-7.png"],
		"attack3": ["300-0.png", "300-1.png", "300-2.png", "300-3.png", "300-4.png"],
		"attack4": ["600-0.png", "600-1.png", "600-2.png", "600-3.png", "600-4.png"],
		"healing": ["1200-0.png", "1200-1.png", "1200-2.png", "1200-3.png", "1200-5.png"]
	}

	for anim in anims.keys():
		if not frames.has_animation(anim):
			frames.add_animation(anim)
		var loop = (anim == "idle" or anim == "walk" or anim == "run" or anim == "defense" or anim == "guard")
		frames.set_animation_loop(anim, loop)
		frames.set_animation_speed(anim, 8.0)

		for tex_name in anims[anim]:
			var path = "res://assets/characters/sakura/" + tex_name
			if ResourceLoader.exists(path):
				var tex = load(path)
				if tex:
					frames.add_frame(anim, tex)
				else:
					print("ERRO ao carregar: ", path)
			else:
				print("NÃO EXISTE: ", path)

	var err = ResourceSaver.save(frames, "res://data/characters/sakura_frames.tres")
	print("Salvo sakura_frames.tres com codigo: ", err)
	quit()
