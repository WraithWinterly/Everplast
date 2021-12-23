extends Control

onready var anim_player: AnimationPlayer = $AnimationPlayer
onready var no_button: Button = $Panel/VBoxContainer/HBoxContainer/No
onready var yes_button: Button = $Panel/VBoxContainer/HBoxContainer/Yes


func _ready() -> void:
	var __: int
	__ = GlobalEvents.connect("ui_settings_reset_settings_pressed", self, "_ui_settings_reset_settings_pressed")
	__ = no_button.connect("pressed", self, "_no_pressed")
	__ = yes_button.connect("pressed", self, "_yes_pressed")


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and (
			GlobalUI.menu == GlobalUI.Menus.SETTINGS_RESET_SETTINGS_PROMPT or GlobalUI.menu == GlobalUI.Menus.SETTINGS_ERASE_ALL_EXTRA_PROMPT) \
			and not GlobalUI.menu_locked:
		_no_pressed()
		get_tree().set_input_as_handled()


func show_menu() -> void:
	anim_player.play("show")
	enable_buttons()
	show()
	GlobalUI.dis_focus_sound = true
	no_button.grab_focus()


func hide_menu() -> void:
	anim_player.play_backwards("show")
	disable_buttons()


func disable_buttons() -> void:
	no_button.disabled = true
	yes_button.disabled = true


func enable_buttons() -> void:
	no_button.disabled = false
	yes_button.disabled = false


func _ui_settings_reset_settings_pressed() -> void:
	show_menu()


func _no_pressed() -> void:
	if GlobalUI.menu_locked: return

	GlobalEvents.emit_signal("ui_button_pressed", true)
	GlobalEvents.emit_signal("ui_settings_reset_settings_prompt_no_pressed")
	GlobalUI.menu = GlobalUI.Menus.SETTINGS_OTHER
	hide_menu()
	no_button.release_focus()


func _yes_pressed() -> void:
	if GlobalUI.menu_locked: return

	GlobalUI.menu_locked = true
	GlobalEvents.emit_signal("ui_button_pressed")

	GlobalEvents.emit_signal("ui_settings_reset_settings_prompt_yes_pressed")
	hide_menu()
	yield(GlobalEvents, "ui_faded")
	var __ = get_tree().change_scene("res://main.tscn")
