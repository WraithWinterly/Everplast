extends Node2D

onready var fsm = get_parent().get_node("FSM")
onready var timer: Timer = $Timer

var sound_allowed: bool = true
var timer_count: float = 0


func _ready() -> void:
	fsm.connect("state_changed", self, "_state_changed")


func _physics_process(_delta: float) -> void:
	if get_tree().paused: return

	if fsm.current_state == fsm.walk or fsm.current_state == fsm.sprint:
		if abs(get_parent().linear_velocity.x) > 0.1:
			footstep_sounds()


func footstep_sounds() -> void:
	calc_footstep_speed()

	for i in get_parent().get_slide_count():
		var collision = get_parent().get_slide_collision(i)
		var collider = collision.collider
		if not get_parent().is_on_floor(): return
		if collider is TileMap:
			match collider.name:
				"TileMapW1Platform", "PlatformTileMap", "TileMapPlatformW2", "TileMapPlatform":
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
				"TileMapIce":
					try_play_sound($FootstepIce)
				"TileMapIceBlock":
					try_play_sound($FootstepIceBlock)
				"TileMapSnow":
					try_play_sound($FootstepSnow)


func calc_footstep_speed() -> void:
#	if get_parent().speed_modifier > 1:
#		timer_count: float = 0.2
#		timer_count /= GlobalInput.get_action_strength()
#
#	if get_parent().sprinting:
#		var timer_count: float = 0.3
#		timer_count *= abs(GlobalInput.get_action_strength())
#		timer.start(timer_count)
#		timer.start(timer_count)
#	else:
		var og_timer_count: float
		if get_parent().speed_modifier > 1:
			og_timer_count = 0.18
		elif get_parent().sprinting:
			og_timer_count = 0.27
		else:
			og_timer_count = 0.3

		timer_count = og_timer_count
		if not GlobalInput.get_action_strength() == 0:
			timer_count *= 1 / abs(GlobalInput.get_action_strength())
			if abs(GlobalInput.get_action_strength()) < 0.4:
				 timer_count *= 1.3
		timer_count = clamp(timer_count, og_timer_count, 0.7)
		#print(timer_count)


func try_play_sound(strm_player: AudioStreamPlayer) -> void:
	if sound_allowed:
		strm_player.pitch_scale = rand_range(0.75 + strm_player.pitch_modifier, 1.1 + strm_player.pitch_modifier)
		strm_player.play()
		sound_allowed = false
		start_timer()


func start_timer() -> void:
	timer.start(timer_count)



func _state_changed() -> void:
	if fsm.last_state == fsm.fall or fsm.current_state == fsm.jump:
		if sound_allowed:
			footstep_sounds()


func _on_Timer_timeout() -> void:
	sound_allowed = true
