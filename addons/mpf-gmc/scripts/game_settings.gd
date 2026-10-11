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

	config.set_value("settings", "free_play_enabled", free_play_enabled)

	config.save("user://pinball_settings.cfg")


func load_settings():
	var config = ConfigFile.new()

	var error = config.load("user://pinball_settings.cfg")

	if error == OK:
		free_play_enabled = config.get_value(
			"settings",
			"free_play_enabled",
			true
		)
		
func _ready():
	load_settings()
	get_parent().get_node("Main_Game_Screen").update_attract_credit_message()
