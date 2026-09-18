extends SceneTree
func _init():
	var paths = [
		"res://data/abilities/sakura_punch.tres",
		"res://data/abilities/sakura_kunai_slice.tres",
		"res://data/abilities/sakura_kick.tres",
		"res://data/abilities/sakura_flying_kick.tres",
		"res://data/abilities/sakura_healing.tres"
	]
	for p in paths:
		var res = ResourceLoader.load(p)
		if res:
			print(p, " -> ", res.animation_key)
		else:
			print(p, " FAILED TO LOAD")
	quit()
