extends PointLight2D

@export var min_energy := 0.55
@export var max_energy := 1.30
@export var flicker_speed := 6.5

var target_energy := 0.9


func _ready():
	randomize()
	energy = target_energy
	_pick_new_flicker()


func _process(delta):
	energy = lerp(
		energy,
		target_energy,
		delta * flicker_speed
	)

	if abs(energy - target_energy) < 0.02:
		_pick_new_flicker()


func _pick_new_flicker():
	target_energy = randf_range(min_energy, max_energy)
