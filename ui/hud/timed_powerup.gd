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
	text = GlobalStats.POWERUP_NAMES[item_name.capitalize()]
	GlobalStats.active_timed_powerup = item_name
	match item_name:
		"bunny egg":
			last_timed_item_name = item_name
			show_bar(GlobalStats.bunny_egg_time)
			last_int = GlobalStats.bunny_egg_time
			tick_sound.pitch_scale = 1
		"glitch orb":
			last_timed_item_name = item_name
			show_bar(GlobalStats.glitch_orb_time)
			last_int = GlobalStats.glitch_orb_time
			tick_sound.pitch_scale = 1


func stop_active_item() -> void:
	timer.stop()
	GlobalStats.timed_powerup_active = false
	anim_player.play_backwards("show")
	GlobalEvents.emit_signal("player_powerup_ended", last_timed_item_name)
	GlobalStats.active_timed_powerup = null


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
