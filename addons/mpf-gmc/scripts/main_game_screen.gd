
extends Node2D
signal video_finished

var player_score = 0
var current_ball = 1
var game_active = false
var game_over = false

var player_count = 0
var game_has_started = false

var pizza_board_down_position
var pizza_board_up_position

var information_board_down_position
var information_board_up_position

var ball_board_down_position
var ball_board_up_position

var active_board = null
var information_message = ""
var pizza_board_was_active = false

var pizza_collection_active = false

var home_alone_mission_status = "READY"
var pizza_frenzy_mission_status = "READY"
var furnace_multiball_mission_status = "LOCKED"
var set_traps_mission_status = "LOCKED"
var defend_house_mission_status = "LOCKED"

var home_alone_section = 1
var home_alone_section_complete = false

var lights_on_target_1_complete = false
var lights_on_target_2_complete = false
var lights_on_target_3_complete = false
var aftershave_target_complete = false
var junk_food_score = 0
var junk_food_complete = false
var grocery_run_active = false

var grocery_1_collected = false
var grocery_2_collected = false
var grocery_3_collected = false
var grocery_4_collected = false
var grocery_5_collected = false

var grocery_run_score = 0
var grocery_items = [
	GROCERY_SOLDIERS,
	GROCERY_MAC,
	GROCERY_MILK,
	GROCERY_BREAD,
	GROCERY_DETERGENT
]

var grocery_target_assignments = []
var grocery_collected_count = 0

var staircase_ramp_lit = false
var video_tv_home_position: Vector2
var current_video = ""

# Video path loactions for TV screen ---------------------------------------------------------------

const VIDEO_BUZZ_GIRLFRIEND = preload("res://addons/mpf-gmc/videos/buzz_girlfriend.ogv")
const VIDEO_9PM_RETURN = preload("res://addons/mpf-gmc/videos/9pm_return.ogv")

# --------------------------------------------------------------------------------------------------

# Grocery itme image paths--------------------------------------------------------------------------
const GROCERY_SOLDIERS = preload("res://addons/mpf-gmc/images/Greocery Run/army_men.png")
const GROCERY_MAC = preload("res://addons/mpf-gmc/images/Greocery Run/macaroni.png")
const GROCERY_MILK = preload("res://addons/mpf-gmc/images/Greocery Run/milk.png")
const GROCERY_BREAD = preload("res://addons/mpf-gmc/images/Greocery Run/bread.png")
const GROCERY_DETERGENT = preload("res://addons/mpf-gmc/images/Greocery Run/detergent.png")

# --------------------------------------------------------------------------------------------------

@onready var pizza_frenzy = get_parent().get_node("PizzaFrenzy")
@onready var game_settings = get_parent().get_node("GameSettings")

func format_score(score):
	var score_string = str(score)
	var result = ""
	var count = 0

	for i in range(score_string.length() - 1, -1, -1):
		result = score_string[i] + result
		count += 1

		if count == 3 and i > 0:
			result = "," + result
			count = 0

	return result

func _ready():
	print("MAIN GAME SCREEN READY")
	print("Pizza P collected: ", pizza_frenzy.p_collected)

	# Remember the visible/down positions of the boards
	pizza_board_down_position = $pizza_board.position
	information_board_down_position = $information_board.position
	ball_board_down_position = $ball_board.position

	# Calculate the hidden/up positions
	pizza_board_up_position = pizza_board_down_position - Vector2(0, 300)
	information_board_up_position = information_board_down_position - Vector2(0, 300)
	ball_board_up_position = ball_board_down_position - Vector2(0, 150)

	# Update Pizza letters
	$pizza_board/p_lit.visible = pizza_frenzy.p_collected
	$pizza_board/p_grey.visible = not pizza_frenzy.p_collected

	# Initial game display
	$score_board/player_label.text = "PLAYER 1"
	$score_board/score_label.text = format_score(player_score)
	$ball_board/ball_label.text = "BALL " + str(current_ball)

	# Hide Game Over
	$game_over_label.visible = false
	
	$pizza_board.position = pizza_board_up_position
	$information_board.position = information_board_up_position
	$ball_board.position = ball_board_up_position
	
	video_tv_home_position = $video_tv.position
	
	$video_tv.visible = false
	$video_tv/VideoStreamPlayer.finished.connect(_on_video_finished)

func update_pizza_board():
	$pizza_board/p_lit.visible = pizza_frenzy.p_collected
	$pizza_board/p_grey.visible = not pizza_frenzy.p_collected
	
	$pizza_board/i_lit.visible = pizza_frenzy.i_collected
	$pizza_board/i_grey.visible = not pizza_frenzy.i_collected
	
	$pizza_board/z2_lit.visible = pizza_frenzy.z2_collected
	$pizza_board/z2_grey.visible = not pizza_frenzy.z2_collected
	
	$pizza_board/z1_lit.visible = pizza_frenzy.z1_collected
	$pizza_board/z1_grey.visible = not pizza_frenzy.z1_collected

	$pizza_board/a_lit.visible = pizza_frenzy.a_collected
	$pizza_board/a_grey.visible = not pizza_frenzy.a_collected

func update_mission_board():

	$mission_board/mission_1_label.text = "HOME ALONE"
	$mission_board/mission_1_status.text = home_alone_mission_status

	$mission_board/mission_2_label.text = "FURNACE\nMULTIBALL"
	$mission_board/mission_2_status.text = furnace_multiball_mission_status

	$mission_board/mission_3_label.text = "PIZZA FRENZY"
	$mission_board/mission_3_status.text = pizza_frenzy_mission_status

	$mission_board/mission_4_label.text = "SET THE TRAPS"
	$mission_board/mission_4_status.text = set_traps_mission_status

	$mission_board/mission_5_label.text = "DEFEND\nTHE HOUSE"
	$mission_board/mission_5_status.text = defend_house_mission_status

func show_pizza_board():

	if active_board != null:
		return

	active_board = $pizza_board

	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(
		$pizza_board,
		"position",
		pizza_board_down_position,
		0.6
	)

func show_information_board():

	if active_board != null:
		return

	active_board = $information_board

	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(
		$information_board,
		"position",
		information_board_down_position,
		0.6
	)

func show_ball_board():

	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(
		$ball_board,
		"position",
		ball_board_down_position,
		0.6
	)

	await tween.finished

	# Hold Ball Board on screen
	await get_tree().create_timer(2.0).timeout

	hide_ball_board()

func hide_ball_board():

	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_IN)

	tween.tween_property(
		$ball_board,
		"position",
		ball_board_up_position,
		0.5
	)

func hide_active_board():

	if active_board == null:
		return

	var board = active_board
	var target_position

	if board == $pizza_board:
		target_position = pizza_board_up_position
	else:
		target_position = information_board_up_position

	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_IN)

	tween.tween_property(
		board,
		"position",
		target_position,
		0.5
	)

	await tween.finished

	active_board = null

func show_information_message(message, duration):
	
	# Don't interrupt another information message
	if information_message != "":
		return

	# Remember if Pizza Board was active
	pizza_board_was_active = (active_board == $pizza_board)

	information_message = message

	# If Pizza Board is currently down, move it up first
	if active_board == $pizza_board:

		var pizza_tween = create_tween()
		pizza_tween.set_trans(Tween.TRANS_QUAD)
		pizza_tween.set_ease(Tween.EASE_IN)

		pizza_tween.tween_property(
			$pizza_board,
			"position",
			pizza_board_up_position,
			0.5
		)

		await pizza_tween.finished

		active_board = null


	# Display the message
	$information_board/information_label.text = information_message


	# Bring Information Board down
	active_board = $information_board

	var info_tween = create_tween()
	info_tween.set_trans(Tween.TRANS_QUAD)
	info_tween.set_ease(Tween.EASE_OUT)

	info_tween.tween_property(
		$information_board,
		"position",
		information_board_down_position,
		0.6
	)

	await info_tween.finished


	# Keep message on screen
	await get_tree().create_timer(duration).timeout


	# Slide Information Board back up
	var hide_tween = create_tween()
	hide_tween.set_trans(Tween.TRANS_QUAD)
	hide_tween.set_ease(Tween.EASE_IN)

	hide_tween.tween_property(
		$information_board,
		"position",
		information_board_up_position,
		0.5
	)

	await hide_tween.finished

	active_board = null
	information_message = ""

# Only return Pizza Board if it was active before the message
	if pizza_board_was_active:
		show_pizza_board()

	pizza_board_was_active = false

func show_staircase_instruction():
	information_message = ""
	
	$information_board/information_label.text = "SHOOT\nSTAIRCASE"

func add_score(points):

	if not game_active:
		return

	game_has_started = true

	player_score += points
	$score_board/score_label.text = format_score(player_score)

func show_score_popup(shot_name, points):

	$score_board/score_popup.text = shot_name + " +" + format_score(points)
	$score_board/score_popup.visible = true

	await get_tree().create_timer(1.5).timeout

	$score_board/score_popup.visible = false

func next_ball():
	current_ball += 1

	if current_ball > game_settings.balls_per_game:
		game_active = false
		game_over = true

		$game_over_label.visible = true
		
		print("GAME OVER")
		print("GAME ACTIVE: ", game_active)
		print("GAME OVER STATE: ", game_over)

		return

	$ball_board/ball_label.text = "BALL " + str(current_ball)
	show_ball_board()

func ball_drained():

	if not game_active:
		return

	print("BALL DRAINED")

	next_ball()

func start_new_game():
	player_score = 0
	current_ball = 1
	game_active = true
	game_over = false

	player_count = 1
	game_has_started = false
	
	home_alone_section = 1
	home_alone_section_complete = false
	
	lights_on_target_1_complete = false
	lights_on_target_2_complete = false
	lights_on_target_3_complete = false
	aftershave_target_complete = false
	junk_food_score = 0
	junk_food_complete = false
	staircase_ramp_lit = false
	grocery_run_active = false

	grocery_1_collected = false
	grocery_2_collected = false
	grocery_3_collected = false
	grocery_4_collected = false
	grocery_5_collected = false

	grocery_run_score = 0
	
	home_alone_mission_status = "ACTIVE"

	pizza_frenzy.reset_pizza_frenzy()
	
	pizza_collection_active = false
	active_board = null
	
	$pizza_board.position = pizza_board_up_position
	$information_board.position = information_board_up_position

	$score_board/player_label.text = "PLAYER 1"
	$score_board/score_label.text = format_score(player_score)
	
	$game_over_label.visible = false

	update_pizza_board()
	update_mission_board()

	print("NEW GAME STARTED")
	print("Balls per game: ", game_settings.balls_per_game)
	print("GAME ACTIVE: ", game_active)

	$ball_board/ball_label.text = "BALL " + str(current_ball)
	show_ball_board()
	start_home_alone_section()

func restart_game():

	print("RESTARTING GAME")

	# Stop any video currently playing
	$video_tv/VideoStreamPlayer.stop()
	$video_tv.visible = false

	# Completely abort Pizza Frenzy
	pizza_frenzy.force_stop_pizza_frenzy()

	# Return to Main Game Screen
	visible = true

	# Start a completely fresh game
	start_new_game()

func start_home_alone_section():
	if home_alone_section_complete:
		return

	match home_alone_section:
		1:
			start_home_alone_section_1()
		2:
			start_home_alone_section_2()
		3:
			start_home_alone_section_3()
		4:
			start_home_alone_section_4()
		5:
			start_home_alone_section_5()
		6:
			start_home_alone_section_6()
		7:
			start_home_alone_section_7()

func start_home_alone_section_1():
	
	print("HOME ALONE - SECTION 1")
	print("BUZZ'S GIRLFRIEND")

func start_home_alone_section_2():
	junk_food_score = 0
	junk_food_complete = false

	print("HOME ALONE - SECTION 2")
	print("JUNK FOOD / GANGSTER MOVIE")
	print("JUNK FOOD TARGET: 50000")

	update_junk_food_display()
	show_information_board()

func start_home_alone_section_3():
	print("HOME ALONE - SECTION 3")
	print("SLED")

func start_home_alone_section_4():
	print("HOME ALONE - SECTION 4")
	print("LIGHTS ON")

func start_home_alone_section_5():
	print("HOME ALONE - SECTION 5")
	print("AFTERSHAVE")

func start_home_alone_section_6():
	print("HOME ALONE - SECTION 6")
	print("GROCERY RUN")

	grocery_target_assignments = grocery_items.duplicate()
	grocery_target_assignments.shuffle()
	grocery_collected_count = 0

	$information_board/information_label.text = ""
	show_information_board()

func start_home_alone_section_7():
	print("HOME ALONE - SECTION 7")
	print("9 PM RETURN")

	play_9pm_return_video()

func grocery_item_1_hit():
	if home_alone_section != 6:
		return

	if grocery_1_collected:
		return

	grocery_1_collected = true

	$information_board/grocery_item_1.texture = grocery_target_assignments[0]
	$information_board/grocery_item_1.visible = true

	grocery_run_active = true

	grocery_run_score += 5000

	print("GROCERY ITEM 1 COLLECTED")
	print("GROCERY RUN SCORE: ", grocery_run_score)

	add_score(5000)
	show_score_popup("GROCERY", 5000)

func grocery_item_2_hit():
	if home_alone_section != 6:
		return

	if grocery_2_collected:
		return

	grocery_2_collected = true

	$information_board/grocery_item_2.texture = grocery_target_assignments[1]
	$information_board/grocery_item_2.visible = true

	grocery_run_active = true

	grocery_run_score += 5000

	print("GROCERY ITEM 2 COLLECTED")
	print("GROCERY RUN SCORE: ", grocery_run_score)

	add_score(5000)
	show_score_popup("GROCERY", 5000)

func grocery_item_3_hit():
	if home_alone_section != 6:
		return

	if grocery_3_collected:
		return

	grocery_3_collected = true

	$information_board/grocery_item_3.texture = grocery_target_assignments[2]
	$information_board/grocery_item_3.visible = true

	grocery_run_active = true

	grocery_run_score += 5000

	print("GROCERY ITEM 3 COLLECTED")
	print("GROCERY RUN SCORE: ", grocery_run_score)

	add_score(5000)
	show_score_popup("GROCERY", 5000)

func grocery_item_4_hit():
	if home_alone_section != 6:
		return

	if grocery_4_collected:
		return

	grocery_4_collected = true

	$information_board/grocery_item_4.texture = grocery_target_assignments[3]
	$information_board/grocery_item_4.visible = true

	grocery_run_active = true

	grocery_run_score += 5000

	print("GROCERY ITEM 4 COLLECTED")
	print("GROCERY RUN SCORE: ", grocery_run_score)

	add_score(5000)
	show_score_popup("GROCERY", 5000)

func grocery_item_5_hit():
	if home_alone_section != 6:
		return

	if grocery_5_collected:
		return

	grocery_5_collected = true

	$information_board/grocery_item_5.texture = grocery_target_assignments[4]
	$information_board/grocery_item_5.visible = true

	grocery_run_active = true

	grocery_run_score += 5000

	print("GROCERY ITEM 5 COLLECTED")
	print("GROCERY RUN SCORE: ", grocery_run_score)

	add_score(5000)
	show_score_popup("GROCERY", 5000)

	print("GROCERY CHECK:")
	print("ITEM 1: ", grocery_1_collected)
	print("ITEM 2: ", grocery_2_collected)
	print("ITEM 3: ", grocery_3_collected)
	print("ITEM 4: ", grocery_4_collected)
	print("ITEM 5: ", grocery_5_collected)

	if grocery_1_collected and grocery_2_collected and grocery_3_collected and grocery_4_collected and grocery_5_collected:
		print("GROCERY RUN COMPLETE")
		print("AWARDING GROCERY BONUS: 10000")

		grocery_run_score += 10000

		add_score(10000)
		show_score_popup("GROCERY RUN", 10000)

		grocery_run_active = false

		home_alone_section = 7
		start_home_alone_section()

func lights_on_target_1_hit():
	if home_alone_section != 4:
		return

	if lights_on_target_1_complete:
		return

	lights_on_target_1_complete = true

	print("LIGHTS ON - TARGET 1 HIT")

	add_score(10000)
	show_score_popup("LIGHTS ON", 10000)

func lights_on_target_2_hit():
	if home_alone_section != 4:
		return

	if lights_on_target_2_complete:
		return

	lights_on_target_2_complete = true

	print("LIGHTS ON - TARGET 2 HIT")

	add_score(10000)
	show_score_popup("LIGHTS ON", 10000)

func lights_on_target_3_hit():
	if home_alone_section != 4:
		return

	if lights_on_target_3_complete:
		return

	lights_on_target_3_complete = true

	print("LIGHTS ON - TARGET 3 HIT")

	add_score(10000)
	show_score_popup("LIGHTS ON", 10000)

	if lights_on_target_1_complete and lights_on_target_2_complete and lights_on_target_3_complete:
		print("LIGHTS ON - ALL TARGETS COMPLETE")

		home_alone_section = 5
		start_home_alone_section()

func aftershave_target_hit():
	if home_alone_section != 5:
		return

	if aftershave_target_complete:
		return

	aftershave_target_complete = true

	print("AFTERSHAVE TARGET HIT")

	add_score(10000)
	show_score_popup("AFTERSHAVE", 10000)

	home_alone_section = 6
	start_home_alone_section()

func buzz_girlfriend_scoop_hit():
	if home_alone_section != 1:
		return

	print("BUZZ'S GIRLFRIEND SCOOP HIT")

	add_score(25000)
	show_score_popup("BUZZ'S GIRLFRIEND", 25000)

	play_buzz_girlfriend_video()

func sled_ramp_hit():
	if home_alone_section != 3:
		return

	if not staircase_ramp_lit:
		return

	print("SLED STAIRCASE RAMP HIT")

	staircase_ramp_lit = false

	add_score(20000)
	show_score_popup("SLED RUN", 20000)

	show_information_message("SLED RUN", 2.0)

func staircase_ramp_hit():
	if home_alone_section != 3:
		return

	if not staircase_ramp_lit:
		return

	print("STAIRCASE RAMP HIT")

	staircase_ramp_lit = false

	add_score(20000)
	show_score_popup("SLED RUN", 20000)

	home_alone_section = 4
	start_home_alone_section()
	
	hide_active_board()

func update_junk_food_display():
	$information_board/information_label.text = "JUNK FOOD\n" + format_score(junk_food_score) + " / 50,000"

func _input(event):
	if event is InputEventKey and event.pressed:

		if event.keycode == KEY_N:

			# No game currently running
			if not game_active:
				start_new_game()
				return

			# Game has already started - restart completely
			if game_has_started:
				restart_game()
				return

			# Game has not started yet - add another player
			if player_count < 4:
				player_count += 1
				print("PLAYER ", player_count, " ADDED")
				$score_board/player_label.text = str(player_count) + " PLAYERS"

		if event.keycode == KEY_D:
			ball_drained()

		if event.keycode == KEY_S:
			add_score(10000)

		if event.keycode == KEY_P:
			show_pizza_board()

		if event.keycode == KEY_I:
			show_information_board()

		if event.keycode == KEY_U:
			hide_active_board()

		if event.keycode == KEY_K:
			show_information_message("BALL SAVED", 3.0)

		if event.keycode == KEY_V:
			show_ball_board()

		if event.keycode == KEY_O:
			start_pizza_collection()

		if event.keycode == KEY_C:
			complete_pizza_collection()

		if event.keycode == KEY_L:
			pizza_frenzy.start_pizza_frenzy()

		if event.keycode == KEY_B:
			buzz_girlfriend_scoop_hit()

		if event.keycode == KEY_T:
			staircase_ramp_hit()

		if event.keycode == KEY_1:
			lights_on_target_1_hit()

		if event.keycode == KEY_2:
			lights_on_target_2_hit()

		if event.keycode == KEY_3:
			lights_on_target_3_hit()

		if event.keycode == KEY_4:
			aftershave_target_hit()

		if event.keycode == KEY_5:
			grocery_item_1_hit()

		if event.keycode == KEY_6:
			grocery_item_2_hit()

		if event.keycode == KEY_7:
			grocery_item_3_hit()

		if event.keycode == KEY_8:
			grocery_item_4_hit()

		if event.keycode == KEY_9:
			grocery_item_5_hit()
			
		if event.is_action_pressed("ui_accept"):
			show_video_tv()
		if event.is_action_pressed("ui_cancel"):
			hide_video_tv()
			
func start_pizza_collection():
	if pizza_collection_active:
		return

	pizza_collection_active = true

	# Update Mission Board
	pizza_frenzy_mission_status = "READY"
	update_mission_board()

	print("PIZZA COLLECTION STARTED")
	show_pizza_board()

func complete_pizza_collection():

	if not pizza_collection_active:
		return

	pizza_collection_active = false

	print("PIZZA COLLECTION COMPLETE")

	# Slide Pizza Board up
	var pizza_tween = create_tween()
	pizza_tween.set_trans(Tween.TRANS_QUAD)
	pizza_tween.set_ease(Tween.EASE_IN)

	pizza_tween.tween_property(
		$pizza_board,
		"position",
		pizza_board_up_position,
		0.5
	)

	await pizza_tween.finished

	active_board = null

	# Set the instruction
	$information_board/information_label.text = "SHOOT\nDELIVERY RAMP"

	# Bring Information Board down
	active_board = $information_board

	var info_tween = create_tween()
	info_tween.set_trans(Tween.TRANS_QUAD)
	info_tween.set_ease(Tween.EASE_OUT)

	info_tween.tween_property(
		$information_board,
		"position",
		information_board_down_position,
		0.6
	)

	await info_tween.finished

func home_alone_complete():
	print("HOME ALONE COMPLETE")

	home_alone_section_complete = true
	home_alone_mission_status = "COMPLETE"

	# Unlock Furnace Multiball
	furnace_multiball_mission_status = "READY"

	update_mission_board()

func _process(_delta):
	update_pizza_board()

func is_video_active():
	return $video_tv.visible

func _on_video_finished():

	hide_video_tv()

	video_finished.emit()

	match current_video:

		"buzz_girlfriend":
			print("BUZZ'S GIRLFRIEND VIDEO COMPLETE")

			home_alone_section = 2
			start_home_alone_section()

		"9pm_return":
			print("9 PM RETURN VIDEO COMPLETE")

			home_alone_complete()

func show_video_tv():
	var start_position = video_tv_home_position + Vector2(0, -700)

	$video_tv.position = start_position
	$video_tv.visible = true

	# Reset video to the beginning
	$video_tv/VideoStreamPlayer.stop()
	$video_tv/VideoStreamPlayer.stream_position = 0.0

	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(
		$video_tv,
		"position",
		video_tv_home_position,
		0.8
	)

	# Start video once TV reaches its final position
	tween.finished.connect(func():
		$video_tv/VideoStreamPlayer.play()
	)

func hide_video_tv():
	$video_tv/VideoStreamPlayer.stop()

	var end_position = video_tv_home_position + Vector2(0, -700)

	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN)

	tween.tween_property(
		$video_tv,
		"position",
		end_position,
		0.8
	)

	tween.finished.connect(func():
		$video_tv.visible = false
	)


func play_buzz_girlfriend_video():
	play_game_video("buzz_girlfriend")

func play_9pm_return_video():
	play_game_video("9pm_return")

func play_game_video(video_id):

	match video_id:

		"buzz_girlfriend":
			current_video = "buzz_girlfriend"
			$video_tv/VideoStreamPlayer.stream = VIDEO_BUZZ_GIRLFRIEND

		"9pm_return":
			current_video = "9pm_return"
			$video_tv/VideoStreamPlayer.stream = VIDEO_9PM_RETURN

		"gangster_movie":
			current_video = "gangster_movie"
			# Gangster movie will be added here

	show_video_tv()
