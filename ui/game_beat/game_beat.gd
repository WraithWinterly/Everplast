extends Control

onready var anim_player: AnimationPlayer = $AnimationPlayer
onready var return_button: Button = $Panel/HBoxContainer/Back


onready var level_label: Label = $Panel/VBoxContainer/Level
onready var total_orbs: Label = $Panel/VBoxContainer/TotalOrbs
onready var total_gems: Label = $Panel/VBoxContainer/TotalGems
onready var remaining_gems: Label = $Panel/VBoxContainer/RemainingGems
onready var total_time: Label = $Panel/VBoxContainer/TotalTime

func _ready() -> void:
	var __: int
	__ = GlobalEvents.connect("ui_game_beat_shown", self, "_ui_game_beat_shown")
	__ = return_button.connect("pressed", self, "_back_pressed")


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if GlobalUI.menu == GlobalUI.Menus.BEAT_GAME:
			_back_pressed()

#
#	if Input.is_action_just_pressed("ability"):
#		show_menu()
#		GlobalUI.menu = GlobalUI.Menus.BEAT_GAME
#		GlobalEvents.emit_signal("ui_button_pressed_to_prompt")


func show_menu() -> void:
	GlobalSave.set_stat("game_beat", true)
	GlobalEvents.emit_signal("save_file_saved")
	$Panel/Label2.text = "Everplast is now complete!"

	if GlobalStats.total_gems - GlobalSave.get_gem_count() > 0:
		$Panel/Label2.text += "There are still %s gems that have not been collected." % (GlobalStats.total_gems - GlobalSave.get_gem_count())
	else:
		remaining_gems.hide()

	return_button.grab_focus()
	return_button.disabled = false
	anim_player.play("show")
	level_label.text = "Level: " + str(GlobalSave.get_stat("level"))
	total_orbs.text = "Total Orbs: "+ str(GlobalSave.get_gem_count())
	total_gems.text = "Total Gems: " + str(GlobalSave.get_gem_count())
	remaining_gems.text = "Remaining Gems: " + str(GlobalStats.total_gems - GlobalSave.get_gem_count())
	total_time.text = "Time Played: "+ GlobalSave.get_timeplay_string()
	get_tree().paused = true


func hide_menu() -> void:
	get_tree().paused = false
	return_button.disabled = true
	anim_player.play_backwards("show")

func _back_pressed() -> void:
	hide_menu()
	GlobalEvents.emit_signal("ui_button_pressed", true)
	GlobalUI.menu = GlobalUI.Menus.NONE

func _ui_game_beat_shown() -> void:
	show_menu()
	GlobalUI.menu = GlobalUI.Menus.BEAT_GAME
	GlobalEvents.emit_signal("ui_button_pressed_to_prompt")
