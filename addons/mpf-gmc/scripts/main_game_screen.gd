
extends Node2D

var player_score = 0
var current_ball = 1

var game_active = false
var game_over = false

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
	$player_label.text = "PLAYER 1"
	$score_label.text = format_score(player_score)
	$ball_board/ball_label.text = "BALL " + str(current_ball)

	# Hide Game Over
	$game_over_label.visible = false
	
	$pizza_board.position = pizza_board_up_position
	$information_board.position = information_board_up_position
	$ball_board.position = ball_board_up_position

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

func add_score(points):

	if not game_active:
		return

	player_score += points
	$score_label.text = format_score(player_score)

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

	pizza_frenzy.reset_pizza_frenzy()
	
	pizza_collection_active = false
	active_board = null
	
	$pizza_board.position = pizza_board_up_position
	$information_board.position = information_board_up_position

	$player_label.text = "PLAYER 1"
	$score_label.text = format_score(player_score)
	
	$game_over_label.visible = false

	update_pizza_board()

	print("NEW GAME STARTED")
	print("Balls per game: ", game_settings.balls_per_game)
	print("GAME ACTIVE: ", game_active)

	$ball_board/ball_label.text = "BALL " + str(current_ball)
	show_ball_board()

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_N:
			start_new_game()

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
		
		# Start Pizza collection
		if event.keycode == KEY_O:
			start_pizza_collection()
		
		# Test Pizza Complete
		if event.keycode == KEY_C:
			complete_pizza_collection()
			
		# Test Delivery Ramp
		if event.keycode == KEY_L:
			pizza_frenzy.start_pizza_frenzy()	

func start_pizza_collection():

	if pizza_collection_active:
		return

	pizza_collection_active = true

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

func _process(_delta):
	update_pizza_board()
