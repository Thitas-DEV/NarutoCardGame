extends SceneTree

func _init():
	var AbilityDataClass = load("res://src/core/ability_data.gd")
	
	var punch = AbilityDataClass.new()
	punch.id = "sakura_punch"
	punch.name = "Soco Certeiro"
	punch.description = "Um soco direto."
	punch.vigor_cost = 10
	punch.animation_key = "attack"
	punch.screen_shake_intensity = 3.0
	punch.scripts = [{"combo": 1, "effect": "damage", "hits": 1, "trigger": "on_play", "value": 6}]
	ResourceSaver.save(punch, "res://data/abilities/sakura_punch.tres")
	
	var kunai = AbilityDataClass.new()
	kunai.id = "sakura_kunai_slice"
	kunai.name = "Corte Rápido"
	kunai.description = "Ataque rápido com kunai."
	kunai.vigor_cost = 8
	kunai.animation_key = "attack2"
	kunai.screen_shake_intensity = 2.0
	kunai.scripts = [{"combo": 1, "effect": "damage", "hits": 1, "trigger": "on_play", "value": 4}]
	ResourceSaver.save(kunai, "res://data/abilities/sakura_kunai_slice.tres")
	
	var kick = AbilityDataClass.new()
	kick.id = "sakura_kick"
	kick.name = "Chute Frontal"
	kick.description = "Um chute com força média."
	kick.vigor_cost = 15
	kick.animation_key = "attack3"
	kick.screen_shake_intensity = 4.0
	kick.scripts = [{"combo": 1, "effect": "damage", "hits": 1, "trigger": "on_play", "value": 8}]
	ResourceSaver.save(kick, "res://data/abilities/sakura_kick.tres")
	
	var flying_kick = AbilityDataClass.new()
	flying_kick.id = "sakura_flying_kick"
	flying_kick.name = "Chute Voador"
	flying_kick.description = "Golpe poderoso que causa alto dano."
	flying_kick.vigor_cost = 25
	flying_kick.animation_key = "attack4"
	flying_kick.screen_shake_intensity = 6.0
	flying_kick.scripts = [{"combo": 1, "effect": "damage", "hits": 1, "trigger": "on_play", "value": 15}]
	ResourceSaver.save(flying_kick, "res://data/abilities/sakura_flying_kick.tres")
	
	var healing = AbilityDataClass.new()
	healing.id = "sakura_healing"
	healing.name = "Ninjutsu Médico"
	healing.description = "Cura um pouco de HP."
	healing.vigor_cost = 15
	healing.element_cost = 1
	healing.required_element = 4
	healing.delivery_type = 5 # SELF_CAST
	healing.animation_key = "healing"
	healing.screen_shake_intensity = 0.0
	healing.scripts = [{"effect": "heal", "trigger": "on_play", "value": 10}]
	ResourceSaver.save(healing, "res://data/abilities/sakura_healing.tres")

	print("CARTAS SALVAS COM SUCESSO PELO GODOT!")
	quit()
