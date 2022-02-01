extends Control

onready var anim_player: AnimationPlayer = $AnimationPlayer
onready var return_button: Button = $Panel/HBoxContainer/Back

onready var total_gems: Label = $Panel/VBoxContainer/TotalGems
onready var remaining_gems: Label = $Panel/VBoxContainer/RemainingGems


func _ready() -> void:
	var __: int
	__ = GlobalEvents.connect("ui_all_gems_shown", self, "_ui_all_gems_shown")
	__ = return_button.connect("pressed", self, "_back_pressed")


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if GlobalUI.menu == GlobalUI.Menus.ALL_ORBS:
			_back_pressed()

#
#	if Input.is_action_just_pressed("ability"):
#		show_menu()
#		GlobalUI.menu = GlobalUI.Menus.BEAT_GAME
#		GlobalEvents.emit_signal("ui_button_pressed_to_prompt")


func show_menu() -> void:
	GlobalSave.set_stat("all_gems_collected", true)
	GlobalEvents.emit_signal("save_file_saved", true)

	return_button.grab_focus()
	return_button.disabled = false
	anim_player.play("show")
	total_gems.text = "%s: " % tr("inventory.stats.total_gems") + str(GlobalSave.get_gem_count())
	remaining_gems.text = "%s: " % tr("game_beat.remaning_gems") + str(GlobalStats.total_gems - GlobalSave.get_gem_count())
	get_tree().paused = true


func hide_menu() -> void:
	get_tree().paused = false
	return_button.disabled = true
	anim_player.play_backwards("show")


func _back_pressed() -> void:
	hide_menu()
	GlobalEvents.emit_signal("ui_button_pressed", true)
	GlobalUI.menu = GlobalUI.Menus.NONE


func _ui_all_gems_shown() -> void:
	show_menu()
	#GlobalSave.set_stat("all_gems_collected", true)
	GlobalEvents.emit_signal("save_file_saved", true)
	GlobalUI.menu = GlobalUI.Menus.ALL_ORBS
	GlobalEvents.emit_signal("ui_button_pressed_to_prompt")
