# res://src/battle/ScriptedPhaseManager.gd
class_name ScriptedPhaseManager
extends Node

signal phase_cutscene_started(title: String, dialogue: Array[Dictionary])
signal phase_cutscene_ended()

var battle_field: Node
var current_phase: int = 1
var is_phase_triggered: bool = false

func init_phase_manager(field: Node) -> void:
	battle_field = field

func check_phase_triggers(player_hp: int, enemy_hp: int) -> bool:
	if is_phase_triggered:
		return false
		
	var encounter = GameManager.active_encounter_id
	
	# SCRIPTED EVENT: Rock Lee vs Gaara
	if encounter == "gaara_chunin_phase1" and (player_hp <= 25 or enemy_hp <= 80):
		is_phase_triggered = true
		_trigger_rock_lee_gates_phase()
		return true
		
	# SCRIPTED EVENT: Naruto vs Zabuza (Kyuubi Awakening)
	if encounter == "zabuza_mist" and player_hp <= 20:
		is_phase_triggered = true
		_trigger_naruto_kyuubi_phase()
		return true
		
	return false

func _trigger_rock_lee_gates_phase() -> void:
	var cutscene_data = [
		{"speaker": "Rock Lee", "text": "Gaara... sua Defesa de Areia é formidável... Mas Guy-sensei me permitiu tirar ISSO!", "color": Color(0.2, 0.8, 0.3)},
		{"speaker": "Narrador", "text": "Rock Lee desamarra os pesos de treino dos tornozelos. Ao caírem no chão, a arena racha com um estrondo ensurdecedor!", "color": Color(1.0, 0.85, 0.2)},
		{"speaker": "Gaara", "text": "O quê?! Apenas pesos normais não causariam tal impacto...", "color": Color(0.9, 0.4, 0.3)},
		{"speaker": "Rock Lee", "text": "Haaaaah! Oito Portões Internos... Terceiro Portão: PORTÃO DA VIDA, ABRA!", "color": Color(0.1, 1.0, 0.4)}
	]
	phase_cutscene_started.emit("TRANSFORMAÇÃO: 5 PORTÕES INTERNOS", cutscene_data)

func _trigger_naruto_kyuubi_phase() -> void:
	var cutscene_data = [
		{"speaker": "Naruto Uzumaki", "text": "Eu não vou desistir... Nunca volto atrás com a minha palavra!", "color": Color(1.0, 0.5, 0.1)},
		{"speaker": "Narrador", "text": "Um manto de Chakra vermelho e borbulhante da Raposa de Nove Caudas envolve o corpo de Naruto!", "color": Color(1.0, 0.2, 0.2)},
		{"speaker": "Zabuza", "text": "Que tipo de Chakra monstruoso é esse?! Não é de um humano vulgar...", "color": Color(0.4, 0.7, 0.9)},
		{"speaker": "Naruto Uzumaki", "text": "EU VOU ACABAR COM VOCÊ!", "color": Color(1.0, 0.1, 0.1)}
	]
	phase_cutscene_started.emit("DESPERTAR: CHAKRA DA RAPOSA", cutscene_data)

func apply_phase_buffs(player_char: CharacterData, enemy_char: CharacterData) -> void:
	current_phase = 2
	var encounter = GameManager.active_encounter_id
	
	if encounter == "gaara_chunin_phase1":
		# Lee restores full HP and gets 5 Gates buffs
		player_char.current_hp = player_char.max_hp
		player_char.max_yin = 4
		player_char.max_yang = 4
		GameManager.add_ability_to_deck(Database.get_ability("ura_renge"))
		GameManager.add_ability_to_deck(Database.get_ability("omote_renge"))
		
	elif encounter == "zabuza_mist":
		player_char.current_hp = 60
		player_char.max_yin = 4
		player_char.max_yang = 4
		GameManager.add_ability_to_deck(Database.get_ability("ougi_rasengan"))
