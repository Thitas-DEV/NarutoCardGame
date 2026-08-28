# res://src/ui/RewardScreen.gd
extends Control

@onready var cards_container: HBoxContainer = $CardsContainer
@onready var skip_btn: Button = $SkipButton
@onready var title_label: Label = $TitleLabel

const CARD_UI_SCENE = preload("res://src/battle/CardUI.tscn")

func _ready() -> void:
	skip_btn.pressed.connect(_finish_rewards)
	_generate_reward_cards()

func _generate_reward_cards() -> void:
	var reward_cards = Database.get_random_reward_cards(GameManager.active_hero, 3)
	
	for c_data in reward_cards:
		var card_ui = CARD_UI_SCENE.instantiate()
		cards_container.add_child(card_ui)
		card_ui.set_card_data(c_data)
		card_ui.gui_input.connect(func(event):
			if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
				_pick_card(c_data)
		)

func _pick_card(c_data: AbilityData) -> void:
	GameManager.add_ability_to_collection(c_data)
	GameManager.add_ability_to_deck(c_data)
	SoundManager.play_sfx("qte_success", 1.2)
	_finish_rewards()

func _finish_rewards() -> void:
	# Heal hero a bit after battle
	GameManager.active_hero.current_hp = mini(GameManager.active_hero.max_hp, GameManager.active_hero.current_hp + 20)
	get_tree().change_scene_to_file("res://src/map/StoryMap.tscn")
