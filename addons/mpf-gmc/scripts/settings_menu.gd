extends Node2D

@onready var game_settings = get_parent().get_node("GameSettings")
@onready var setting_label = $setting_label
@onready var balls_selector = $balls_selector

var settings_active = false

# Current settings page
var current_page = 1
const TOTAL_PAGES = 7
var game_difficulty = "NORMAL"

# Page 1 - Balls
var selected_balls = 5
var editing_setting = false

# Page 2 - Difficulty
var selected_difficulty = 1
var difficulty_options = ["EASY", "NORMAL", "HARD"]

# Page 3 - Master Volume
var selected_master_volume = 100

# Page 4 - Music Volume
var selected_music_volume = 100

# Page 5 - Voice Volume
var selected_voice_volume = 100

# Page 6 - Effects Volume
var selected_effects_volume = 100

# Page 7 - Free Play / Credits
var free_play_enabled = true

# Bauble textures
var gold_bauble_texture
var red_bauble_texture

# Animation
var page_animating = false

var balls_label_home_x = 0.0
var balls_selector_home_x = 0.0


func _ready():
	visible = false

	selected_balls = game_settings.balls_per_game

	# Remember the existing artwork
	gold_bauble_texture = $bauble_1.texture
	red_bauble_texture = $bauble_2.texture
	
	balls_label_home_x = setting_label.position.x
	balls_selector_home_x = balls_selector.position.x

	update_page_display()
	update_baubles()

	print("SETTINGS MENU READY")
	print("Current balls per game: ", selected_balls)


func _input(event):

	if not (event is InputEventKey and event.pressed):
		return

	# Temporary development key to open/close settings
	if event.keycode == KEY_0:
		settings_active = not settings_active
		visible = settings_active

		if settings_active:
			current_page = 1
			editing_setting = false

			selected_balls = game_settings.balls_per_game
			selected_difficulty = difficulty_options.find(game_settings.game_difficulty)

			selected_master_volume = game_settings.master_volume
			selected_music_volume = game_settings.music_volume
			selected_voice_volume = game_settings.voice_volume
			selected_effects_volume = game_settings.effects_volume

			free_play_enabled = game_settings.free_play_enabled

			update_page_display()
			update_baubles()

		print("SETTINGS MENU ACTIVE: ", settings_active)
		return

	if not settings_active:
		return

	if page_animating:
		print("PAGE INPUT BLOCKED - page_animating = TRUE")
		return

	# LEFT
	if event.keycode == KEY_LEFT:

		if editing_setting:
			change_current_value(-1)
		else:
			if current_page == 1:
				current_page = TOTAL_PAGES
				animate_page_change(-1)
			else:
				change_page(-1)

	# RIGHT
	if event.keycode == KEY_RIGHT:

		if editing_setting:
			change_current_value(1)
		else:
			if current_page == TOTAL_PAGES:
				current_page = 1
				animate_page_change(1)
			else:
				change_page(1)

	# START / ENTER
	if event.keycode == KEY_ENTER:

		if editing_setting:
			confirm_current_setting()
		else:
			editing_setting = true
			update_page_display()
			print("EDITING PAGE: ", current_page)


# =========================================================
# PAGE NAVIGATION
# =========================================================

func change_page(direction):

	stop_audio_previews()

	var old_page = current_page

	current_page += direction

	if current_page > TOTAL_PAGES:
		current_page = 1
	elif current_page < 1:
		current_page = TOTAL_PAGES

	print("CHANGED PAGE: ", old_page, " -> ", current_page)

	animate_page_change(direction)


func animate_page_change(direction):

	page_animating = true

	var start_offset = 120.0 * direction
	var exit_offset = -120.0 * direction

	# Always start from the correct home position
	setting_label.position.x = balls_label_home_x
	balls_selector.position.x = balls_selector_home_x

	# Fade current content out
	var fade_out = create_tween()
	fade_out.set_parallel(true)
	fade_out.set_trans(Tween.TRANS_QUAD)
	fade_out.set_ease(Tween.EASE_IN)

	fade_out.tween_property(
		setting_label,
		"position:x",
		balls_label_home_x + exit_offset,
		0.18
	)

	fade_out.tween_property(
		setting_label,
		"modulate:a",
		0.0,
		0.18
	)

	fade_out.tween_property(
		balls_selector,
		"position:x",
		balls_selector_home_x + exit_offset,
		0.18
	)

	fade_out.tween_property(
		balls_selector,
		"modulate:a",
		0.0,
		0.18
	)

	await fade_out.finished

	# Update page while hidden
	update_page_display()
	update_baubles()

	# Put new content on the opposite side
	setting_label.position.x = balls_label_home_x + start_offset
	balls_selector.position.x = balls_selector_home_x + start_offset

	# Fade new content in
	var fade_in = create_tween()
	fade_in.set_parallel(true)
	fade_in.set_trans(Tween.TRANS_QUAD)
	fade_in.set_ease(Tween.EASE_OUT)

	fade_in.tween_property(
		setting_label,
		"position:x",
		balls_label_home_x,
		0.22
	)

	fade_in.tween_property(
		setting_label,
		"modulate:a",
		1.0,
		0.22
	)

	fade_in.tween_property(
		balls_selector,
		"position:x",
		balls_selector_home_x,
		0.22
	)

	fade_in.tween_property(
		balls_selector,
		"modulate:a",
		1.0,
		0.22
	)

	await fade_in.finished

	# Guarantee exact final positions
	setting_label.position.x = balls_label_home_x
	balls_selector.position.x = balls_selector_home_x

	page_animating = false

func stop_audio_previews():

	$music_preview.stop()
	$voice_preview.stop()
	$effects_preview.stop()


# =========================================================
# BAUBLES
# =========================================================

func update_baubles():
	$bauble_1.texture = red_bauble_texture
	$bauble_2.texture = red_bauble_texture
	$bauble_3.texture = red_bauble_texture
	$bauble_4.texture = red_bauble_texture
	$bauble_5.texture = red_bauble_texture
	$bauble_6.texture = red_bauble_texture
	$bauble_7.texture = red_bauble_texture

	match current_page:
		1:
			$bauble_1.texture = gold_bauble_texture
		2:
			$bauble_2.texture = gold_bauble_texture
		3:
			$bauble_3.texture = gold_bauble_texture
		4:
			$bauble_4.texture = gold_bauble_texture
		5:
			$bauble_5.texture = gold_bauble_texture
		6:
			$bauble_6.texture = gold_bauble_texture
		7:
			$bauble_7.texture = gold_bauble_texture


# =========================================================
# PAGE DISPLAY
# =========================================================

func update_page_display():
	match current_page:
		1:
			# Page 1 - Balls Per Game
			setting_label.text = "BALLS PER GAME: " + str(selected_balls)

			if editing_setting:
				balls_selector.text = "◀   " + str(selected_balls) + " BALLS   ▶"
			else:
				balls_selector.text = str(selected_balls) + " BALLS"


		2:
			# Page 2 - Game Difficulty
			setting_label.text = "GAME DIFFICULTY"

			if editing_setting:
				balls_selector.text = "◀   " + difficulty_options[selected_difficulty] + "   ▶"
			else:
				balls_selector.text = difficulty_options[selected_difficulty]


		3:
			# Page 3 - Master Volume
			setting_label.text = "MASTER VOLUME"

			if editing_setting:
				balls_selector.text = "◀   " + str(selected_master_volume) + "%   ▶"
			else:
				balls_selector.text = str(selected_master_volume) + "%"


		4:
			# Page 4 - Music Volume
			setting_label.text = "MUSIC VOLUME"

			if editing_setting:
				balls_selector.text = "◀   " + str(selected_music_volume) + "%   ▶"
			else:
				balls_selector.text = str(selected_music_volume) + "%"


		5:
			# Page 5 - Voice Volume
			setting_label.text = "VOICE VOLUME"

			if editing_setting:
				balls_selector.text = "◀   " + str(selected_voice_volume) + "%   ▶"
			else:
				balls_selector.text = str(selected_voice_volume) + "%"


		6:
			# Page 6 - Effects Volume
			setting_label.text = "EFFECTS VOLUME"

			if editing_setting:
				balls_selector.text = "◀   " + str(selected_effects_volume) + "%   ▶"
			else:
				balls_selector.text = str(selected_effects_volume) + "%"


		7:
			# Page 7 - Free Play / Credits
			setting_label.text = "FREE PLAY"

			if editing_setting:
				if free_play_enabled:
					balls_selector.text = "◀   ON   ▶"
				else:
					balls_selector.text = "◀   OFF   ▶"
			else:
				if free_play_enabled:
					balls_selector.text = "ON"
				else:
					balls_selector.text = "OFF"
# =========================================================
# VALUE CHANGES
# =========================================================

func change_current_value(direction):

	# Page 1 - Balls
	if current_page == 1:
		if direction > 0:
			if selected_balls == 3:
				selected_balls = 5
			else:
				selected_balls = 3
		else:
			if selected_balls == 3:
				selected_balls = 5
			else:
				selected_balls = 3

	# Page 2 - Difficulty
	elif current_page == 2:
		selected_difficulty += direction

		if selected_difficulty >= difficulty_options.size():
			selected_difficulty = 0
		elif selected_difficulty < 0:
			selected_difficulty = difficulty_options.size() - 1

	# Page 3 - Master Volume
	elif current_page == 3:
		selected_master_volume += direction * 10

		if selected_master_volume > 100:
			selected_master_volume = 0
		elif selected_master_volume < 0:
			selected_master_volume = 100

	# Page 4 - Music Volume
	elif current_page == 4:
		selected_music_volume += direction * 10

		if selected_music_volume > 100:
			selected_music_volume = 0
		elif selected_music_volume < 0:
			selected_music_volume = 100

	# Page 5 - Voice Volume
	elif current_page == 5:
		selected_voice_volume += direction * 10

		if selected_voice_volume > 100:
			selected_voice_volume = 0
		elif selected_voice_volume < 0:
			selected_voice_volume = 100

	# Page 6 - Effects Volume
	elif current_page == 6:
		selected_effects_volume += direction * 10

		if selected_effects_volume > 100:
			selected_effects_volume = 0
		elif selected_effects_volume < 0:
			selected_effects_volume = 100

	# Page 7 - Free Play / Credits
	elif current_page == 7:
		free_play_enabled = not free_play_enabled

	update_page_display()
	print("VALUE CHANGED - PAGE: ", current_page)

# =========================================================
# CONFIRM
# =========================================================

func confirm_current_setting():

	if current_page == 1:

		game_settings.balls_per_game = selected_balls

		print(
			"BALLS SETTING CONFIRMED: ",
			game_settings.balls_per_game
		)

	# Page 2 - Difficulty
	elif current_page == 2:

		game_settings.game_difficulty = difficulty_options[selected_difficulty]

		print(
			"DIFFICULTY CONFIRMED: ",
			game_settings.game_difficulty
		)

	# Page 3 - Master Volume
	elif current_page == 3:

		game_settings.master_volume = selected_master_volume

		var master_bus = AudioServer.get_bus_index("Master")
		var volume_linear = game_settings.master_volume / 100.0

		if game_settings.master_volume <= 0:
			AudioServer.set_bus_mute(master_bus, true)
		else:
			AudioServer.set_bus_mute(master_bus, false)
			AudioServer.set_bus_volume_db(
				master_bus,
				linear_to_db(volume_linear)
			)

		print(
			"MASTER VOLUME CONFIRMED: ",
			game_settings.master_volume
		)

	# Page 4 - Music Volume
	elif current_page == 4:

		game_settings.music_volume = selected_music_volume

		var music_bus = AudioServer.get_bus_index("music")
		var volume_linear = game_settings.music_volume / 100.0

		if game_settings.music_volume <= 0:
			AudioServer.set_bus_mute(music_bus, true)
		else:
			AudioServer.set_bus_mute(music_bus, false)
			AudioServer.set_bus_volume_db(
				music_bus,
				linear_to_db(volume_linear)
			)

		$music_preview.play()

		print(
			"MUSIC VOLUME CONFIRMED: ",
			game_settings.music_volume
		)

	# Page 5 - Voice Volume
	elif current_page == 5:

		game_settings.voice_volume = selected_voice_volume

		var voice_bus = AudioServer.get_bus_index("voice")
		var volume_linear = game_settings.voice_volume / 100.0

		if game_settings.voice_volume <= 0:
			AudioServer.set_bus_mute(voice_bus, true)
		else:
			AudioServer.set_bus_mute(voice_bus, false)
			AudioServer.set_bus_volume_db(
				voice_bus,
				linear_to_db(volume_linear)
			)

		$voice_preview.play()

		print(
			"VOICE VOLUME CONFIRMED: ",
			game_settings.voice_volume
		)

	# Page 6 - Effects Volume
	elif current_page == 6:

		game_settings.effects_volume = selected_effects_volume

		var effects_bus = AudioServer.get_bus_index("effects")
		var volume_linear = game_settings.effects_volume / 100.0

		if game_settings.effects_volume <= 0:
			AudioServer.set_bus_mute(effects_bus, true)
		else:
			AudioServer.set_bus_mute(effects_bus, false)
			AudioServer.set_bus_volume_db(
				effects_bus,
				linear_to_db(volume_linear)
			)

		$effects_preview.play()

		print(
			"EFFECTS VOLUME CONFIRMED: ",
			game_settings.effects_volume
		)

	# Page 7 - Free Play
	elif current_page == 7:

		game_settings.free_play_enabled = free_play_enabled

		print(
			"FREE PLAY CONFIRMED: ",
			game_settings.free_play_enabled
		)

	# =====================================================
	# SAVE EVERYTHING
	# =====================================================

	game_settings.save_settings()

	print("SETTINGS SAVED AFTER PAGE: ", current_page)

	editing_setting = false
	update_page_display()
