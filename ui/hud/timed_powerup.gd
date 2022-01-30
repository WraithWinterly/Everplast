extends Label

var last_timed_item_name: String

var last_int: int = 0

onready var timer: Timer = $Timer
onready var progress_bar: ProgressBar = $ProgressBar
onready var time_left_label: Label = $ProgressBar/TimeLeft
onready var anim_player: AnimationPlayer = $AnimationPlayer
onready var start_sound: AudioStreamPlayer = $StartSound
onready var end_sound: AudioStreamPlayer = $EndSound
onready var tick_sound: AudioStreamPlayer = $TickSound


func _ready() -> void:
	var __: int
	__ = GlobalEvents.connect("ui_pause_menu_return_prompt_yes_pressed", self, "_ui_pause_menu_return_prompt_yes_pressed")
	__ = GlobalEvents.connect("player_used_powerup", self, "_player_used_powerup")
	__ = GlobalEvents.connect("level_completed", self, "_level_completed")
	__ = GlobalEvents.connect("player_died", self, "_player_died")
	__ = timer.connect("timeout", self, "_timeout")
	hide()


func _physics_process(_delta) -> void:
	if GlobalStats.timed_powerup_active:
		progress_bar.value = timer.time_left
		time_left_label.text = str(int(timer.time_left) + 1)

		# Ticking Sound
		if not last_int == int(timer.time_left):
			last_int = int(timer.time_left)
			tick_sound.play()

			if last_int <= 2:
				tick_sound.pitch_scale = 1.15
			else:
				tick_sound.pitch_scale = 1


func _player_used_powerup(item_name: String) -> void:
	if GlobalStats.timed_powerup_active: stop_active_item()
	if item_name in GlobalStats.TIMED_POWERUPS:
		GlobalStats.active_timed_powerup = item_name
	text = GlobalStats.COMMON_NAMES[item_name.capitalize()]
	last_timed_item_name = item_name
	tick_sound.pitch_scale = 1

	match item_name:
		"bunny egg":
			show_bar(GlobalStats.BUNNY_EGG_TIME)
			last_int = GlobalStats.BUNNY_EGG_TIME
		"glitch orb":
			show_bar(GlobalStats.GLITCH_ORB_TIME)
			last_int = GlobalStats.GLITCH_ORB_TIME
		"ice spike":
			show_bar(GlobalStats.ICE_SPIKE_TIME)
			last_int = GlobalStats.ICE_SPIKE_TIME
		"glitch soul":
			show_bar(GlobalStats.GLITCH_SOUL_TIME)
			last_int = GlobalStats.GLITCH_SOUL_TIME
			Engine.time_scale = 0.75



func stop_active_item() -> void:
	if GlobalStats.active_timed_powerup == "glitch soul":
		Engine.time_scale = 1
	timer.stop()
	GlobalStats.timed_powerup_active = false
	anim_player.play_backwards("show")
	GlobalEvents.emit_signal("player_powerup_ended", last_timed_item_name)
	GlobalStats.active_timed_powerup = ""

func _ui_pause_menu_return_prompt_yes_pressed() -> void:
	stop_active_item()


func _level_completed() -> void:
	stop_active_item()


func _player_died() -> void:
	stop_active_item()


func show_bar(time: int) -> void:
	show()
	start_sound.play()
	anim_player.play("show")
	timer.start(time)
	progress_bar.max_value = timer.time_left
	GlobalStats.timed_powerup_active = true


func _timeout() -> void:
	GlobalStats.timed_powerup_active = false
	anim_player.play_backwards("show")
	end_sound.play()
	GlobalEvents.emit_signal("player_powerup_ended", last_timed_item_name)
	if GlobalStats.active_timed_powerup == "glitch soul":
		Engine.time_scale = 1
