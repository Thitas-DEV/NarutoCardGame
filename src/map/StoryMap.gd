# res://src/map/StoryMap.gd
extends Control

# Nodes on the story overworld
var story_nodes = [
	{
		"id": "node_bell_test",
		"name": "Treinamento dos Sinos",
		"desc": "Teste de sobrevivência com Kakashi Hatake.",
		"type": "battle",
		"pos": Vector2(180, 480),
		"encounter": "kakashi_bell_test",
		"unlocked": true,
		"completed": false,
		"dialogue": [
			{"speaker": "Kakashi Hatake", "text": "Vocês só têm até o meio-dia para pegar um desses guizos de mim. Venham com a intenção de matar!"},
			{"speaker": "Naruto Uzumaki", "text": "Eu vou pegar esses sinos e provar que sou o melhor ninja da vila!"}
		]
	},
	{
		"id": "node_great_naruto_bridge",
		"name": "País das Ondas: Ponte",
		"desc": "Confronto contra Zabuza Momochi no nevoeiro.",
		"type": "battle",
		"pos": Vector2(400, 380),
		"encounter": "zabuza_mist",
		"unlocked": false,
		"completed": false,
		"dialogue": [
			{"speaker": "Zabuza Momochi", "text": "Vocês fedelhos se meteram no caminho errado. A Névoa Oculta vai engoli-los!"},
			{"speaker": "Kakashi Hatake", "text": "Naruto, Sasuke, protejam o construtor Tazuna!"}
		]
	},
	{
		"id": "node_forest_of_death",
		"name": "Floresta da Morte",
		"desc": "Segunda fase do Exame Chunin: pergaminhos do Céu e da Terra.",
		"type": "event",
		"pos": Vector2(650, 420),
		"unlocked": false,
		"completed": false,
		"dialogue": [
			{"speaker": "Anko Mitarashi", "text": "Bem-vindos à Floresta da Morte! Metade de vocês não vai sair daqui com vida... divirtam-se!"},
			{"speaker": "Naruto Uzumaki", "text": "Não me assusta nem um pouco! Vamos conseguir os dois pergaminhos!"}
		]
	},
	{
		"id": "node_chunin_preliminaries",
		"name": "Preliminares: Rock Lee vs Gaara",
		"desc": "A lendária luta dos Exames Chunin: Taijutsu puro vs Defesa Absoluta!",
		"type": "battle",
		"pos": Vector2(880, 260),
		"encounter": "gaara_chunin_phase1",
		"unlocked": false,
		"completed": false,
		"dialogue": [
			{"speaker": "Rock Lee", "text": "Guy-sensei... este é o momento de mostrar que mesmo sem Ninjutsu ou Genjutsu, posso ser um ninja esplêndido!"},
			{"speaker": "Gaara", "text": "Sua existência não tem significado. Minha areia irá consumir sua vida."}
		]
	},
	{
		"id": "node_valley_of_the_end",
		"name": "Vale do Fim",
		"desc": "O clímax do Naruto Clássico: Rasengan vs Chidori!",
		"type": "battle",
		"pos": Vector2(1100, 220),
		"encounter": "valley_of_the_end",
		"unlocked": false,
		"completed": false,
		"dialogue": [
			{"speaker": "Sasuke Uchiha", "text": "Naruto... é tarde demais. Estou cortando todos os meus laços!"},
			{"speaker": "Naruto Uzumaki", "text": "Se eu tiver que quebrar seus braços e pernas para te levar de volta pra casa, eu vou fazer isso!"}
		]
	}
]

var active_node_index: int = 0
var is_moving: bool = false

# UI references
@onready var chibi_player: Node2D = $MapArea/ChibiPlayer
@onready var map_canvas: CanvasItem = $MapArea/MapCanvas
@onready var node_buttons_container: Control = $MapArea/NodeButtons
@onready var info_title: Label = $TopBar/HeroInfo/HeroName
@onready var info_hp: Label = $TopBar/HeroInfo/HPLabel
@onready var deck_btn: Button = $TopBar/DeckButton
@onready var menu_btn: Button = $TopBar/MenuButton

# Dialogue Box
@onready var dialogue_modal: Panel = $DialogueModal
@onready var dlg_speaker: Label = $DialogueModal/Speaker
@onready var dlg_text: RichTextLabel = $DialogueModal/Text
@onready var dlg_start_btn: Button = $DialogueModal/StartBattleBtn
@onready var dlg_cancel_btn: Button = $DialogueModal/CancelBtn

var selected_node_data: Dictionary = {}
var current_dlg_step: int = 0

func _ready() -> void:
	deck_btn.pressed.connect(func(): get_tree().change_scene_to_file("res://src/deck_builder/DeckBuilder.tscn"))
	menu_btn.pressed.connect(func(): get_tree().change_scene_to_file("res://src/ui/MainMenu.tscn"))
	dlg_start_btn.pressed.connect(_on_dialogue_next_or_start)
	dlg_cancel_btn.pressed.connect(func(): dialogue_modal.visible = false)
	
	_update_header()
	_build_node_ui()
	chibi_player.position = story_nodes[0].pos

func _update_header() -> void:
	info_title.text = GameManager.active_hero.name + " (" + GameManager.active_hero.title + ")"
	info_hp.text = "❤️ HP: %d / %d  |  🎴 Deck: %d cartas" % [
		GameManager.active_hero.current_hp,
		GameManager.active_hero.max_hp,
		GameManager.player_deck.size()
	]

func _build_node_ui() -> void:
	for child in node_buttons_container.get_children():
		child.queue_free()
		
	for i in range(story_nodes.size()):
		var n_data = story_nodes[i]
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(130, 45)
		btn.position = n_data.pos - Vector2(65, 22)
		btn.text = n_data.name
		
		var style = StyleBoxFlat.new()
		style.set_corner_radius_all(8)
		style.bg_color = Color(0.15, 0.18, 0.28, 0.9)
		style.border_color = Color(1.0, 0.65, 0.1) if (i == 0 or story_nodes[i-1].completed) else Color(0.4, 0.4, 0.4)
		style.set_border_width_all(2)
		btn.add_theme_stylebox_override("normal", style)
		
		btn.pressed.connect(func(): _on_node_clicked(i))
		node_buttons_container.add_child(btn)

func _on_node_clicked(node_idx: int) -> void:
	if is_moving:
		return
		
	var n_data = story_nodes[node_idx]
	selected_node_data = n_data
	
	# Move chibi player to node
	is_moving = true
	SoundManager.play_sfx("card_draw")
	var tw = create_tween()
	tw.tween_property(chibi_player, "position", n_data.pos, 0.6).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_callback(func():
		is_moving = false
		active_node_index = node_idx
		_open_node_dialogue(n_data)
	)

func _open_node_dialogue(n_data: Dictionary) -> void:
	current_dlg_step = 0
	dialogue_modal.visible = true
	_render_dialogue_step()

func _render_dialogue_step() -> void:
	var dlg_list = selected_node_data.get("dialogue", [])
	if current_dlg_step < dlg_list.size():
		var entry = dlg_list[current_dlg_step]
		dlg_speaker.text = entry.speaker
		dlg_text.text = entry.text
		if current_dlg_step == dlg_list.size() - 1:
			dlg_start_btn.text = "⚔️ ENTRAR NA BATALHA"
		else:
			dlg_start_btn.text = "AVANÇAR ▶"
		SoundManager.play_sfx("chakra_charge", 1.3)
	else:
		_start_mission()

func _on_dialogue_next_or_start() -> void:
	var dlg_list = selected_node_data.get("dialogue", [])
	if current_dlg_step < dlg_list.size() - 1:
		current_dlg_step += 1
		_render_dialogue_step()
	else:
		_start_mission()

func _start_mission() -> void:
	dialogue_modal.visible = false
	if selected_node_data.type == "battle":
		GameManager.start_story_battle(selected_node_data.encounter)
	elif selected_node_data.type == "event":
		# Free card reward / heal
		GameManager.active_hero.current_hp = GameManager.active_hero.max_hp
		_update_header()
		SoundManager.play_sfx("qte_success")
