
extends Node2D

var player_score = 0
var current_ball = 1

var game_active = false
var game_over = false

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

	$pizza_board/p_lit.visible = pizza_frenzy.p_collected
	$pizza_board/p_grey.visible = not pizza_frenzy.p_collected
	
	$player_label.text = "PLAYER 1"
	$score_label.text = format_score(player_score)
	$ball_label.text = "BALL " + str(current_ball)
	$game_over_label.visible = false

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

	$ball_label.text = "BALL " + str(current_ball)

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

	$player_label.text = "PLAYER 1"
	$score_label.text = format_score(player_score)
	$ball_label.text = "BALL " + str(current_ball)
	
	$game_over_label.visible = false

	update_pizza_board()

	print("NEW GAME STARTED")
	print("Balls per game: ", game_settings.balls_per_game)
	print("GAME ACTIVE: ", game_active)

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_N:
			start_new_game()

	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_D:
			ball_drained()
	
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_S:
			add_score(10000)


func _process(_delta):
	update_pizza_board()
