extends Label

var last_item_name: String

onready var timer: Timer = $Timer
onready var progress_bar: ProgressBar = $ProgressBar
onready var time_left_label: Label = $ProgressBar/TimeLeft
onready var anim_player: AnimationPlayer = $AnimationPlayer
onready var start_sound: AudioStreamPlayer = $StartSound
onready var end_sound: AudioStreamPlayer = $EndSound

func _ready() -> void:
	UI.connect("changed", self, "_ui_changed")
	Signals.connect("powerup_used", self, "_powerup_used")
	Signals.connect("level_completed", self, "_level_completed")
	Signals.connect("player_death", self, "_player_death")
	timer.connect("timeout", self, "_timeout")
	hide()


func _physics_process(delta) -> void:
	if Globals.timed_powerup_active:
		progress_bar.value = timer.time_left
		time_left_label.text = str(int(timer.time_left) + 1)


func _powerup_used(item_name: String) -> void:
	match item_name:
		"bunny egg":
			show_bar(item_name, 5)
		"glitch orb":
			show_bar(item_name, 5)


func stop_active_item() -> void:
		timer.stop()
		Globals.timed_powerup_active = false
		anim_player.play_backwards("show")
		Signals.emit_signal("powerup_ended", last_item_name
		)


func _ui_changed(menu: int) -> void:
	if menu == UI.NONE and UI.last_menu == UI.PAUSE_MENU_RETURN_PROMPT:
		stop_active_item()


func _level_completed() -> void:
	stop_active_item()


func _player_death() -> void:
	stop_active_item()



func show_bar(item_name: String, time: int) -> void:
	show()
	start_sound.play()
	last_item_name = item_name
	text = last_item_name.capitalize()
	anim_player.play("show")
	timer.start(5)
	progress_bar.max_value = timer.time_left
	Globals.timed_powerup_active = true


func _timeout() -> void:
	Globals.timed_powerup_active = false
	anim_player.play_backwards("show")
	end_sound.play()
	Signals.emit_signal("powerup_ended", last_item_name)
