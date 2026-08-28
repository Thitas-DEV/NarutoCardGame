# res://src/deck_builder/DeckBuilder.gd
extends Control

@onready var collection_grid: GridContainer = $MainContainer/HSplit/CollectionPanel/Scroll/CollectionGrid
@onready var deck_grid: GridContainer = $MainContainer/HSplit/DeckPanel/Scroll/DeckGrid
@onready var stats_label: Label = $MainContainer/HSplit/DeckPanel/StatsLabel
@onready var hero_selector: OptionButton = $TopBar/HeroSelector
@onready var back_btn: Button = $TopBar/BackButton

const CARD_UI_SCENE = preload("res://src/battle/CardUI.tscn")

func _ready() -> void:
	back_btn.pressed.connect(func(): get_tree().change_scene_to_file("res://src/map/StoryMap.tscn"))
	
	hero_selector.add_item("Naruto Uzumaki", 0)
	hero_selector.add_item("Sasuke Uchiha", 1)
	hero_selector.add_item("Rock Lee", 2)
	
	match GameManager.active_hero.id:
		"naruto": hero_selector.select(0)
		"sasuke": hero_selector.select(1)
		"rock_lee": hero_selector.select(2)
		
	hero_selector.item_selected.connect(_on_hero_selected)
	_refresh_views()

func _on_hero_selected(index: int) -> void:
	match index:
		0: GameManager.select_hero("naruto")
		1: GameManager.select_hero("sasuke")
		2: GameManager.select_hero("rock_lee")
	_refresh_views()

func _refresh_views() -> void:
	_populate_collection()
	_populate_deck()
	_update_stats()

func _populate_collection() -> void:
	for child in collection_grid.get_children():
		child.queue_free()
		
	for c_data in GameManager.player_collection:
		if c_data:
			# Check if card is usable by active hero or universal
			if c_data.can_be_used_by(GameManager.active_hero) or c_data.allowed_character_ids.is_empty():
				var card_ui = CARD_UI_SCENE.instantiate()
				collection_grid.add_child(card_ui)
				card_ui.set_card_data(c_data)
				card_ui.gui_input.connect(func(event):
					if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
						_add_to_deck(c_data)
				)

func _populate_deck() -> void:
	for child in deck_grid.get_children():
		child.queue_free()
		
	for i in range(GameManager.player_deck.size()):
		var c_data = GameManager.player_deck[i]
		if c_data:
			var card_ui = CARD_UI_SCENE.instantiate()
			deck_grid.add_child(card_ui)
			card_ui.set_card_data(c_data)
			var idx = i
			card_ui.gui_input.connect(func(event):
				if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
					_remove_from_deck(idx)
			)

func _add_to_deck(ability: AbilityData) -> void:
	if GameManager.player_deck.size() >= 30:
		return
	GameManager.add_ability_to_deck(ability)
	SoundManager.play_sfx("card_draw", 1.2)
	_refresh_views()

func _remove_from_deck(index: int) -> void:
	if GameManager.player_deck.size() <= 8:
		return # Minimum deck size
	GameManager.remove_ability_from_deck(index)
	SoundManager.play_sfx("card_draw", 0.9)
	_refresh_views()

func _update_stats() -> void:
	var total = GameManager.player_deck.size()
	var total_chakra = 0
	for c in GameManager.player_deck:
		if c:
			total_chakra += c.yin_cost + c.yang_cost
	var avg_cost = float(total_chakra) / float(maxi(1, total))
	stats_label.text = "Cartas no Deck: %d / 30 | Custo Médio de Chakra: %.1f | Clique com botão direito na carta para remover" % [total, avg_cost]
