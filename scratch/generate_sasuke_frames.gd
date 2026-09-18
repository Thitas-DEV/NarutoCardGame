@tool
extends EditorScript

func _run() -> void:
		var frames = SpriteFrames.new()
		
		# Remover "default"
		if frames.has_animation("default"):
			frames.remove_animation("default")
			
		var anims = {
			"idle": ["0-8.png", "0-9.png", "0-10.png", "0-11.png"],
			"walk": ["20-0.png", "20-1.png", "20-2.png", "20-3.png", "20-4.png", "20-5.png"],
			"run": ["6-0.png", "41-1.png", "41-5.png"],
			"defense": ["120-1.png"],
			"damage": ["5000-0.png", "5000-10.png"],
			"sharingan": ["195-0.png"],
			"attack": ["200-0.png", "200-1.png", "200-2.png"],
			"attack2": ["200-4.png", "200-5.png", "200-6.png", "200-7.png"],
			"attack3": ["200-8.png", "200-9.png", "200-10.png", "200-11.png", "200-12.png"],
			"attack4": ["600-0.png", "600-1.png", "600-2.png"],
			"chidori": ["6-0.png", "1000-0.png", "20-0.png", "20-1.png", "1000-2.png", "1000-1.png"],
			"katon_gokakyu": ["6-0.png", "300-3.png", "300-4.png", "300-5.png"],
			"katon_housenka": ["1000-3.png", "4-2.png"],
			"katon_gouryuuka": ["500-0.png", "500-1.png", "1100-0.png", "1100-2.png", "1100-3.png", "1100-4.png"],
			"black_chidori": ["500-0.png", "500-1.png", "1100-0.png", "1100-2.png", "1100-3.png", "1100-4.png"],
			"chidori_fx": ["9007-38.png", "9007-39.png", "9007-40.png", "9007-41.png", "9007-42.png", "9007-144.png", "9007-145.png", "9007-146.png", "9007-147.png", "9007-148.png", "9007-149.png", "9007-150.png", "9007-151.png", "9007-152.png", "9007-153.png", "9007-154.png", "9007-155.png"],
			"katon_fx": ["1060-0.png", "1060-1.png", "1060-2.png", "1060-3.png", "1060-4.png", "1060-5.png", "1060-6.png", "1060-7.png", "1060-8.png", "1060-9.png", "1060-10.png", "1060-11.png", "1060-12.png", "1060-13.png", "1060-14.png", "1060-15.png", "1060-16.png", "1060-17.png", "1060-18.png", "1060-19.png", "1060-20.png", "1060-21.png", "1060-22.png", "1060-23.png", "1060-24.png", "1060-25.png", "1060-26.png", "1060-27.png", "1060-28.png", "1060-29.png", "1060-30.png", "1060-31.png", "1060-32.png", "1060-33.png", "1060-34.png", "1060-35.png", "1060-36.png", "1060-37.png", "1060-38.png", "1060-39.png"]
		}
		
		for anim in anims.keys():
			if not frames.has_animation(anim):
				frames.add_animation(anim)
			frames.set_animation_loop(anim, false)
			if anim == "idle" or anim == "walk" or anim == "run":
				frames.set_animation_loop(anim, true)
			frames.set_animation_speed(anim, 10.0)
			
			for tex_name in anims[anim]:
				var path = "res://assets/characters/sasuke/" + tex_name
				# Verificar se existe antes de adicionar
				if ResourceLoader.exists(path):
					var tex = load(path)
					if tex:
						frames.add_frame(anim, tex)
				else:
					print("Faltando textura: ", path)
					
		ResourceSaver.save(frames, "res://data/characters/sasuke_frames.tres")
		print("sasuke_frames.tres gerado com sucesso!")
