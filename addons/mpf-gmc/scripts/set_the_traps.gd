extends Node2D

# ==============================================================================
# Video Files
# ==============================================================================
const HEAVY_CANS_VIDEO = preload("res://addons/mpf-gmc/videos/heavy_cans.ogv")
const ORNAMINTS_VIDEO = preload("res://addons/mpf-gmc/videos/ornamints.ogv")
const MICRO_MACHINES_VIDEO = preload("res://addons/mpf-gmc/videos/micro_machines.ogv")
const FAN_FEATHERS_VIDEO = preload("res://addons/mpf-gmc/videos/fan_feathers.ogv")
const DOOR_HANDLE_VIDEO = preload("res://addons/mpf-gmc/videos/door_handle.ogv")
const FRONT_ICE_VIDEO = preload("res://addons/mpf-gmc/videos/front_ice.ogv")
const REAR_ICE_VIDEO = preload("res://addons/mpf-gmc/videos/rear_ice.ogv")
const GLUE_VIDEO = preload("res://addons/mpf-gmc/videos/glue.ogv")
const TAR_VIDEO = preload("res://addons/mpf-gmc/videos/tar.ogv")

# ==============================================================================

@onready var battle_plan = $BattlePlan
@onready var tv_screen = get_node_or_null("../Main_Game_Screen/video_tv/ColorRect")
@onready var tv_content = get_node_or_null("../Main_Game_Screen/video_tv/TV_Content")

@onready var trap_heavy_cans = $Trap_HeavyCans
@onready var heavy_cans = $Trap_HeavyCans/heavy_cans
@onready var word_heavy_cans = $Trap_HeavyCans/word_heavy_cans

@onready var trap_ornamints = $Trap_Ornamints
@onready var ornamints = $Trap_Ornamints/ornamints
@onready var word_ornamints = $Trap_Ornamints/word_ornamints

@onready var trap_micro_machines = $Trap_MicroMachines
@onready var micro_machines = $Trap_MicroMachines/micro_machines
@onready var word_micro_machines = $Trap_MicroMachines/word_micro_machines

@onready var trap_fan_feathers = $Trap_FanFeathers
@onready var fan_feathers = $Trap_FanFeathers/fan_feathers
@onready var word_fan_feathers = $Trap_FanFeathers/word_fan_feathers

@onready var trap_door_handle = $Trap_DoorHandle
@onready var door_handle = $Trap_DoorHandle/door_handle
@onready var word_door_handle = $Trap_DoorHandle/word_door_handle

@onready var trap_front_ice = $Trap_FrontIce
@onready var front_ice = $Trap_FrontIce/front_ice
@onready var word_front_ice = $Trap_FrontIce/word_front_ice

@onready var trap_rear_ice = $Trap_RearIce
@onready var rear_ice = $Trap_RearIce/rear_ice
@onready var word_rear_ice = $Trap_RearIce/word_rear_ice

@onready var trap_glue = $Trap_Glue
@onready var glue = $Trap_Glue/glue
@onready var word_glue = $Trap_Glue/word_glue

@onready var trap_fire = $Trap_Fire
@onready var fire = $Trap_Fire/fire
@onready var word_fire = $Trap_Fire/word_fire

@onready var trap_tar = $Trap_Tar
@onready var tar = $Trap_Tar/tar
@onready var word_tar = $Trap_Tar/word_tar

var heavy_cans_word_base_scale = Vector2.ONE
var heavy_cans_word_pulse_tween: Tween
var ornamints_word_base_scale = Vector2.ONE
var ornamints_word_pulse_tween: Tween
var micro_machines_word_base_scale = Vector2.ONE
var micro_machines_word_pulse_tween: Tween
var fan_feathers_word_base_scale = Vector2.ONE
var fan_feathers_word_pulse_tween: Tween
var door_handle_word_base_scale = Vector2.ONE
var door_handle_word_pulse_tween: Tween
var front_ice_word_base_scale = Vector2.ONE
var front_ice_word_pulse_tween: Tween
var rear_ice_word_base_scale = Vector2.ONE
var rear_ice_word_pulse_tween: Tween
var glue_word_base_scale = Vector2.ONE
var glue_word_pulse_tween: Tween
var fire_word_base_scale = Vector2.ONE
var fire_word_pulse_tween: Tween
var tar_word_base_scale = Vector2.ONE
var tar_word_pulse_tween: Tween


var trap_sequence_running = false
var trap_queue: Array[String] = []
var traps_completed: Array[String] = []

func request_trap(trap_name: String):
	# Ignore the trap if it has already been completed
	if trap_name in traps_completed:
		print("TRAP ALREADY COMPLETED: ", trap_name)
		return

	# Ignore the trap if it is already waiting in the queue
	if trap_name in trap_queue:
		print("TRAP ALREADY QUEUED: ", trap_name)
		return

	# Mark the trap as completed immediately
	traps_completed.append(trap_name)

	# Add the trap to the queue
	trap_queue.append(trap_name)

	print("TRAP QUEUED: ", trap_name)

	# Only start the queue processor if it isn't already running
	if not trap_sequence_running:
		process_trap_queue()


func process_trap_queue():
	if trap_sequence_running:
		return

	trap_sequence_running = true

	while trap_queue.size() > 0:
		var next_trap = trap_queue.pop_front()

		print("TRAP STARTING: ", next_trap)

		match next_trap:
			"heavy_cans":
				await set_heavy_cans()
			"ornamints":
				await set_ornamints()
			"micro_machines":
				await set_micro_machines()
			"fan_feathers":
				await set_fan_feathers()
			"door_handle":
				await set_door_handle()
			"front_ice":
				await set_front_ice()
			"rear_ice":
				await set_rear_ice()
			"glue":
				await set_glue()
			"fire":
				await set_fire()
			"tar":
				await set_tar()

	trap_sequence_running = false
	print("TRAP QUEUE EMPTY")

	if traps_completed.size() == 10:
		print("SET THE TRAPS: COMPLETE")

		var main_screen = $"../Main_Game_Screen"
		main_screen.set_traps_mission_status = "COMPLETE"
		main_screen.update_mission_board()

func _ready():
	# Set the entire mode hidden when the game loads
	visible = false

	# Hide all trap artwork
	$Trap_HeavyCans.visible = false
	$Trap_Ornamints.visible = false
	$Trap_MicroMachines.visible = false
	$Trap_Tar.visible = false
	$Trap_DoorHandle.visible = false
	$Trap_FanFeathers.visible = false
	$Trap_Glue.visible = false
	$Trap_Fire.visible = false
	$Trap_RearIce.visible = false
	$Trap_FrontIce.visible = false


	heavy_cans_word_base_scale = word_heavy_cans.scale
	ornamints_word_base_scale = word_ornamints.scale
	micro_machines_word_base_scale = word_micro_machines.scale
	fan_feathers_word_base_scale = word_fan_feathers.scale
	door_handle_word_base_scale = word_door_handle.scale
	front_ice_word_base_scale = word_front_ice.scale
	rear_ice_word_base_scale = word_rear_ice.scale
	glue_word_base_scale = word_glue.scale
	fire_word_base_scale = word_fire.scale
	tar_word_base_scale = word_tar.scale
	
	# Keep the plan hidden until the mode starts
	battle_plan.visible = false

func start_set_the_traps():
	traps_completed.clear()
	trap_queue.clear()
	trap_sequence_running = false

	print("SET THE TRAPS: MODE ACTIVE")

	if battle_plan.get_parent() != self:
		battle_plan.reparent(self, true)
		
	visible = true

	# Start with the empty plan
	battle_plan.visible = true

	# Full-screen starting position
	battle_plan.position = Vector2(
		get_viewport_rect().size.x / 2.0,
		get_viewport_rect().size.y / 2.0
	)

	var viewport_size = get_viewport_rect().size
	var texture_size = battle_plan.texture.get_size()

	var scale_x = viewport_size.x / texture_size.x
	var scale_y = viewport_size.y / texture_size.y

	var full_screen_scale = min(scale_x, scale_y)

	battle_plan.scale = Vector2(
		full_screen_scale,
		full_screen_scale
	)

	# Give the player time to see the empty plan
	await get_tree().create_timer(3.0).timeout

	# Bring the TV down onto the screen
	var main_screen = $"../Main_Game_Screen"

	main_screen.set_traps_mission_status = "ACTIVE"
	main_screen.update_mission_board()

	main_screen.show_video_tv(false)

	# Wait for the TV to finish dropping down
	await get_tree().create_timer(0.8).timeout

	# Now move the Battle Plan into the TV
	await move_plan_to_tv()

func animate_heavy_cans_word():
	# Stop any previous pulse
	if heavy_cans_word_pulse_tween != null:
		heavy_cans_word_pulse_tween.kill()

	# Start slightly smaller for the pop
	word_heavy_cans.scale = heavy_cans_word_base_scale * 0.6

	# Initial pop
	var pop_tween = create_tween()

	pop_tween.tween_property(
		word_heavy_cans,
		"scale",
		heavy_cans_word_base_scale * 1.12,
		0.22
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	pop_tween.tween_property(
		word_heavy_cans,
		"scale",
		heavy_cans_word_base_scale,
		0.16
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	await pop_tween.finished

	# Gentle continuous pulse
	heavy_cans_word_pulse_tween = create_tween()
	heavy_cans_word_pulse_tween.set_loops()

	heavy_cans_word_pulse_tween.tween_property(
		word_heavy_cans,
		"scale",
		heavy_cans_word_base_scale * 1.04,
		1.2
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	heavy_cans_word_pulse_tween.tween_property(
		word_heavy_cans,
		"scale",
		heavy_cans_word_base_scale,
		1.2
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func animate_ornamints_word():
	# Stop any previous pulse
	if ornamints_word_pulse_tween != null:
		ornamints_word_pulse_tween.kill()

	# Start slightly smaller for the pop
	word_ornamints.scale = ornamints_word_base_scale * 0.6

	# Initial pop
	var pop_tween = create_tween()

	pop_tween.tween_property(
		word_ornamints,
		"scale",
		ornamints_word_base_scale * 1.12,
		0.22
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	pop_tween.tween_property(
		word_ornamints,
		"scale",
		ornamints_word_base_scale,
		0.16
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	await pop_tween.finished

	# Gentle continuous pulse
	ornamints_word_pulse_tween = create_tween()
	ornamints_word_pulse_tween.set_loops()

	ornamints_word_pulse_tween.tween_property(
		word_ornamints,
		"scale",
		ornamints_word_base_scale * 1.04,
		1.2
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	ornamints_word_pulse_tween.tween_property(
		word_ornamints,
		"scale",
		ornamints_word_base_scale,
		1.2
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func animate_micro_machines_word():
	# Stop any previous pulse
	if micro_machines_word_pulse_tween != null:
		micro_machines_word_pulse_tween.kill()

	# Start slightly smaller for the pop
	word_micro_machines.scale = micro_machines_word_base_scale * 0.6

	# Initial pop
	var pop_tween = create_tween()

	pop_tween.tween_property(
		word_micro_machines,
		"scale",
		micro_machines_word_base_scale * 1.12,
		0.22
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	pop_tween.tween_property(
		word_micro_machines,
		"scale",
		micro_machines_word_base_scale,
		0.16
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	await pop_tween.finished

	# Gentle continuous pulse
	micro_machines_word_pulse_tween = create_tween()
	micro_machines_word_pulse_tween.set_loops()

	micro_machines_word_pulse_tween.tween_property(
		word_micro_machines,
		"scale",
		micro_machines_word_base_scale * 1.04,
		1.2
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	micro_machines_word_pulse_tween.tween_property(
		word_micro_machines,
		"scale",
		micro_machines_word_base_scale,
		1.2
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func animate_fan_feathers_word():
	# Stop any previous pulse
	if fan_feathers_word_pulse_tween != null:
		fan_feathers_word_pulse_tween.kill()

	# Start slightly smaller for the pop
	word_fan_feathers.scale = fan_feathers_word_base_scale * 0.6

	# Initial pop
	var pop_tween = create_tween()

	pop_tween.tween_property(
		word_fan_feathers,
		"scale",
		fan_feathers_word_base_scale * 1.12,
		0.22
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	pop_tween.tween_property(
		word_fan_feathers,
		"scale",
		fan_feathers_word_base_scale,
		0.16
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	await pop_tween.finished

	# Gentle continuous pulse
	fan_feathers_word_pulse_tween = create_tween()
	fan_feathers_word_pulse_tween.set_loops()

	fan_feathers_word_pulse_tween.tween_property(
		word_fan_feathers,
		"scale",
		fan_feathers_word_base_scale * 1.04,
		1.2
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	fan_feathers_word_pulse_tween.tween_property(
		word_fan_feathers,
		"scale",
		fan_feathers_word_base_scale,
		1.2
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func animate_door_handle_word():
	# Stop any previous pulse
	if door_handle_word_pulse_tween != null:
		door_handle_word_pulse_tween.kill()

	# Start slightly smaller for the pop
	word_door_handle.scale = door_handle_word_base_scale * 0.6

	# Initial pop
	var pop_tween = create_tween()

	pop_tween.tween_property(
		word_door_handle,
		"scale",
		door_handle_word_base_scale * 1.12,
		0.22
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	pop_tween.tween_property(
		word_door_handle,
		"scale",
		door_handle_word_base_scale,
		0.16
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	await pop_tween.finished

	# Gentle continuous pulse
	door_handle_word_pulse_tween = create_tween()
	door_handle_word_pulse_tween.set_loops()

	door_handle_word_pulse_tween.tween_property(
		word_door_handle,
		"scale",
		door_handle_word_base_scale * 1.04,
		1.2
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	door_handle_word_pulse_tween.tween_property(
		word_door_handle,
		"scale",
		door_handle_word_base_scale,
		1.2
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func animate_front_ice_word():
	# Stop any previous pulse
	if front_ice_word_pulse_tween != null:
		front_ice_word_pulse_tween.kill()

	# Start slightly smaller for the pop
	word_front_ice.scale = front_ice_word_base_scale * 0.6

	# Initial pop
	var pop_tween = create_tween()

	pop_tween.tween_property(
		word_front_ice,
		"scale",
		front_ice_word_base_scale * 1.12,
		0.22
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	pop_tween.tween_property(
		word_front_ice,
		"scale",
		front_ice_word_base_scale,
		0.16
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	await pop_tween.finished

	# Gentle continuous pulse
	front_ice_word_pulse_tween = create_tween()
	front_ice_word_pulse_tween.set_loops()

	front_ice_word_pulse_tween.tween_property(
		word_front_ice,
		"scale",
		front_ice_word_base_scale * 1.04,
		1.2
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	front_ice_word_pulse_tween.tween_property(
		word_front_ice,
		"scale",
		front_ice_word_base_scale,
		1.2
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func animate_rear_ice_word():
	# Stop any previous pulse
	if rear_ice_word_pulse_tween != null:
		rear_ice_word_pulse_tween.kill()

	# Start slightly smaller for the pop
	word_rear_ice.scale = rear_ice_word_base_scale * 0.6

	# Initial pop
	var pop_tween = create_tween()

	pop_tween.tween_property(
		word_rear_ice,
		"scale",
		rear_ice_word_base_scale * 1.12,
		0.22
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	pop_tween.tween_property(
		word_rear_ice,
		"scale",
		rear_ice_word_base_scale,
		0.16
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	await pop_tween.finished

	# Gentle continuous pulse
	rear_ice_word_pulse_tween = create_tween()
	rear_ice_word_pulse_tween.set_loops()

	rear_ice_word_pulse_tween.tween_property(
		word_rear_ice,
		"scale",
		rear_ice_word_base_scale * 1.04,
		1.2
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	rear_ice_word_pulse_tween.tween_property(
		word_rear_ice,
		"scale",
		rear_ice_word_base_scale,
		1.2
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func animate_glue_word():
	# Stop any previous pulse
	if glue_word_pulse_tween != null:
		glue_word_pulse_tween.kill()

	# Start slightly smaller for the pop
	word_glue.scale = glue_word_base_scale * 0.6

	# Initial pop
	var pop_tween = create_tween()

	pop_tween.tween_property(
		word_glue,
		"scale",
		glue_word_base_scale * 1.12,
		0.22
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	pop_tween.tween_property(
		word_glue,
		"scale",
		glue_word_base_scale,
		0.16
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	await pop_tween.finished

	# Gentle continuous pulse
	glue_word_pulse_tween = create_tween()
	glue_word_pulse_tween.set_loops()

	glue_word_pulse_tween.tween_property(
		word_glue,
		"scale",
		glue_word_base_scale * 1.04,
		1.2
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	glue_word_pulse_tween.tween_property(
		word_glue,
		"scale",
		glue_word_base_scale,
		1.2
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func animate_fire_word():
	# Stop any previous pulse
	if fire_word_pulse_tween != null:
		fire_word_pulse_tween.kill()

	# Start slightly smaller for the pop
	word_fire.scale = fire_word_base_scale * 0.6

	# Initial pop
	var pop_tween = create_tween()

	pop_tween.tween_property(
		word_fire,
		"scale",
		fire_word_base_scale * 1.12,
		0.22
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	pop_tween.tween_property(
		word_fire,
		"scale",
		fire_word_base_scale,
		0.16
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	await pop_tween.finished

	# Gentle continuous pulse
	fire_word_pulse_tween = create_tween()
	fire_word_pulse_tween.set_loops()

	fire_word_pulse_tween.tween_property(
		word_fire,
		"scale",
		fire_word_base_scale * 1.04,
		1.2
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	fire_word_pulse_tween.tween_property(
		word_fire,
		"scale",
		fire_word_base_scale,
		1.2
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func animate_tar_word():
	# Stop any previous pulse
	if tar_word_pulse_tween != null:
		tar_word_pulse_tween.kill()

	# Start slightly smaller for the pop
	word_tar.scale = tar_word_base_scale * 0.6

	# Initial pop
	var pop_tween = create_tween()

	pop_tween.tween_property(
		word_tar,
		"scale",
		tar_word_base_scale * 1.12,
		0.22
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	pop_tween.tween_property(
		word_tar,
		"scale",
		tar_word_base_scale,
		0.16
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	await pop_tween.finished

	# Gentle continuous pulse
	tar_word_pulse_tween = create_tween()
	tar_word_pulse_tween.set_loops()

	tar_word_pulse_tween.tween_property(
		word_tar,
		"scale",
		tar_word_base_scale * 1.04,
		1.2
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	tar_word_pulse_tween.tween_property(
		word_tar,
		"scale",
		tar_word_base_scale,
		1.2
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func move_plan_to_tv():
	if tv_screen == null:
		print("SET THE TRAPS: TV screen not available.")
		return

	var texture_size = battle_plan.texture.get_size()

	var tv_center_global = tv_screen.global_position + (tv_screen.size / 2.0)

	var tv_center_local = to_local(tv_center_global)

	var scale_x = tv_screen.size.x / texture_size.x
	var scale_y = tv_screen.size.y / texture_size.y
	var tv_scale = min(scale_x, scale_y)

	var tween = create_tween()

	tween.set_parallel(true)

	tween.tween_property(
		battle_plan,
		"position",
		tv_center_local,
		1.0
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	tween.tween_property(
		battle_plan,
		"scale",
		Vector2(tv_scale, tv_scale),
		1.0
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	await tween.finished

	# Move the Battle Plan into the TV content layer
	# Keep its exact position and scale on screen
	if tv_content != null:
		battle_plan.reparent(tv_content, true)
		battle_plan.z_index = 5

func set_heavy_cans():
	print("SET THE TRAPS: HEAVY CANS")

	# Make sure the Battle Plan is back under Set the Traps
	if battle_plan.get_parent() != self:
		battle_plan.reparent(self, true)


	# Hide the Battle Plan while the video plays
	battle_plan.visible = false

	# Hide the trap artwork while the video plays
	trap_heavy_cans.visible = false

	# Get the TV video player
	var video_player = get_node_or_null("../Main_Game_Screen/video_tv/TV_Content/VideoStreamPlayer")

	if video_player == null:
		print("HEAVY CANS: VideoStreamPlayer not found.")
		return

	# Make sure the TV is visible
	video_player.visible = true

	# Keep the video behind the TV bezel
	video_player.z_index = 1

	var main_screen = $"../Main_Game_Screen"
	main_screen.keep_video_tv_open = true

	# Load and play the temporary Heavy Cans video
	video_player.stream = HEAVY_CANS_VIDEO
	video_player.play()

	# Wait until the video finishes
	await video_player.finished

	print("HEAVY CANS: Video finished")


	# Bring the Battle Plan back to full screenn
	battle_plan.visible = true

	battle_plan.position = Vector2(
		get_viewport_rect().size.x / 2.0,
		get_viewport_rect().size.y / 2.0
	)

	var viewport_size = get_viewport_rect().size
	var texture_size = battle_plan.texture.get_size()

	var scale_x = viewport_size.x / texture_size.x
	var scale_y = viewport_size.y / texture_size.y
	var full_screen_scale = min(scale_x, scale_y)

	battle_plan.scale = Vector2(
		full_screen_scale,
		full_screen_scale
	)
	
	# Attach Heavy Cans to the full-screen Battle Plan
	if trap_heavy_cans.get_parent() != battle_plan:
		trap_heavy_cans.reparent(battle_plan, true)

	# Show Heavy Cans artwork
	trap_heavy_cans.visible = true

	heavy_cans.visible = true
	word_heavy_cans.visible = true

	# Animate the Heavy Cans word
	animate_heavy_cans_word()

	# Keep the Battle Plan full screen for a few seconds
	await get_tree().create_timer(3.0).timeout

	# Shrink the Battle Plan back into the TV
	await move_plan_to_tv()

	# Show Heavy Cans inside the TV
	trap_heavy_cans.visible = true

func set_ornamints():
	print("SET THE TRAPS: ORNAMINTS")

	# Make sure the Battle Plan is back under Set the Traps
	if battle_plan.get_parent() != self:
		battle_plan.reparent(self, true)

	# Hide the Battle Plan while the video plays
	battle_plan.visible = false

	# Hide the trap artwork while the video plays
	trap_ornamints.visible = false

	# Get the TV video player
	var video_player = get_node_or_null("../Main_Game_Screen/video_tv/TV_Content/VideoStreamPlayer")

	if video_player == null:
		print("ORNAMINTS: VideoStreamPlayer not found.")
		return

	# Make sure the TV is visible
	video_player.visible = true

	# Keep the video behind the TV bezel
	video_player.z_index = 1

	var main_screen = $"../Main_Game_Screen"
	main_screen.keep_video_tv_open = true

	# Load and play the Ornamints video
	video_player.stream = ORNAMINTS_VIDEO
	video_player.play()

	# Wait until the video finishes
	await video_player.finished

	print("ORNAMINTS: Video finished")

	# Bring the Battle Plan back to full screen
	battle_plan.visible = true

	battle_plan.position = Vector2(
		get_viewport_rect().size.x / 2.0,
		get_viewport_rect().size.y / 2.0
	)

	var viewport_size = get_viewport_rect().size
	var texture_size = battle_plan.texture.get_size()

	var scale_x = viewport_size.x / texture_size.x
	var scale_y = viewport_size.y / texture_size.y
	var full_screen_scale = min(scale_x, scale_y)

	battle_plan.scale = Vector2(
		full_screen_scale,
		full_screen_scale
	)

	# Attach Ornamints to the full-screen Battle Plan
	if trap_ornamints.get_parent() != battle_plan:
		trap_ornamints.reparent(battle_plan, true)

	# Show Ornamints artwork
	trap_ornamints.visible = true

	ornamints.visible = true
	word_ornamints.visible = true

	# Animate the Ornamints word
	animate_ornamints_word()

	# Keep the Battle Plan full screen for a few seconds
	await get_tree().create_timer(3.0).timeout

	# Shrink the Battle Plan back into the TV
	await move_plan_to_tv()
	
func set_micro_machines():
	print("SET THE TRAPS: MICRO MACHINES")

	# Make sure the Battle Plan is back under Set the Traps
	if battle_plan.get_parent() != self:
		battle_plan.reparent(self, true)

	# Hide the Battle Plan while the video plays
	battle_plan.visible = false

	# Hide the trap artwork while the video plays
	trap_micro_machines.visible = false

	# Get the TV video player
	var video_player = get_node_or_null("../Main_Game_Screen/video_tv/TV_Content/VideoStreamPlayer")

	if video_player == null:
		print("MICRO MACHINES: VideoStreamPlayer not found.")
		return

	# Make sure the TV is visible
	video_player.visible = true

	# Keep the video behind the TV bezel
	video_player.z_index = 1

	var main_screen = $"../Main_Game_Screen"
	main_screen.keep_video_tv_open = true

	# Load and play the MicroMachines video
	video_player.stream = MICRO_MACHINES_VIDEO
	video_player.play()

	# Wait until the video finishes
	await video_player.finished

	print("MICRO MACHINES: Video finished")

	# Bring the Battle Plan back to full screen
	battle_plan.visible = true

	battle_plan.position = Vector2(
		get_viewport_rect().size.x / 2.0,
		get_viewport_rect().size.y / 2.0
	)

	var viewport_size = get_viewport_rect().size
	var texture_size = battle_plan.texture.get_size()

	var scale_x = viewport_size.x / texture_size.x
	var scale_y = viewport_size.y / texture_size.y
	var full_screen_scale = min(scale_x, scale_y)

	battle_plan.scale = Vector2(
		full_screen_scale,
		full_screen_scale
	)

	# Attach MicroMachines to the full-screen Battle Plan
	if trap_micro_machines.get_parent() != battle_plan:
		trap_micro_machines.reparent(battle_plan, true)

	# Show MicroMachines artwork
	trap_micro_machines.visible = true

	micro_machines.visible = true
	word_micro_machines.visible = true

	# Animate the MicroMachines word
	animate_micro_machines_word()

	# Keep the Battle Plan full screen for a few seconds
	await get_tree().create_timer(3.0).timeout

	# Shrink the Battle Plan back into the TV
	await move_plan_to_tv()
	
func set_fan_feathers():
	print("SET THE TRAPS: FAN FEATHERS")

	# Make sure the Battle Plan is back under Set the Traps
	if battle_plan.get_parent() != self:
		battle_plan.reparent(self, true)

	# Hide the Battle Plan while the video plays
	battle_plan.visible = false

	# Hide the trap artwork while the video plays
	trap_fan_feathers.visible = false

	# Get the TV video player
	var video_player = get_node_or_null("../Main_Game_Screen/video_tv/TV_Content/VideoStreamPlayer")

	if video_player == null:
		print("FAN FEATHERS: VideoStreamPlayer not found.")
		return

	# Make sure the TV is visible
	video_player.visible = true

	# Keep the video behind the TV bezel
	video_player.z_index = 1

	var main_screen = $"../Main_Game_Screen"
	main_screen.keep_video_tv_open = true

	# Load and play the Fan Feathers video
	video_player.stream = FAN_FEATHERS_VIDEO
	video_player.play()

	# Wait until the video finishes
	await video_player.finished

	print("FAN FEATHERS: Video finished")

	# Bring the Battle Plan back to full screen
	battle_plan.visible = true

	battle_plan.position = Vector2(
		get_viewport_rect().size.x / 2.0,
		get_viewport_rect().size.y / 2.0
	)

	var viewport_size = get_viewport_rect().size
	var texture_size = battle_plan.texture.get_size()

	var scale_x = viewport_size.x / texture_size.x
	var scale_y = viewport_size.y / texture_size.y
	var full_screen_scale = min(scale_x, scale_y)

	battle_plan.scale = Vector2(
		full_screen_scale,
		full_screen_scale
	)

	# Attach Fan Feathers to the full-screen Battle Plan
	if trap_fan_feathers.get_parent() != battle_plan:
		trap_fan_feathers.reparent(battle_plan, true)

	# Show Fan Feathers artwork
	trap_fan_feathers.visible = true

	fan_feathers.visible = true
	word_fan_feathers.visible = true

	# Animate the Fan Feathers word
	animate_fan_feathers_word()

	# Keep the Battle Plan full screen for a few seconds
	await get_tree().create_timer(3.0).timeout

	# Shrink the Battle Plan back into the TV
	await move_plan_to_tv()

func set_door_handle():
	print("SET THE TRAPS: DOOR HANDLE")

	# Make sure the Battle Plan is back under Set the Traps
	if battle_plan.get_parent() != self:
		battle_plan.reparent(self, true)

	# Hide the Battle Plan while the video plays
	battle_plan.visible = false

	# Hide the trap artwork while the video plays
	trap_door_handle.visible = false

	# Get the TV video player
	var video_player = get_node_or_null("../Main_Game_Screen/video_tv/TV_Content/VideoStreamPlayer")

	if video_player == null:
		print("DOOR HANDLE: VideoStreamPlayer not found.")
		return

	# Make sure the TV is visible
	video_player.visible = true

	# Keep the video behind the TV bezel
	video_player.z_index = 1

	var main_screen = $"../Main_Game_Screen"
	main_screen.keep_video_tv_open = true

	# Load and play the Door Handle video
	video_player.stream = DOOR_HANDLE_VIDEO
	video_player.play()

	# Wait until the video finishes
	await video_player.finished

	print("DOOR HANDLE: Video finished")

	# Bring the Battle Plan back to full screen
	battle_plan.visible = true

	battle_plan.position = Vector2(
		get_viewport_rect().size.x / 2.0,
		get_viewport_rect().size.y / 2.0
	)

	var viewport_size = get_viewport_rect().size
	var texture_size = battle_plan.texture.get_size()

	var scale_x = viewport_size.x / texture_size.x
	var scale_y = viewport_size.y / texture_size.y
	var full_screen_scale = min(scale_x, scale_y)

	battle_plan.scale = Vector2(
		full_screen_scale,
		full_screen_scale
	)

	# Attach Door Handle to the full-screen Battle Plan
	if trap_door_handle.get_parent() != battle_plan:
		trap_door_handle.reparent(battle_plan, true)

	# Show Door Handle artwork
	trap_door_handle.visible = true

	door_handle.visible = true
	word_door_handle.visible = true

	# Animate the Door Handle word
	animate_door_handle_word()

	# Keep the Battle Plan full screen for a few seconds
	await get_tree().create_timer(3.0).timeout

	# Shrink the Battle Plan back into the TV
	await move_plan_to_tv()

func set_front_ice():
	print("SET THE TRAPS: FRONT ICE")

	# Make sure the Battle Plan is back under Set the Traps
	if battle_plan.get_parent() != self:
		battle_plan.reparent(self, true)

	# Hide the Battle Plan while the video plays
	battle_plan.visible = false

	# Hide the trap artwork while the video plays
	trap_front_ice.visible = false

	# Get the TV video player
	var video_player = get_node_or_null("../Main_Game_Screen/video_tv/TV_Content/VideoStreamPlayer")

	if video_player == null:
		print("FRONT ICE: VideoStreamPlayer not found.")
		return

	# Make sure the TV is visible
	video_player.visible = true

	# Keep the video behind the TV bezel
	video_player.z_index = 1

	var main_screen = $"../Main_Game_Screen"
	main_screen.keep_video_tv_open = true

	# Load and play the Front Ice video
	video_player.stream = FRONT_ICE_VIDEO
	video_player.play()

	# Wait until the video finishes
	await video_player.finished

	print("FRONT ICE: Video finished")

	# Bring the Battle Plan back to full screen
	battle_plan.visible = true

	battle_plan.position = Vector2(
		get_viewport_rect().size.x / 2.0,
		get_viewport_rect().size.y / 2.0
	)

	var viewport_size = get_viewport_rect().size
	var texture_size = battle_plan.texture.get_size()

	var scale_x = viewport_size.x / texture_size.x
	var scale_y = viewport_size.y / texture_size.y
	var full_screen_scale = min(scale_x, scale_y)

	battle_plan.scale = Vector2(
		full_screen_scale,
		full_screen_scale
	)

	# Attach Front Ice to the full-screen Battle Plan
	if trap_front_ice.get_parent() != battle_plan:
		trap_front_ice.reparent(battle_plan, true)

	# Show Front Ice artwork
	trap_front_ice.visible = true

	front_ice.visible = true
	word_front_ice.visible = true

	# Animate the Front Ice word
	animate_front_ice_word()

	# Keep the Battle Plan full screen for a few seconds
	await get_tree().create_timer(3.0).timeout

	# Shrink the Battle Plan back into the TV
	await move_plan_to_tv()

func set_rear_ice():
	print("SET THE TRAPS: REAR ICE")

	# Make sure the Battle Plan is back under Set the Traps
	if battle_plan.get_parent() != self:
		battle_plan.reparent(self, true)

	# Hide the Battle Plan while the video plays
	battle_plan.visible = false

	# Hide the trap artwork while the video plays
	trap_rear_ice.visible = false

	# Get the TV video player
	var video_player = get_node_or_null("../Main_Game_Screen/video_tv/TV_Content/VideoStreamPlayer")

	if video_player == null:
		print("REAR ICE: VideoStreamPlayer not found.")
		return

	# Make sure the TV is visible
	video_player.visible = true

	# Keep the video behind the TV bezel
	video_player.z_index = 1

	var main_screen = $"../Main_Game_Screen"
	main_screen.keep_video_tv_open = true

	# Load and play the Rear Ice video
	video_player.stream = REAR_ICE_VIDEO
	video_player.play()

	# Wait until the video finishes
	await video_player.finished

	print("REAR ICE: Video finished")

	# Bring the Battle Plan back to full screen
	battle_plan.visible = true

	battle_plan.position = Vector2(
		get_viewport_rect().size.x / 2.0,
		get_viewport_rect().size.y / 2.0
	)

	var viewport_size = get_viewport_rect().size
	var texture_size = battle_plan.texture.get_size()

	var scale_x = viewport_size.x / texture_size.x
	var scale_y = viewport_size.y / texture_size.y
	var full_screen_scale = min(scale_x, scale_y)

	battle_plan.scale = Vector2(
		full_screen_scale,
		full_screen_scale
	)

	# Attach Rear Ice to the full-screen Battle Plan
	if trap_rear_ice.get_parent() != battle_plan:
		trap_rear_ice.reparent(battle_plan, true)

	# Show Rear Ice artwork
	trap_rear_ice.visible = true

	rear_ice.visible = true
	word_rear_ice.visible = true

	# Animate the Rear Ice word
	animate_rear_ice_word()

	# Keep the Battle Plan full screen for a few seconds
	await get_tree().create_timer(3.0).timeout

	# Shrink the Battle Plan back into the TV
	await move_plan_to_tv()

func set_glue():
	print("SET THE TRAPS: GLUE")

	# Make sure the Battle Plan is back under Set the Traps
	if battle_plan.get_parent() != self:
		battle_plan.reparent(self, true)

	# Hide the Battle Plan while the video plays
	battle_plan.visible = false

	# Hide the trap artwork while the video plays
	trap_glue.visible = false

	# Get the TV video player
	var video_player = get_node_or_null("../Main_Game_Screen/video_tv/TV_Content/VideoStreamPlayer")

	if video_player == null:
		print("GLUE: VideoStreamPlayer not found.")
		return

	# Make sure the TV is visible
	video_player.visible = true

	# Keep the video behind the TV bezel
	video_player.z_index = 1

	var main_screen = $"../Main_Game_Screen"
	main_screen.keep_video_tv_open = true

	# Load and play the Glue video
	video_player.stream = GLUE_VIDEO
	video_player.play()

	# Wait until the video finishes
	await video_player.finished

	print("GLUE: Video finished")

	# Bring the Battle Plan back to full screen
	battle_plan.visible = true

	battle_plan.position = Vector2(
		get_viewport_rect().size.x / 2.0,
		get_viewport_rect().size.y / 2.0
	)

	var viewport_size = get_viewport_rect().size
	var texture_size = battle_plan.texture.get_size()

	var scale_x = viewport_size.x / texture_size.x
	var scale_y = viewport_size.y / texture_size.y
	var full_screen_scale = min(scale_x, scale_y)

	battle_plan.scale = Vector2(
		full_screen_scale,
		full_screen_scale
	)

	# Attach Glue to the full-screen Battle Plan
	if trap_glue.get_parent() != battle_plan:
		trap_glue.reparent(battle_plan, true)

	# Show Glue artwork
	trap_glue.visible = true

	glue.visible = true
	word_glue.visible = true

	# Animate the Glue word
	animate_glue_word()

	# Keep the Battle Plan full screen for a few seconds
	await get_tree().create_timer(3.0).timeout

	# Shrink the Battle Plan back into the TV
	await move_plan_to_tv()

func set_fire():
	print("SET THE TRAPS: FIRE")

	# Make sure the Battle Plan is back under Set the Traps
	if battle_plan.get_parent() != self:
		battle_plan.reparent(self, true)

	# Bring the Battle Plan to full screen
	battle_plan.visible = true

	battle_plan.position = Vector2(
		get_viewport_rect().size.x / 2.0,
		get_viewport_rect().size.y / 2.0
	)

	var viewport_size = get_viewport_rect().size
	var texture_size = battle_plan.texture.get_size()

	var scale_x = viewport_size.x / texture_size.x
	var scale_y = viewport_size.y / texture_size.y
	var full_screen_scale = min(scale_x, scale_y)

	battle_plan.scale = Vector2(
		full_screen_scale,
		full_screen_scale
	)

	# Attach Fire to the full-screen Battle Plan
	if trap_fire.get_parent() != battle_plan:
		trap_fire.reparent(battle_plan, true)

	# Show Fire artwork
	trap_fire.visible = true

	fire.visible = true
	word_fire.visible = true

	# Animate the Fire word
	animate_fire_word()

	# Keep the Battle Plan full screen for a few seconds
	await get_tree().create_timer(3.0).timeout

	# Shrink the Battle Plan back into the TV
	await move_plan_to_tv()

func set_tar():
	print("SET THE TRAPS: TAR")

	# Make sure the Battle Plan is back under Set the Traps
	if battle_plan.get_parent() != self:
		battle_plan.reparent(self, true)

	# Hide the Battle Plan while the video plays
	battle_plan.visible = false

	# Hide the trap artwork while the video plays
	trap_tar.visible = false

	# Get the TV video player
	var video_player = get_node_or_null("../Main_Game_Screen/video_tv/TV_Content/VideoStreamPlayer")

	if video_player == null:
		print("TAR: VideoStreamPlayer not found.")
		return

	# Make sure the TV is visible
	video_player.visible = true

	# Keep the video behind the TV bezel
	video_player.z_index = 1

	var main_screen = $"../Main_Game_Screen"
	main_screen.keep_video_tv_open = true

	# Load and play the Tar video
	video_player.stream = TAR_VIDEO
	video_player.play()

	# Wait until the video finishes
	await video_player.finished

	print("TAR: Video finished")

	# Bring the Battle Plan back to full screen
	battle_plan.visible = true

	battle_plan.position = Vector2(
		get_viewport_rect().size.x / 2.0,
		get_viewport_rect().size.y / 2.0
	)

	var viewport_size = get_viewport_rect().size
	var texture_size = battle_plan.texture.get_size()

	var scale_x = viewport_size.x / texture_size.x
	var scale_y = viewport_size.y / texture_size.y
	var full_screen_scale = min(scale_x, scale_y)

	battle_plan.scale = Vector2(
		full_screen_scale,
		full_screen_scale
	)

	# Attach Tar to the full-screen Battle Plan
	if trap_tar.get_parent() != battle_plan:
		trap_tar.reparent(battle_plan, true)

	# Show Tar artwork
	trap_tar.visible = true

	tar.visible = true
	word_tar.visible = true

	# Animate the Tar word
	animate_tar_word()

	# Keep the Battle Plan full screen for a few seconds
	await get_tree().create_timer(3.0).timeout

	# Shrink the Battle Plan back into the TV
	await move_plan_to_tv()

func complete_set_the_traps():
	print("SET THE TRAPS: COMPLETE")

	var main_screen = $"../Main_Game_Screen"

	main_screen.set_traps_mission_status = "COMPLETE"
	main_screen.defend_house_mission_status = "READY"
	main_screen.update_mission_board()

# ==============================================================================
# TEMP INPUT KEY BINDINGS
# ==============================================================================

func _input(event):
	if event is InputEventKey and event.pressed and not event.echo:
		
		if event.keycode == KEY_H:
			request_trap("heavy_cans")

		if event.keycode == KEY_O:
			request_trap("ornamints")

		if event.keycode == KEY_M:
			request_trap("micro_machines")

		if event.keycode == KEY_F:
			request_trap("fan_feathers")

		if event.keycode == KEY_D:
			request_trap("door_handle")

		if event.keycode == KEY_I:
			request_trap("front_ice")

		if event.keycode == KEY_R:
			request_trap("rear_ice")

		if event.keycode == KEY_G:
			request_trap("glue")

		if event.keycode == KEY_E:
			request_trap("fire")

		if event.keycode == KEY_Y:
			request_trap("tar")
