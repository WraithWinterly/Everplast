extends Control

onready var anim_player: AnimationPlayer = $AnimationPlayer
onready var return_button: Button = $Panel/HBoxContainer/Back


func _ready() -> void:
	var __: int
	__ = GlobalEvents.connect("ui_adrenaline_shown", self, "_ui_adrenaline_shown")
	__ = return_button.connect("pressed", self, "_back_pressed")


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if GlobalUI.menu == GlobalUI.Menus.ADRENALINE_TUT:
			_back_pressed()


func show_menu() -> void:
	GlobalSave.set_stat("adrenaline_shown", true)
	GlobalEvents.emit_signal("save_file_saved", true)

	return_button.grab_focus()
	return_button.disabled = false
	anim_player.play("show")
	get_tree().paused = true


func hide_menu() -> void:
	get_tree().paused = false
	return_button.disabled = true
	anim_player.play_backwards("show")


func _back_pressed() -> void:
	hide_menu()
	GlobalEvents.emit_signal("ui_button_pressed", true)
	GlobalUI.menu = GlobalUI.Menus.NONE


func _ui_adrenaline_shown() -> void:
	show_menu()
	GlobalEvents.emit_signal("save_file_saved", true)
	GlobalUI.menu = GlobalUI.Menus.ADRENALINE_TUT
	GlobalEvents.emit_signal("ui_button_pressed_to_prompt")
