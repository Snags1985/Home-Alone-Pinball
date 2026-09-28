extends Node2D

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
var pizza_ball_save_active = false
var frenzy_score = 0
var wheel_spin_speed = 11.0
var callout_showing = false
var last_ball_saved_screen = 2
var combo_active = false
var combo_count = 0
var combo_timer = null
var pizza_frenzy_count = 0
var wheels_spinning = false

func _ready():

	# Start with empty pizza box
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

	# Hide frenzy visuals
	$street_scene_night.visible = false
	$street_scene_day.visible = false
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
	

	var original_scale = $multiplier_label.scale

	var tween = create_tween()

	tween.tween_property(
		$multiplier_label,
		"scale",
		original_scale * 1.3,
		0.1
	)

	tween.tween_property(
		$multiplier_label,
		"scale",
		original_scale,
		0.1
	)

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
	
	show_status_logo("get_ready")
			
 #tempory input values to test the PIZZA word lighting up
		   
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

			animate_multiplier()
			show_multiplier_popup()

			add_frenzy_score(100000)
			register_combo()
			
			print("MULTIPLIER: ", frenzy_multiplier)

		return

	if !delivery_ramp_lit:
		return

	start_pizza_frenzy()
	
func start_pizza_frenzy():

	if pizza_frenzy_active:
		return

	pizza_frenzy_count += 1

	frenzy_starting = true

	print("PIZZA FRENZY STARTING")

	show_status_logo("pizza_frenzy")

	start_sequence()
	
func start_sequence():

	hide_gameplay_elements()

	$frenzy_intro.visible = true

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
	$timer_label.visible = true
	$timer_label.text = str(frenzy_time_remaining)

	pizza_frenzy_active = true
	delivery_ramp_lit = false
	frenzy_starting = false
	frenzy_score = 0
	$score_label.text = format_score(0)
	$score_label.visible = true
	
	pizza_ball_save_active = true

	frenzy_multiplier = 2
	$multiplier_label.text = str(frenzy_multiplier) + "X"
	$multiplier_label.visible = true

	frenzy_time_remaining = 45

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

	while frenzy_time_remaining > 0:

		await get_tree().create_timer(1.0).timeout

		frenzy_time_remaining -= 1
		$timer_label.text = str(frenzy_time_remaining)

		print(frenzy_time_remaining)

	complete_pizza_frenzy()
	
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

	frenzy_score += points

	show_score_popup(points)
	
	$score_label.text = format_score(frenzy_score)

	print("FRENZY SCORE: ", frenzy_score)

func award_bonus(points):

	frenzy_score += points

	show_score_popup(points)

	$score_label.text = format_score(frenzy_score)

	print("BONUS AWARDED: ", points)
	print("FRENZY SCORE: ", frenzy_score)

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
	
	# Leave the scene visible for a moment
	await get_tree().create_timer(2.0).timeout

	# Hide all mode visuals
	$street_scene_night.visible = false
	$street_scene_day.visible = false
	$delivery_car_container.visible = false
	$timer_label.visible = false
	$multiplier_label.visible = false
	$score_label.visible = false
		
	# Show complete logo
	$complete.visible = true

	await pulse_once($complete)
	await pulse_once($complete)
	await pulse_once($complete)

	$complete.visible = false
	
	frenzy_multiplier = 2
	reset_pizza_frenzy()

	frenzy_finished = false
	pizza_ball_save_active = false

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

func delivery_ramp_shot():

	if !pizza_frenzy_active:
		return

	add_frenzy_score(25000)

	
func register_combo():

	if combo_active:

		combo_count += 1

		print("COMBO x", combo_count)

		add_frenzy_score(combo_count * 10000)

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

func end_combo():

	print("COMBO ENDED")

	combo_active = false
	combo_count = 0

	if combo_timer:
		combo_timer.queue_free()
		combo_timer = null
