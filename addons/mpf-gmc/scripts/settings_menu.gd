extends Node2D

@onready var game_settings = get_parent().get_node("GameSettings")
@onready var balls_setting_label = $balls_setting_label
@onready var balls_selector = $balls_selector

var settings_active = false
var selected_balls = 5

func _ready():
	visible = false
	
	selected_balls = game_settings.balls_per_game

	balls_setting_label.text = "BALLS PER GAME: " + str(selected_balls)
	
	balls_setting_label.text = "BALLS PER GAME: " + str(selected_balls)
	balls_selector.text = "◀   " + str(selected_balls) + " BALLS   ▶"

	print("SETTINGS MENU READY")
	print("Current balls per game: ", selected_balls)


func _input(event):

	if event is InputEventKey and event.pressed:

		if event.keycode == KEY_M:
			settings_active = not settings_active
			visible = settings_active

			if settings_active:
				selected_balls = game_settings.balls_per_game
				balls_setting_label.text = "BALLS PER GAME: " + str(selected_balls)

			print("SETTINGS MENU ACTIVE: ", settings_active)

	if not settings_active:
		return

	if event is InputEventKey and event.pressed:

		if event.keycode == KEY_LEFT:
			selected_balls = 3
			balls_setting_label.text = "BALLS PER GAME: 3"
			balls_selector.text = "◀   3 BALLS   ▶"
			print("SELECTED BALLS: 3")

		if event.keycode == KEY_RIGHT:
			selected_balls = 5
			balls_setting_label.text = "BALLS PER GAME: 5"
			balls_selector.text = "◀   5 BALLS   ▶"
			print("SELECTED BALLS: 5")

		if event.keycode == KEY_ENTER:
			game_settings.balls_per_game = selected_balls
			balls_setting_label.text = "BALLS PER GAME: " + str(selected_balls)
			print("BALLS SETTING CONFIRMED: ", game_settings.balls_per_game)
