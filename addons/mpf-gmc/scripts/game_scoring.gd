extends Node

@onready var main_game_screen = get_parent().get_node("Main_Game_Screen")

func award_points(points):
	main_game_screen.add_score(points)

func target_hit():
	award_points(10000)
	
func ramp_hit():
	award_points(25000)
	
func bumper_hit():
	award_points(1000)

func _input(event):
	if event is InputEventKey and event.pressed:

		if event.keycode == KEY_G:
			target_hit()

		if event.keycode == KEY_R:
			ramp_hit()

		if event.keycode == KEY_B:
			bumper_hit()
