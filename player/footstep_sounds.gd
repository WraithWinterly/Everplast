extends Node2D

onready var fsm = get_parent().get_node("FSM")
onready var timer: Timer = $Timer

var sound_allowed: bool = true


func _ready() -> void:
	fsm.connect("state_changed", self, "_state_changed")


func _physics_process(_delta: float) -> void:
	if get_tree().paused: return

	if fsm.current_state == fsm.walk or fsm.current_state == fsm.sprint:
		if abs(get_parent().linear_velocity.x) > 0.1:
			footstep_sounds()


func footstep_sounds() -> void:
	for i in get_parent().get_slide_count():
		var collision = get_parent().get_slide_collision(i)
		var collider = collision.collider
		if collider is TileMap:
			match collider.name:
				"TileMapW1Platform", "PlatformTileMap", "TileMapPlatformW2":
					try_play_sound($FootstepWood)
				"TileMapW1Grass", "TileMapW1Beach":
					try_play_sound($FootstepGrass)
				"TileMapW1Cloud":
					try_play_sound($FootstepCloud)
				"TileMapW1Rock", "TileMapRock":
					try_play_sound($FootstepRock)
				"TileMapSand":
					try_play_sound($FootstepSand)
				"TileMapSandstone":
					try_play_sound($FootstepSandstone)


func try_play_sound(strm_player: AudioStreamPlayer) -> void:
	if sound_allowed:
		strm_player.pitch_scale = rand_range(0.75, 1.1)
		strm_player.play()
		sound_allowed = false
		start_timer()


func start_timer() -> void:
	if get_parent().speed_modifier > 1:
		timer.start(0.2)
		return

	if get_parent().sprinting:
		timer.start(0.3)
	else:
		timer.start(0.4)


func _state_changed() -> void:
	if fsm.last_state == fsm.fall or fsm.current_state == fsm.jump:
		#sound_allowed = true
		#start_timer()
		if sound_allowed:
			footstep_sounds()


func _on_Timer_timeout() -> void:
	sound_allowed = true
