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

func _ready():

	# Start with empty pizza box
	show_pizza_box(0)
	
	$p_lit.visible = false
	$i_lit.visible = false
	$z1_lit.visible = false
	$z2_lit.visible = false
	$a_lit.visible = false

	show_status_logo("get_ready")
	
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
	pizza_ready = false
	pizza_complete = false

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
		print("PIZZA COMPLETE")
		animate_pizza_ready()
	
		
