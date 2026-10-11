extends Node

var balls_per_game = 5
var game_difficulty = "NORMAL"

var master_volume = 100
var music_volume = 100
var voice_volume = 100
var effects_volume = 100

var free_play_enabled = true


func save_settings():

	var config = ConfigFile.new()

	config.set_value(
		"settings",
		"balls_per_game",
		balls_per_game
	)

	config.set_value(
		"settings",
		"game_difficulty",
		game_difficulty
	)

	config.set_value(
		"settings",
		"master_volume",
		master_volume
	)

	config.set_value(
		"settings",
		"music_volume",
		music_volume
	)

	config.set_value(
		"settings",
		"voice_volume",
		voice_volume
	)

	config.set_value(
		"settings",
		"effects_volume",
		effects_volume
	)

	config.set_value(
		"settings",
		"free_play_enabled",
		free_play_enabled
	)

	var error = config.save("user://pinball_settings.cfg")

	if error == OK:
		print("================================")
		print("SETTINGS SAVED")
		print("Balls: ", balls_per_game)
		print("Difficulty: ", game_difficulty)
		print("Master: ", master_volume)
		print("Music: ", music_volume)
		print("Voice: ", voice_volume)
		print("Effects: ", effects_volume)
		print("Free Play: ", free_play_enabled)
		print("================================")
	else:
		print("ERROR SAVING SETTINGS: ", error)


func load_settings():

	var config = ConfigFile.new()

	var error = config.load("user://pinball_settings.cfg")

	if error == OK:

		balls_per_game = config.get_value(
			"settings",
			"balls_per_game",
			5
		)

		game_difficulty = config.get_value(
			"settings",
			"game_difficulty",
			"NORMAL"
		)

		master_volume = config.get_value(
			"settings",
			"master_volume",
			100
		)

		music_volume = config.get_value(
			"settings",
			"music_volume",
			100
		)

		voice_volume = config.get_value(
			"settings",
			"voice_volume",
			100
		)

		effects_volume = config.get_value(
			"settings",
			"effects_volume",
			100
		)

		free_play_enabled = config.get_value(
			"settings",
			"free_play_enabled",
			true
		)

		print("================================")
		print("SETTINGS LOADED")
		print("Balls: ", balls_per_game)
		print("Difficulty: ", game_difficulty)
		print("Master: ", master_volume)
		print("Music: ", music_volume)
		print("Voice: ", voice_volume)
		print("Effects: ", effects_volume)
		print("Free Play: ", free_play_enabled)
		print("================================")

	else:

		print("NO SETTINGS FILE FOUND")
		print("USING DEFAULT SETTINGS")


func _ready():

	load_settings()

	get_parent().get_node(
		"Main_Game_Screen"
	).update_attract_credit_message()
