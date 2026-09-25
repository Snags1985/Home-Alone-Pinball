extends Node2D

var pizza_slices = 0
var p_collected = false
var i_collected = false
var z1_collected = false
var z2_collected = false
var a_collected = false

func _ready():

	# Start with empty pizza box
	show_pizza_box(0)

	# Hide all lit letters
	$p_lit.visible = false
	$i_lit.visible = false
	$z1_lit.visible = false
	$z2_lit.visible = false
	$a_lit.visible = false


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
		"I":
			$i_lit.visible = true
		"Z1":
			$z1_lit.visible = true
		"Z2":
			$z2_lit.visible = true
		"A":
			$a_lit.visible = true
			


func reset_pizza_frenzy():

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
	
	if pizza_slices == 5:
		print("PIZZA COMPLETE")
	
		
