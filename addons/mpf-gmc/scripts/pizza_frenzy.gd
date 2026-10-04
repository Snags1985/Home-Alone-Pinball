extends Node2D
@onready var main_game_screen = get_parent().get_node("Main_Game_Screen")

var pizza_complete = false
var pizza_slices = 0
var p_collected = false
var i_collected = false
var z1_collected = false
var z2_collected = false
var a_collected = false
var pizza_ready = false
var active_logo = null
var logo_pulsing = false
var delivery_ramp_lit = false
var pizza_frenzy_active = false
var frenzy_time_remaining = 45
var frenzy_starting = false
var active_scene = null
var car_tween = null
var frenzy_finished = false
var delivery_progress = 0
var frenzy_multiplier = 2
var multiplier_tween = null
var pizza_ball_save_active = false
var wheel_spin_speed = 11.0
var callout_showing = false
var last_ball_saved_screen = 2
var combo_active = false
var combo_count = 0
var combo_timer = null
var pizza_frenzy_count = 0
var wheels_spinning = false
var final_receipt_position = Vector2.ZERO
var frenzy_score = 0
var base_score = 0
var delivery_bonus_total = 0
var multiplier_bonus_total = 0
var combo_bonus_total = 0
var jackpot_bonus_total = 0
var super_jackpot_bonus_total = 0



func _ready():

	show_pizza_box(0)
	
	$p_lit.visible = false
	$i_lit.visible = false
	$z1_lit.visible = false
	$z2_lit.visible = false
	$a_lit.visible = false

	$awesome.visible = false
	$perfect.visible = false
	$looking_good.visible = false
	$on_fire.visible = false

	$jackpot.visible = false
	$super_jackpot.visible = false

	show_status_logo("get_ready")

	$timer_label.visible = false
	$multiplier_label.visible = false
	$score_label.visible = false
	$score_popup.visible = false

	# Shared Pizza Frenzy HUD
	$pizza_frenzy_hud.visible = false

	# Final receipt
	final_receipt_position = $final_receipt.position
	$final_receipt.visible = false

	# Street scenes
	$street_scene_night.visible = false
	$street_scene_day.visible = false

	# Delivery car
	$delivery_car_container.visible = false
	
func show_status_logo(logo_name):

	print("Showing logo: ", logo_name)

	# Hide all logos first
	$get_ready.visible = false
	$nice_job.visible = false
	$great_work.visible = false
	$keep_going.visible = false
	$shoot_delivery_ramp.visible = false
	$pizza_frenzy.visible = false

	match logo_name:

		"get_ready":
			active_logo = $get_ready

		"nice_job":
			active_logo = $nice_job

		"great_work":
			active_logo = $great_work

		"keep_going":
			active_logo = $keep_going

		"shoot_delivery_ramp":
			active_logo = $shoot_delivery_ramp

		"pizza_frenzy":
			active_logo = $pizza_frenzy

	active_logo.visible = true

	logo_pulsing = true
	pulse_logo()

	print("get_ready: ", $get_ready.visible)
	print("nice_job: ", $nice_job.visible)
	print("great_work: ", $great_work.visible)
	print("keep_going: ", $keep_going.visible)
	print("shoot_delivery_ramp: ", $shoot_delivery_ramp.visible)
	print("pizza_frenzy: ", $pizza_frenzy.visible)
	
func hide_countdown():

	$frenzy_intro/countdown_3.visible = false
	$frenzy_intro/countdown_2.visible = false
	$frenzy_intro/countdown_1.visible = false
	$frenzy_intro/go.visible = false

func show_pizza_box(count):

	# Hide all pizza box states
	$slice_0.visible = false
	$slice_1.visible = false
	$slice_2.visible = false
	$slice_3.visible = false
	$slice_4.visible = false
	$slice_5.visible = false

	match count:
		0:
			$slice_0.visible = true
		1:
			$slice_1.visible = true
		2:
			$slice_2.visible = true
		3:
			$slice_3.visible = true
		4:
			$slice_4.visible = true
		5:
			$slice_5.visible = true

func light_letter(letter):

	match letter:

		"P":
			$p_lit.visible = true
			animate_letter($p_lit)

		"I":
			$i_lit.visible = true
			animate_letter($i_lit)

		"Z1":
			$z1_lit.visible = true
			animate_letter($z1_lit)

		"Z2":
			$z2_lit.visible = true
			animate_letter($z2_lit)

		"A":
			$a_lit.visible = true
			animate_letter($a_lit)
			
func animate_letter(letter_node):

	var original_scale = letter_node.scale

	var tween = create_tween()

	tween.tween_property(
		letter_node,
		"scale",
		original_scale * 1.3,
		0.1
	)

	tween.tween_property(
		letter_node,
		"scale",
		original_scale,
		0.1
	)

func animate_multiplier():

	# Stop any previous multiplier animation
	if multiplier_tween:
		multiplier_tween.kill()

	# Always start from the normal scale
	$multiplier_label.scale = Vector2(1.0, 1.0)

	multiplier_tween = create_tween()

	multiplier_tween.tween_property(
		$multiplier_label,
		"scale",
		Vector2(1.3, 1.3),
		0.1
	)

	multiplier_tween.tween_property(
		$multiplier_label,
		"scale",
		Vector2(1.0, 1.0),
		0.1
	)

	await multiplier_tween.finished

	multiplier_tween = null

func show_multiplier_popup():

	$multiplier_popup.text = "+" + str(frenzy_multiplier) + "X!"
	$multiplier_popup.visible = true

	var original_position = $multiplier_popup.position

	var tween = create_tween()

	tween.parallel().tween_property(
		$multiplier_popup,
		"position",
		original_position + Vector2(0, -50),
		0.6
	)

	tween.parallel().tween_property(
		$multiplier_popup,
		"modulate:a",
		0.0,
		0.6
	)

	await tween.finished

	$multiplier_popup.visible = false
	$multiplier_popup.modulate.a = 1.0
	$multiplier_popup.position = original_position

func show_score_popup(points):

	$score_popup.text = "+" + format_score(points)

	$score_popup.visible = true

	var original_position = $score_popup.position

	var tween = create_tween()

	tween.parallel().tween_property(
		$score_popup,
		"position",
		original_position + Vector2(0, -50),
		0.8
	)

	tween.parallel().tween_property(
		$score_popup,
		"modulate:a",
		0.0,
		0.8
	)

	await tween.finished

	$score_popup.visible = false
	$score_popup.modulate.a = 1.0
	$score_popup.position = original_position

func animate_pizza_ready():

	pizza_ready = true

	pulse_logo()
	
func pulse_logo():

	if active_logo == null:
		logo_pulsing = false
		return

	var logo = active_logo
	var original_scale = logo.scale

	var tween = create_tween()

	tween.tween_property(
		logo,
		"scale",
		original_scale * 1.15,
		0.3
	)

	tween.tween_property(
		logo,
		"scale",
		original_scale,
		0.3
	)

	tween.finished.connect(func():

		if logo == active_logo:
			pulse_logo()
	)

func reset_pizza_frenzy():
	
	# Hide final receipt
	$final_receipt.visible = false

	# Hide shared Pizza Frenzy HUD
	$pizza_frenzy_hud.visible = false

	# Hide all Pizza Frenzy visuals
	$street_scene_night.visible = false
	$street_scene_day.visible = false
	$delivery_car_container.visible = false

	$timer_label.visible = false
	$multiplier_label.visible = false

	$complete.visible = false
	$score_label.visible = false
	$score_popup.visible = false

	$frenzy_intro.visible = false

	hide_countdown()
	hide_intro_elements()

	pizza_ready = false
	pizza_complete = false
	delivery_ramp_lit = false
	
	pizza_slices = 0

	p_collected = false
	i_collected = false
	z1_collected = false
	z2_collected = false
	a_collected = false

	show_pizza_box(0)

	$p_lit.visible = false
	$i_lit.visible = false
	$z1_lit.visible = false
	$z2_lit.visible = false
	$a_lit.visible = false

	$complete.visible = false

	$p_grey.visible = true
	$i_grey.visible = true
	$z1_grey.visible = true
	$z2_grey.visible = true
	$a_grey.visible = true
	
	pizza_frenzy_active = false
	wheels_spinning = false
	frenzy_starting = false
	frenzy_finished = false
	pizza_ball_save_active = false
	
	$street_scene_night.visible = false
	$street_scene_day.visible = false
	$delivery_car_container.visible = false

	frenzy_time_remaining = 45
	frenzy_multiplier = 2

# Reset Pizza Frenzy scoring
	frenzy_score = 0
	base_score = 0
	delivery_bonus_total = 0
	multiplier_bonus_total = 0
	combo_bonus_total = 0
	jackpot_bonus_total = 0
	super_jackpot_bonus_total = 0

	show_status_logo("get_ready")

func _input(event):

	if event.is_action_pressed("ui_accept"):
		collect_letter("P")

	if event.is_action_pressed("ui_right"):
		collect_letter("I")

	if event.is_action_pressed("ui_left"):
		collect_letter("Z1")

	if event.is_action_pressed("ui_up"):
		collect_letter("Z2")

	if event.is_action_pressed("ui_down"):
		collect_letter("A")
		
	if event.is_action_pressed("ui_cancel"):
		reset_pizza_frenzy()
	
	if event.is_action_pressed("ui_page_up"):
		shoot_delivery_ramp()
		
	if event.is_action_pressed("ball_saved_test"):
		show_ball_saved()

func shoot_delivery_ramp():

	if pizza_frenzy_active:

		if frenzy_multiplier < 10:

			frenzy_multiplier += 1

			if frenzy_multiplier == 5:

				award_bonus(500000)

				await show_callout_once($jackpot)

			if frenzy_multiplier == 10:

				award_bonus(1000000)

				await show_callout_once($super_jackpot)

			$multiplier_label.text = str(frenzy_multiplier) + "X"

			# Match the timer's digital green
			$multiplier_label.modulate = Color(0.2, 0.8, 0.3, 1.0)

			animate_multiplier()
			show_multiplier_popup()

			# Delivery ramp scoring
			var delivery_points = 100000 * frenzy_multiplier

			frenzy_score += delivery_points
			delivery_bonus_total += delivery_points

			show_score_popup(delivery_points)

			$score_label.text = format_score(frenzy_score)

			register_combo()
			
			print("DELIVERY BONUS: ", delivery_bonus_total)
			print("FRENZY SCORE: ", frenzy_score)
			print("MULTIPLIER: ", frenzy_multiplier)

		return

	if !delivery_ramp_lit:
		return

	start_pizza_frenzy()
	
func start_pizza_frenzy():

	
	if pizza_frenzy_active:
		return
		
	visible = true
	main_game_screen.visible = false

	pizza_frenzy_count += 1

	frenzy_starting = true

	print("PIZZA FRENZY STARTING")

	show_status_logo("pizza_frenzy")

	start_sequence()
	
func start_sequence():

	hide_gameplay_elements()

	$frenzy_intro.visible = true
	$timer_label.modulate = Color.BLACK

	hide_intro_elements()

	# Show big Pizza Frenzy logo
	$frenzy_intro/pizza_frenzy_big.visible = true

	var logo = $frenzy_intro/pizza_frenzy_big

	logo.scale = Vector2(0.1, 0.1)

	var tween = create_tween()

	tween.tween_property(
		logo,
		"scale",
		Vector2(1.0, 1.0),
		0.5
	)

	await tween.finished

	await pulse_once(logo)
	await pulse_once(logo)

	await get_tree().create_timer(0.5).timeout

	# Hide logo before countdown
	$frenzy_intro/pizza_frenzy_big.visible = false

	hide_countdown()
	$frenzy_intro/countdown_3.visible = true

	await get_tree().create_timer(1.0).timeout

	hide_countdown()
	$frenzy_intro/countdown_2.visible = true

	await get_tree().create_timer(1.0).timeout

	hide_countdown()
	$frenzy_intro/countdown_1.visible = true

	await get_tree().create_timer(1.0).timeout

	hide_countdown()
	$frenzy_intro/go.visible = true

	await get_tree().create_timer(1.0).timeout

	hide_countdown()
	$frenzy_intro.visible = false
	
	start_delivery_run()
	frenzy_time_remaining = 45

	# Show shared Pizza Frenzy HUD
	$pizza_frenzy_hud.visible = true

	$timer_label.modulate = Color.BLACK
	$timer_label.scale = Vector2(1.0, 1.0)

	$timer_label.visible = true
	$timer_label.text = "00:%02d" % frenzy_time_remaining

	pizza_frenzy_active = true
	delivery_ramp_lit = false
	frenzy_starting = false
	frenzy_score = 0
	
	delivery_bonus_total = 0
	multiplier_bonus_total = 0
	combo_bonus_total = 0
	jackpot_bonus_total = 0
	super_jackpot_bonus_total = 0
	
	$score_label.text = format_score(0)
	$score_label.visible = true
	
	pizza_ball_save_active = true

	frenzy_multiplier = 2
	$multiplier_label.modulate = Color(0.2, 0.8, 0.3, 1.0)
	$multiplier_label.text = str(frenzy_multiplier) + "X"
	$multiplier_label.visible = true

	frenzy_countdown()
	
func start_delivery_run():

	print("START DELIVERY RUN")

	if pizza_frenzy_count % 2 == 1:
		active_scene = $street_scene_night/street_scene_night
		$street_scene_night.visible = true
		$street_scene_day.visible = false
		print("Using NIGHT scene")
	else:
		active_scene = $street_scene_day/street_scene_day
		$street_scene_night.visible = false
		$street_scene_day.visible = true
		print("Using DAY scene")

	$delivery_car_container.visible = true

	# Put car at shop
	$delivery_car_container/pizza_car.global_position = Vector2(350, 948)
	print("Car X = ", $delivery_car_container/pizza_car.global_position.x)
	print("Car Y = ", $delivery_car_container/pizza_car.global_position.y)

	# Reset street position
	active_scene.position.x = 488.941

	# Pause for 2 seconds so player sees the pizza shop
	await get_tree().create_timer(2.0).timeout
	
	# Start wheel animation
	wheels_spinning = true

	# Scroll street for 15 seconds
	var scroll_tween = create_tween()

	scroll_tween.tween_property(
		active_scene,
		"position:x",
		-489.059,
		15.0
	)

	# Wait until scrolling finishes
	await scroll_tween.finished
	print("House after scroll = ",
	active_scene.get_node("house_marker").global_position)

	print("Car after scroll = ",
	$delivery_car_container/pizza_car.global_position)

	# Drive to house
	car_tween = create_tween()

	car_tween.tween_property(
		$delivery_car_container/pizza_car,
		"global_position",
		active_scene.get_node("house_marker").global_position,
		28.0
	)
	
func _process(delta):

	if wheels_spinning:

		$delivery_car_container/pizza_car/front_wheel.rotation += 6.0 * delta

		$delivery_car_container/pizza_car/rear_wheel.rotation += 6.0 * delta
	
func pulse_once(node):

	node.visible = true

	var original_scale = node.scale

	var tween = create_tween()

	tween.tween_property(
		node,
		"scale",
		original_scale * 1.1,
		0.2
	)

	tween.tween_property(
		node,
		"scale",
		original_scale,
		0.2
	)

	await tween.finished

	node.visible = false

func frenzy_countdown():

	# Normal timer colour
	$timer_label.modulate = Color(0.2, 0.8, 0.3, 1.0)

	while frenzy_time_remaining > 0:

		$timer_label.text = "00:%02d" % frenzy_time_remaining

		if frenzy_time_remaining <= 10:
			$timer_label.modulate = Color(0.766, 0.006, 0.01, 1.0)

			var tween = create_tween()

			tween.tween_property(
				$timer_label,
				"scale",
				Vector2(1.1, 1.1),
				0.15
			)

			tween.tween_property(
				$timer_label,
				"scale",
				Vector2(1.0, 1.0),
				0.15
			)

		await get_tree().create_timer(1.0).timeout

		frenzy_time_remaining -= 1

	$timer_label.text = "00:00"

	complete_pizza_frenzy()
	
func start_timer_warning():

	while frenzy_time_remaining > 0:

		var shake_amount = 3

		if frenzy_time_remaining <= 5:
			shake_amount = 6

		var original_pos = $timer_label.position

		$timer_label.position = original_pos + Vector2(-shake_amount, 0)

		await get_tree().create_timer(0.05).timeout

		$timer_label.position = original_pos + Vector2(shake_amount, 0)

		await get_tree().create_timer(0.05).timeout

		$timer_label.position = original_pos

		await get_tree().create_timer(0.1).timeout
	
func collect_letter(letter):

	match letter:

		"P":
			if p_collected:
				return
			p_collected = true

		"I":
			if i_collected:
				return
			i_collected = true

		"Z1":
			if z1_collected:
				return
			z1_collected = true

		"Z2":
			if z2_collected:
				return
			z2_collected = true

		"A":
			if a_collected:
				return
			a_collected = true

	light_letter(letter)

	pizza_slices += 1

	show_pizza_box(pizza_slices)
	
	match pizza_slices:

		1:
			show_status_logo("nice_job")

		2:
			show_status_logo("great_work")

		3:
			show_status_logo("keep_going")

		4:
			show_status_logo("great_work")

		5:
			show_status_logo("shoot_delivery_ramp")
	
	if pizza_slices == 5:
		pizza_complete = true
		delivery_ramp_lit = true

		print("PIZZA COMPLETE")
		print("DELIVERY RAMP LIT")

		animate_pizza_ready()
		main_game_screen.complete_pizza_collection()
	
func hide_gameplay_elements():

	# Pizza box
	$slice_0.visible = false
	$slice_1.visible = false
	$slice_2.visible = false
	$slice_3.visible = false
	$slice_4.visible = false
	$slice_5.visible = false

	# Pizza letters
	$p_grey.visible = false
	$p_lit.visible = false

	$i_grey.visible = false
	$i_lit.visible = false

	$z1_grey.visible = false
	$z1_lit.visible = false

	$z2_grey.visible = false
	$z2_lit.visible = false

	$a_grey.visible = false
	$a_lit.visible = false

	# Status logos
	$get_ready.visible = false
	$nice_job.visible = false
	$great_work.visible = false
	$keep_going.visible = false
	$shoot_delivery_ramp.visible = false
	$pizza_frenzy.visible = false
		
func hide_intro_elements():

	$frenzy_intro/pizza_frenzy_big.visible = false
	$frenzy_intro/countdown_3.visible = false
	$frenzy_intro/countdown_2.visible = false
	$frenzy_intro/countdown_1.visible = false
	$frenzy_intro/go.visible = false

func format_score(score):

	var s = str(score)
	var result = ""

	while s.length() > 3:
		result = "," + s.substr(s.length() - 3, 3) + result
		s = s.substr(0, s.length() - 3)

	return s + result

func add_frenzy_score(base_value):

	var points = base_value * frenzy_multiplier

	# Calculate the extra points created by the multiplier
	var multiplier_bonus = points - base_value

	# Add the full amount to the overall Pizza Frenzy score
	frenzy_score += points

	# Track the original scoring separately
	base_score += base_value

	# Track only the extra points created by the multiplier
	multiplier_bonus_total += multiplier_bonus

	show_score_popup(points)
	
	$score_label.text = format_score(frenzy_score)

	print("FRENZY SCORE: ", frenzy_score)
	print("BASE SCORE: ", base_score)
	print("MULTIPLIER BONUS: ", multiplier_bonus_total)

func award_bonus(points):

	frenzy_score += points

	# Track jackpot bonuses separately
	if points == 500000:

		jackpot_bonus_total += points

	elif points == 1000000:

		super_jackpot_bonus_total += points

	show_score_popup(points)

	$score_label.text = format_score(frenzy_score)

	print("BONUS AWARDED: ", points)
	print("FRENZY SCORE: ", frenzy_score)
	print("JACKPOT BONUS: ", jackpot_bonus_total)
	print("SUPER JACKPOT: ", super_jackpot_bonus_total)

func show_ball_saved():

	var screen

	if last_ball_saved_screen == 1:
		screen = $ball_saved_2
		$ball_saved_2_audio.play()
		last_ball_saved_screen = 2
	else:
		screen = $ball_saved_1
		$ball_saved_1_audio.play()
		last_ball_saved_screen = 1

	screen.visible = true

	var final_position = screen.position

	# Start above the screen
	screen.position = final_position + Vector2(0, -1000)

	var tween = create_tween()

	# Slide into centre
	tween.tween_property(
		screen,
		"position",
		final_position,
		0.3
	)

	await tween.finished

	# Hold on screen
	await get_tree().create_timer(1.2).timeout

	# Slide back out
	var exit_tween = create_tween()

	exit_tween.tween_property(
		screen,
		"position",
		final_position + Vector2(0, -1000),
		0.3
	)

	await exit_tween.finished

	screen.visible = false

	# Reset for next time
	screen.position = final_position

func complete_pizza_frenzy():

	if frenzy_finished:
		return

	frenzy_finished = true

	print("PIZZA FRENZY COMPLETE")

	if car_tween:
		car_tween.kill()
		
	wheels_spinning = false

	# Timer has reached zero
	$timer_label.text = "00:00"
	$timer_label.visible = false

	# Hide the normal Pizza Frenzy HUD
	$pizza_frenzy_hud.visible = false

	# Hide active gameplay score elements
	$score_label.visible = false
	$score_popup.visible = false
	$multiplier_label.visible = false

	# Make sure the old completion logo is hidden
	$complete.visible = false

	# Keep the street scene and car visible
	# The final receipt will appear over them

	await show_final_receipt()

	# Give the player time to read the results
	await get_tree().create_timer(8.0).timeout

	# Reset everything after the receipt
	reset_pizza_frenzy()

	# Return to the Main Game Screen
	visible = false
	main_game_screen.visible = true

	# Hide any active Main Game Screen board
	main_game_screen.hide_active_board()

func show_combo_callout():

	match combo_count:

		2:
			await show_callout_once($looking_good)

		3:
			await show_callout_once($awesome)

		4:
			await show_callout_once($perfect)

		_:
			if combo_count >= 5:
				await show_callout_once($on_fire)

func show_callout_once(node):

	# Hide only the Pizza Frenzy logo
	$pizza_frenzy_hud/pizza_frenzy_logo.visible = false

	node.visible = true

	var original_scale = node.scale

	var tween = create_tween()

	tween.tween_property(
		node,
		"scale",
		original_scale * 1.1,
		0.2
	)

	tween.tween_property(
		node,
		"scale",
		original_scale,
		0.2
	)

	await tween.finished

	await get_tree().create_timer(0.5).timeout

	node.visible = false

	# Show Pizza Frenzy logo again
	if pizza_frenzy_active:
		$pizza_frenzy_hud/pizza_frenzy_logo.visible = true

func register_combo():

	if combo_active:

		combo_count += 1

		print("COMBO x", combo_count)

		var combo_points = combo_count * 10000
		var combo_points_with_multiplier = combo_points * frenzy_multiplier

		# Track the actual points earned from the combo
		combo_bonus_total += combo_points_with_multiplier

		# Add combo points to the overall Frenzy score
		frenzy_score += combo_points_with_multiplier

		show_score_popup(combo_points_with_multiplier)

		$score_label.text = format_score(frenzy_score)

		print("COMBO BONUS: ", combo_bonus_total)
		print("FRENZY SCORE: ", frenzy_score)

		await show_combo_callout()

	else:

		combo_active = true
		combo_count = 1

		print("COMBO STARTED")

	if combo_timer:
		combo_timer.stop()

	combo_timer = Timer.new()

	add_child(combo_timer)

	combo_timer.wait_time = 3.0
	combo_timer.one_shot = true

	combo_timer.timeout.connect(end_combo)

	combo_timer.start()

func animate_receipt_row(label_node, value_node):

	label_node.visible = true
	value_node.visible = true

	label_node.modulate.a = 0.0
	value_node.modulate.a = 0.0

	label_node.scale = Vector2(0.8, 0.8)
	value_node.scale = Vector2(0.8, 0.8)

	var row_tween = create_tween()

	row_tween.parallel().tween_property(
		label_node,
		"modulate:a",
		1.0,
		0.25
	)

	row_tween.parallel().tween_property(
		value_node,
		"modulate:a",
		1.0,
		0.25
	)

	row_tween.parallel().tween_property(
		label_node,
		"scale",
		Vector2(1.0, 1.0),
		0.25
	)

	row_tween.parallel().tween_property(
		value_node,
		"scale",
		Vector2(1.0, 1.0),
		0.25
	)

	await row_tween.finished

func show_final_receipt():

	$final_receipt.visible = true

	# Hide all receipt score lines before the receipt appears

	$final_receipt/base_score_label.visible = false
	$final_receipt/base_score_value.visible = false

	$final_receipt/delivery_bonus_label.visible = false
	$final_receipt/delivery_bonus_value.visible = false

	$final_receipt/multiplier_bonus_label.visible = false
	$final_receipt/multiplier_bonus_value.visible = false

	$final_receipt/combo_bonus_label.visible = false
	$final_receipt/combo_bonus_value.visible = false

	$final_receipt/jackpot_bonus_label.visible = false
	$final_receipt/jackpot_bonus_value.visible = false

	$final_receipt/super_jackpot_bonus_label.visible = false
	$final_receipt/super_jackpot_bonus_value.visible = false
	
	$final_receipt/final_total_label.visible = false
	$final_receipt/final_total_value.visible = false


	# --------------------------------
	# FINAL RECEIPT VALUES
	# --------------------------------

	$final_receipt/base_score_label.text = "BASE SCORE"
	$final_receipt/base_score_value.text = format_score(base_score)

	$final_receipt/delivery_bonus_label.text = "DELIVERY BONUS"
	$final_receipt/delivery_bonus_value.text = format_score(delivery_bonus_total)

	$final_receipt/multiplier_bonus_label.text = "MULTIPLIER BONUS"
	$final_receipt/multiplier_bonus_value.text = format_score(multiplier_bonus_total)

	$final_receipt/combo_bonus_label.text = "COMBO BONUS"
	$final_receipt/combo_bonus_value.text = format_score(combo_bonus_total)

	$final_receipt/jackpot_bonus_label.text = "JACKPOT BONUS"
	$final_receipt/jackpot_bonus_value.text = format_score(jackpot_bonus_total)

	$final_receipt/super_jackpot_bonus_label.text = "SUPER JACKPOT"
	$final_receipt/super_jackpot_bonus_value.text = format_score(super_jackpot_bonus_total)


	# --------------------------------
	# RECEIPT ENTRANCE
	# --------------------------------

	$final_receipt.position = final_receipt_position + Vector2(0, 1200)

	var receipt_tween = create_tween()

	receipt_tween.set_trans(Tween.TRANS_QUAD)
	receipt_tween.set_ease(Tween.EASE_OUT)

	receipt_tween.tween_property(
		$final_receipt,
		"position",
		final_receipt_position,
		1.0
	)

	await receipt_tween.finished

	print("FINAL RECEIPT ON SCREEN")


	# Small pause before printing
	await get_tree().create_timer(0.5).timeout


	# --------------------------------
	# BASE SCORE
	# --------------------------------

	await animate_receipt_row(
		$final_receipt/base_score_label,
		$final_receipt/base_score_value
	)

	await get_tree().create_timer(0.4).timeout


	# --------------------------------
	# DELIVERY BONUS
	# --------------------------------

	await animate_receipt_row(
		$final_receipt/delivery_bonus_label,
		$final_receipt/delivery_bonus_value
	)

	await get_tree().create_timer(0.4).timeout


	# --------------------------------
	# MULTIPLIER BONUS
	# --------------------------------

	await animate_receipt_row(
		$final_receipt/multiplier_bonus_label,
		$final_receipt/multiplier_bonus_value
	)

	await get_tree().create_timer(0.4).timeout


	# --------------------------------
	# COMBO BONUS
	# --------------------------------

	await animate_receipt_row(
		$final_receipt/combo_bonus_label,
		$final_receipt/combo_bonus_value
	)


	# Pause between normal scoring
	# and special bonuses
	await get_tree().create_timer(0.8).timeout


	# --------------------------------
	# JACKPOT BONUS
	# --------------------------------

	await animate_receipt_row(
		$final_receipt/jackpot_bonus_label,
		$final_receipt/jackpot_bonus_value
	)

	await get_tree().create_timer(0.4).timeout


	# --------------------------------
	# SUPER JACKPOT
	# --------------------------------

	await animate_receipt_row(
		$final_receipt/super_jackpot_bonus_label,
		$final_receipt/super_jackpot_bonus_value
	)

	await get_tree().create_timer(0.8).timeout


	# --------------------------------
	# FINAL FRENZY SCORE
	# --------------------------------

	$final_receipt/final_total_label.text = "FRENZY SCORE"
	$final_receipt/final_total_value.text = format_score(frenzy_score)

	await animate_receipt_row(
		$final_receipt/final_total_label,
		$final_receipt/final_total_value
	)

	await get_tree().create_timer(0.8).timeout

	print("ALL RECEIPT SCORES DISPLAYED")

func end_combo():

	print("COMBO ENDED")

	combo_active = false
	combo_count = 0

	if combo_timer:
		combo_timer.queue_free()
		combo_timer = null
