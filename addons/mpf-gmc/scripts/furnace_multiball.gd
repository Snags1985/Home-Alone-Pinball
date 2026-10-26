extends Node2D


var furnace_multiball_active = false
var furnace_multiball_ready = false

var furnace_balls_locked = 0
var furnace_multiball_score = 0
var furnace_multiball_balls_in_play = 0

var furnace_multiball_completed = false
var laundry_scoop_visits = 0

var furnace_ball_save_active = false
var furnace_ball_save_time = 20.0
var completed_pulse_tween: Tween
var completed_animation_running = false
var scoreboard_zoom_running = false


@onready var game = get_parent()
@onready var active_logo = $active_logo
@onready var ball1_locked = $ball1_locked
@onready var ball2_locked = $ball2_locked
@onready var ball3_locked = $ball3_locked
@onready var completed_logo = $completed_logo


func test_furnace_ready():
	furnace_multiball_ready = true
	print("FURNACE MULTIBALL: READY")

func _ready():
	visible = false

func format_furnace_score(score):
	var main_screen = $"../Main_Game_Screen"
	return main_screen.format_score(score)

func laundry_scoop_hit():
	print("DEBUG - BALLS LOCKED: ", furnace_balls_locked, " | MULTIBALL ACTIVE: ", furnace_multiball_active)

	if furnace_balls_locked == 3:
		print("FURNACE MULTIBALL: SCOOP HIT - STARTING")
		furnace_multiball_active = true
		start_furnace_multiball()
		return
		
	laundry_scoop_visits += 1

	print("LAUNDRY SCOOP VISIT: ", laundry_scoop_visits)

	if laundry_scoop_visits == 1:
		print("FURNACE: CLOSED - MOAN / MOVEMENT")

	elif laundry_scoop_visits == 2:
		print("FURNACE: OPEN - READY TO LOCK BALL 1")

	elif laundry_scoop_visits == 3:
		print("FURNACE: MOAN / GROAN - SLIGHT MOVEMENT")

	elif laundry_scoop_visits == 4:
		print("FURNACE: OPEN - READY TO LOCK BALL 2")
		
	elif laundry_scoop_visits == 5:
		print("FURNACE: MOAN / GROAN - SLIGHT MOVEMENT")

	elif laundry_scoop_visits == 6:
		print("FURNACE: OPEN - READY TO LOCK BALL 3")
		
func furnace_ball_lock_hit():
	furnace_balls_locked += 1

	print("FURNACE BALL LOCK: BALL ", furnace_balls_locked, " LOCKED")

	var main_screen = $"../Main_Game_Screen"
	main_screen.show_information_message("BALL " + str(furnace_balls_locked) + " LOCKED", 3.0)

	print("FURNACE: SNAP SHUT")

	if furnace_balls_locked == 1:
		await show_ball1_locked()

	elif furnace_balls_locked == 2:
		await show_ball2_locked()

	elif furnace_balls_locked == 3:
		await show_ball3_locked()
		print("FURNACE MULTIBALL: READY TO START")

func show_ball1_locked():
	print("FURNACE: BALL 1 LOCKED CALLOUT")

	visible = true

	$scoreboard.visible = false
	active_logo.visible = false
	ball1_locked.visible = false

	await animate_ball1_locked()

	await get_tree().create_timer(2.0).timeout

	ball1_locked.visible = false
	visible = false

	print("FURNACE: BALL 1 LOCKED CALLOUT COMPLETE")

func show_ball2_locked():
	print("FURNACE: BALL 2 LOCKED CALLOUT")

	visible = true

	$scoreboard.visible = false
	active_logo.visible = false
	ball1_locked.visible = false
	ball2_locked.visible = false
	ball3_locked.visible = false

	await animate_ball2_locked()

	await get_tree().create_timer(2.0).timeout

	ball2_locked.visible = false
	visible = false

	print("FURNACE: BALL 2 LOCKED CALLOUT COMPLETE")

func show_ball3_locked():
	print("FURNACE: BALL 3 LOCKED CALLOUT")

	visible = true

	$scoreboard.visible = false
	active_logo.visible = false
	ball1_locked.visible = false
	ball2_locked.visible = false
	ball3_locked.visible = false

	await animate_ball3_locked()

	await get_tree().create_timer(2.0).timeout

	ball3_locked.visible = false
	visible = false

	print("FURNACE: BALL 3 LOCKED CALLOUT COMPLETE")

func start_furnace_multiball():
	furnace_multiball_score = 0
	$scoreboard/score_label.text = format_furnace_score(furnace_multiball_score)

	print("🔥 FURNACE MULTIBALL STARTED")

	visible = true
	$scoreboard.visible = true
	$scoreboard/score_popup.visible = false
	
	furnace_multiball_balls_in_play = 4

	furnace_ball_save_active = true
	furnace_ball_save_time = 20.0

	print("FURNACE MULTIBALL: ", furnace_multiball_balls_in_play, " BALLS IN PLAY")
	print("FURNACE BALL SAVE: ACTIVE - 20 SECONDS")
	
	animate_active_logo()

func add_furnace_score(points):
	furnace_multiball_score += points

	$scoreboard/score_label.text = format_furnace_score(furnace_multiball_score)

	$scoreboard/score_popup.text = "TARGET +" + format_furnace_score(points)
	$scoreboard/score_popup.visible = true

	await get_tree().create_timer(1.5).timeout

	$scoreboard/score_popup.visible = false

	print("FURNACE MULTIBALL SCORE: ", furnace_multiball_score)

func furnace_ball_drained():
	if not furnace_multiball_active:
		return

	if furnace_ball_save_active:
		print("🔥 BALL SAVED")

		var main_screen = $"../Main_Game_Screen"
		main_screen.show_information_message("BALL SAVED", 2.0)

		print("FURNACE BALL SAVE: REPLACEMENT BALL KICKED OUT")
		print("FURNACE BALL SAVE: REPLACEMENT BALL AUTO LAUNCHED")

		return

	furnace_multiball_balls_in_play -= 1

	print("FURNACE MULTIBALL: BALL DRAINED")
	print("FURNACE MULTIBALL: ", furnace_multiball_balls_in_play, " BALLS REMAINING")

	if furnace_multiball_balls_in_play <= 1:
		end_furnace_multiball()

func end_furnace_multiball():

	print("🔥 FURNACE MULTIBALL ENDED")

	var final_furnace_score = furnace_multiball_score

	furnace_multiball_active = false
	furnace_multiball_balls_in_play = 0

	await play_furnace_completion_sequence()

	var main_screen = $"../Main_Game_Screen"

	if final_furnace_score > 0:
		main_screen.add_score(final_furnace_score)
		main_screen.show_score_popup("FURNACE MULTIBALL", final_furnace_score)

	visible = false

	print("🔥 FURNACE SCORE TRANSFERRED: ", final_furnace_score)
	
	
func _process(delta):
	if furnace_ball_save_active:
		furnace_ball_save_time -= delta

		if furnace_ball_save_time <= 0:
			furnace_ball_save_time = 0
			furnace_ball_save_active = false

			print("FURNACE BALL SAVE: EXPIRED")

# ==============================================================================
# MULTIBALL CALLOUTS
# ==============================================================================
func animate_active_logo():
	active_logo.visible = true

	var base_scale = 0.721

	# Start from almost nothing
	active_logo.scale = Vector2(0.01, 0.01)
	active_logo.rotation = deg_to_rad(-5.0)

	# SLOW EXPLOSION
	var explode_tween = create_tween()

	explode_tween.tween_property(
		active_logo,
		"scale",
		Vector2(0.80, 0.80),
		2.2
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	await explode_tween.finished

	# SLOWLY SHRINK BACK TO NORMAL SIZE
	var settle_tween = create_tween()

	settle_tween.tween_property(
		active_logo,
		"scale",
		Vector2(base_scale, base_scale),
		1.0
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	await settle_tween.finished

	# CONTINUOUS GENTLE PULSE
	var pulse_tween = create_tween()
	pulse_tween.set_loops()

	pulse_tween.tween_property(
		active_logo,
		"scale",
		Vector2(0.755, 0.755),
		0.8
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	pulse_tween.tween_property(
		active_logo,
		"scale",
		Vector2(base_scale, base_scale),
		0.8
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func animate_ball1_locked():
	ball1_locked.visible = true

	var base_scale = ball1_locked.scale.x

	# Start from almost nothing
	ball1_locked.scale = Vector2(0.01, 0.01)
	ball1_locked.rotation = deg_to_rad(-5.0)

	# SLOW EXPLOSION
	var explode_tween = create_tween()

	explode_tween.tween_property(
		ball1_locked,
		"scale",
		Vector2(base_scale + 0.08, base_scale + 0.08),
		2.2
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	await explode_tween.finished

	# SLOWLY SHRINK BACK TO NORMAL SIZE
	var settle_tween = create_tween()

	settle_tween.tween_property(
		ball1_locked,
		"scale",
		Vector2(base_scale, base_scale),
		1.0
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
func animate_ball2_locked():
	ball2_locked.visible = true

	var base_scale = ball2_locked.scale.x

	ball2_locked.scale = Vector2(0.01, 0.01)
	ball2_locked.rotation = deg_to_rad(-5.0)

	var explode_tween = create_tween()

	explode_tween.tween_property(
		ball2_locked,
		"scale",
		Vector2(base_scale + 0.08, base_scale + 0.08),
		2.2
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	await explode_tween.finished

	var settle_tween = create_tween()

	settle_tween.tween_property(
		ball2_locked,
		"scale",
		Vector2(base_scale, base_scale),
		1.0
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func animate_ball3_locked():
	ball3_locked.visible = true

	var base_scale = ball3_locked.scale.x

	ball3_locked.scale = Vector2(0.01, 0.01)
	ball3_locked.rotation = deg_to_rad(-5.0)

	var explode_tween = create_tween()

	explode_tween.tween_property(
		ball3_locked,
		"scale",
		Vector2(base_scale + 0.08, base_scale + 0.08),
		2.2
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	await explode_tween.finished

	var settle_tween = create_tween()

	settle_tween.tween_property(
		ball3_locked,
		"scale",
		Vector2(base_scale, base_scale),
		1.0
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func animate_completed_logo():
	if completed_animation_running:
		return

	completed_animation_running = true

	completed_logo.visible = true

	if completed_pulse_tween:
		completed_pulse_tween.kill()

	var full_scale = 0.721
	var final_position = Vector2(960, 870)
	var final_scale = 0.483

	# RESET
	completed_logo.position = Vector2(960, 540)
	completed_logo.scale = Vector2(0.01, 0.01)
	completed_logo.rotation = deg_to_rad(-5.0)

	# BIG SLOW EXPLOSION
	var explode_tween = create_tween()

	explode_tween.tween_property(
		completed_logo,
		"scale",
		Vector2(full_scale + 0.06, full_scale + 0.06),
		1.4
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	await explode_tween.finished

	# FULL-SCREEN PULSE
	var full_pulse_tween = create_tween()

	full_pulse_tween.tween_property(
		completed_logo,
		"scale",
		Vector2(0.755, 0.755),
		0.45
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	full_pulse_tween.tween_property(
		completed_logo,
		"scale",
		Vector2(full_scale, full_scale),
		0.45
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	full_pulse_tween.tween_property(
		completed_logo,
		"scale",
		Vector2(0.755, 0.755),
		0.45
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	full_pulse_tween.tween_property(
		completed_logo,
		"scale",
		Vector2(full_scale, full_scale),
		0.45
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	await full_pulse_tween.finished

	# MOVE + SHRINK TO FINAL POSITION
	var move_tween = create_tween()
	move_tween.set_parallel(true)

	move_tween.tween_property(
		completed_logo,
		"position",
		final_position,
		0.8
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)

	move_tween.tween_property(
		completed_logo,
		"scale",
		Vector2(final_scale, final_scale),
		0.8
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)

	await move_tween.finished

	# CONTINUOUS BOTTOM PULSE
	completed_pulse_tween = create_tween()
	completed_pulse_tween.set_loops()

	completed_pulse_tween.tween_property(
		completed_logo,
		"scale",
		Vector2(0.505, 0.505),
		0.65
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	completed_pulse_tween.tween_property(
		completed_logo,
		"scale",
		Vector2(0.483, 0.483),
		0.65
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
func show_completed_logo():
	if completed_animation_running:
		return

	print("FURNACE: COMPLETED CALLOUT TEST")

	visible = true

	$scoreboard.visible = false
	active_logo.visible = false
	ball1_locked.visible = false
	ball2_locked.visible = false
	ball3_locked.visible = false
	completed_logo.visible = false

	await animate_completed_logo()

	await get_tree().create_timer(4.0).timeout

	completed_animation_running = false

	print("FURNACE: COMPLETED CALLOUT TEST COMPLETE")

func test_scoreboard_zoom():

	if scoreboard_zoom_running:
		return

	scoreboard_zoom_running = true

	# KEEP FURNACE SCENE VISIBLE
	visible = true

	# SET THE SCORE FIRST
	$scoreboard/score_label.text = format_furnace_score(furnace_multiball_score)

	# START IN THE CENTRE
	$scoreboard.position = Vector2(960, 460)
	$scoreboard.scale = Vector2(0.01, 0.01)

	$scoreboard.visible = true

	# GROW INTO PLACE
	var grow_tween = create_tween()

	grow_tween.tween_property(
		$scoreboard,
		"scale",
		Vector2(1.80, 1.80),
		1.8
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	await grow_tween.finished

	# SETTLE TO FINAL SIZE
	var settle_tween = create_tween()

	settle_tween.tween_property(
		$scoreboard,
		"scale",
		Vector2(1.75, 1.75),
		0.8
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	await settle_tween.finished

	# HOLD
	await get_tree().create_timer(6.0).timeout

	# HIDE AFTER TEST
	$scoreboard.visible = false
	completed_logo.visible = false
	visible = false

	scoreboard_zoom_running = false

	print("FURNACE SCOREBOARD ZOOM TEST COMPLETE")

func play_furnace_completion_sequence():

	print("🔥 FURNACE COMPLETION SEQUENCE STARTED")

	visible = true

	$scoreboard.visible = false
	active_logo.visible = false
	ball1_locked.visible = false
	ball2_locked.visible = false
	ball3_locked.visible = false

	# COMPLETED LOGO
	await animate_completed_logo()

	# SCOREBOARD
	await test_scoreboard_zoom()

	print("🔥 FURNACE COMPLETION SEQUENCE COMPLETE")
