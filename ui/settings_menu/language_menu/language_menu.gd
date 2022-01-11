extends Control

var inital := false

onready var anim_player: AnimationPlayer = $Panel/AnimationPlayer
onready var english_button: CheckBox = $Panel/VBoxContainer/English
onready var spanish_button: CheckBox = $Panel/VBoxContainer/Spanish
onready var return_button: Button = $Panel/BottomButtons/Return


func _ready() -> void:
	var __: int
	__ = GlobalEvents.connect("ui_settings_language_pressed", self, "_ui_settings_language_pressed")
	__ = GlobalEvents.connect("ui_settings_language_buttons_updated", self, "_ui_settings_language_buttons_updated")
	__ = english_button.connect("pressed", self, "_english_pressed")
	__ = spanish_button.connect("pressed", self, "_spanish_pressed")
	__ = return_button.connect("pressed", self, "_return_pressed")

	for button in $Panel/BottomButtons.get_children():
		__ = button.connect("focus_entered", self, "_button_hovered")
		__ = button.connect("mouse_entered", self, "_button_hovered")

	for button in $Panel/VBoxContainer.get_children():
		__ = button.connect("focus_entered", self, "_button_hovered")
		__ = button.connect("mouse_entered", self, "_button_hovered")

	if get_node(GlobalPaths.SETTINGS).data.language == "not_set":
		GlobalUI.menu = GlobalUI.Menus.INITIAL_SETUP

		yield(GlobalEvents, "ui_faded")

		GlobalEvents.emit_signal("ui_button_pressed_to_prompt")

		_ui_settings_language_pressed()

		return_button.hide()
		return_button.text = tr("global.continue")
		GlobalEvents.emit_signal("ui_settings_initial_started")


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and GlobalUI.menu == GlobalUI.Menus.SETTINGS_GENERAL_LANGUAGE and not GlobalUI.menu_locked:
		_return_pressed()
		get_tree().set_input_as_handled()


func enable_buttons() -> void:
	english_button.disabled = false
	spanish_button.disabled = false
	return_button.disabled = false


func disable_buttons() -> void:
	english_button.disabled = true
	spanish_button.disabled = true
	return_button.disabled = true


func show_menu() -> void:
	enable_buttons()
	anim_player.play("show")

	english_button.grab_focus()


func hide_menu() -> void:
	disable_buttons()
	anim_player.play_backwards("show")
	return_button.release_focus()
	yield(anim_player, "animation_finished")
	if not anim_player.is_playing():
		anim_player.play("RESET")


func _ui_settings_language_pressed() -> void:
	show_menu()


func _ui_settings_language_buttons_updated(region: String) -> void:
	if region == "en":
		english_button.pressed = true
		spanish_button.pressed = false
	elif region == "es":
		spanish_button.pressed = true
		english_button.pressed = false


func _english_pressed() -> void:
	spanish_button.pressed = false
	GlobalEvents.emit_signal("ui_button_pressed")
	GlobalEvents.emit_signal("ui_settings_language_english_pressed")
	return_button.show()

	if GlobalUI.menu == GlobalUI.Menus.INITIAL_SETUP:
		yield(get_tree(), "physics_frame")
		return_button.text = tr("global.continue")
	else:
		yield(get_tree(), "physics_frame")
		return_button.text = tr("global.return")


func _spanish_pressed() -> void:
	english_button.pressed = false
	GlobalEvents.emit_signal("ui_button_pressed")
	GlobalEvents.emit_signal("ui_settings_language_spanish_pressed")
	return_button.show()

	if GlobalUI.menu == GlobalUI.Menus.INITIAL_SETUP:
		yield(get_tree(), "physics_frame")
		return_button.text = tr("global.continue")
	else:
		yield(get_tree(), "physics_frame")
		return_button.text = tr("global.return")


func _return_pressed() -> void:
	disable_buttons()
	hide_menu()
	if not GlobalUI.menu == GlobalUI.Menus.INITIAL_SETUP:
		GlobalUI.menu = GlobalUI.Menus.SETTINGS_GENERAL
		GlobalEvents.emit_signal("ui_settings_language_back_pressed")
		GlobalEvents.emit_signal("ui_button_pressed", true)
	else:
		GlobalEvents.emit_signal("ui_settings_language_back_pressed_initial")
		GlobalUI.menu = GlobalUI.Menus.PRE_MAIN_MENU
		inital = false
		GlobalEvents.emit_signal("ui_button_pressed")
		yield(anim_player,"animation_finished")
		return_button.text = tr("global.return")


func _button_hovered() -> void:
	GlobalEvents.emit_signal("ui_button_hovered")
