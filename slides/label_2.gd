
extends Label

func _ready():
	visible = false
	
	#wait 8 seconds before first showing
	await get_tree() .create_timer(2.0).timeout
	visible = true
	#then blink every 0.3 second
	while true:
		await get_tree() .create_timer(0.5).timeout
		visible = !visible
	
