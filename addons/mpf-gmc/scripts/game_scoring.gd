extends Node

@onready var main_game_screen = get_parent().get_node("Main_Game_Screen")

func award_points(points):
	main_game_screen.add_score(points)

func target_hit():
	award_points(10000)
	main_game_screen.show_score_popup("TARGET", 10000)
	
func ramp_hit():
	award_points(25000)
	main_game_screen.show_score_popup("RAMP", 25000)
	
func bumper_hit():
	award_points(1000)
	main_game_screen.show_score_popup("BUMPER", 1000)

	if main_game_screen.home_alone_section != 2:
		return

	if main_game_screen.junk_food_complete:
		return

	main_game_screen.junk_food_score += 1000

	print("JUNK FOOD SCORE: ", main_game_screen.junk_food_score)

	if main_game_screen.junk_food_score >= 50000:
		main_game_screen.junk_food_score = 50000
		main_game_screen.junk_food_complete = true
		main_game_screen.staircase_ramp_lit = true

		print("JUNK FOOD COMPLETE")
		print("STAIRCASE RAMP LIT")

		main_game_screen.home_alone_section = 3
		main_game_screen.start_home_alone_section()
		main_game_screen.show_staircase_instruction()
	else:
		main_game_screen.update_junk_food_display()

func _input(event):
	if event is InputEventKey and event.pressed:

		if event.keycode == KEY_G:
			target_hit()

		if event.keycode == KEY_R:
			ramp_hit()

		if event.keycode == KEY_B:
			bumper_hit()
