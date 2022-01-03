extends Control

onready var anim_player: AnimationPlayer = $CanvasLayer/AnimationPlayer
onready var no_button: Button = $CanvasLayer/Panel/VBoxContainer/HBoxContainer/No
onready var yes_button: Button = $CanvasLayer/Panel/VBoxContainer/HBoxContainer/Yes
onready var prompt_text: Label = $CanvasLayer/Panel/VBoxContainer/PromptText


func _ready() -> void:
	var __: int
	__ = GlobalEvents.connect("ui_settings_erase_all_pressed", self, "_ui_settings_erase_all_pressed")
	__ = no_button.connect("pressed", self, "_no_pressed")
	__ = yes_button.connect("pressed", self, "_yes_pressed")


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and (
			GlobalUI.menu == GlobalUI.Menus.SETTINGS_ERASE_ALL_PROMPT or GlobalUI.menu == GlobalUI.Menus.SETTINGS_ERASE_ALL_EXTRA_PROMPT
			) and not GlobalUI.menu_locked:
		_no_pressed()
		get_tree().set_input_as_handled()


func show_menu() -> void:
	anim_player.play("show")
	enable_buttons()
	show()

	no_button.grab_focus()
	prompt_text.text = tr("erase_all.prompt.text")


func hide_menu() -> void:
	anim_player.play_backwards("show")
	disable_buttons()


func disable_buttons() -> void:
	no_button.disabled = true
	yes_button.disabled = true


func enable_buttons() -> void:
	no_button.disabled = false
	yes_button.disabled = false


func _ui_settings_erase_all_pressed() -> void:
	show_menu()


func _no_pressed() -> void:
	if GlobalUI.menu_locked: return
	GlobalEvents.emit_signal("ui_button_pressed", true)
	if GlobalUI.menu == GlobalUI.Menus.SETTINGS_ERASE_ALL_EXTRA_PROMPT:
		GlobalEvents.emit_signal("ui_settings_erase_all_prompt_extra_no_pressed")
		GlobalUI.menu = GlobalUI.Menus.SETTINGS_OTHER
		hide_menu()
		no_button.release_focus()
	else:
		no_button.release_focus()
		hide_menu()
		GlobalEvents.emit_signal("ui_settings_erase_all_prompt_no_pressed")
		GlobalUI.menu = GlobalUI.Menus.SETTINGS_OTHER


func _yes_pressed() -> void:
	if GlobalUI.menu_locked: return


	GlobalEvents.emit_signal("ui_button_pressed")
	if GlobalUI.menu == GlobalUI.Menus.SETTINGS_ERASE_ALL_EXTRA_PROMPT:
		GlobalUI.menu_locked = true
		GlobalEvents.emit_signal("ui_settings_erase_all_prompt_extra_yes_pressed")
		hide_menu()
		yield(get_tree().create_timer(1), "timeout")
		GlobalUI.menu = GlobalUI.Menus.MAIN_MENU
		GlobalUI.menu_locked = false
		var __ = get_tree().change_scene("res://main.tscn")

	else:
		disable_buttons()
		GlobalUI.menu = GlobalUI.Menus.SETTINGS_ERASE_ALL_EXTRA_PROMPT
		GlobalEvents.emit_signal("ui_settings_erase_all_prompt_yes_pressed")
		hide_menu()
		GlobalUI.menu_locked = true
		yield(get_tree().create_timer(0.75), "timeout")
		GlobalEvents.emit_signal("ui_button_pressed_to_prompt")
		GlobalUI.menu_locked = false
		enable_buttons()
		no_button.grab_focus()
		show_menu()
		prompt_text.text = tr("erase_all.prompt.text_extra")
