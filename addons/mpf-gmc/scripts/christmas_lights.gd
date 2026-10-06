extends Node2D

@export var min_brightness: float = 0.65
@export var max_brightness: float = 1.9
@export var min_speed: float = 1.5
@export var max_speed: float = 3.0

var lights = []


func _ready():

	# Find all Sprite2D bulbs
	for child in get_children():

		if child is Sprite2D:

			var light_data = {
				"node": child,
				"speed": randf_range(min_speed, max_speed),
				"offset": randf_range(0.0, TAU)
			}

			lights.append(light_data)


func _process(_delta):

	var time = Time.get_ticks_msec() / 1000.0

	for light_data in lights:

		var bulb = light_data["node"]
		var speed = light_data["speed"]
		var offset = light_data["offset"]

		var wave = (sin(time * speed + offset) + 1.0) / 2.0

		var brightness = lerp(
			min_brightness,
			max_brightness,
			wave
		)

		bulb.modulate.a = brightness
