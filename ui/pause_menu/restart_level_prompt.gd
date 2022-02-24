extends Control

onready var anim_player: AnimationPlayer = $AnimationPlayer
onready var yes_button: Button = $Panel/VBoxContainer/HBoxContainer/Yes
onready var no_button: Button = $Panel/VBoxContainer/HBoxContainer/No
onready var title_text: Label = $Panel/VBoxContainer/Title
onready var prompt_text: Label = $Panel/VBoxContainer/PromptText


func _ready() -> void:
	var __: int
	__ = GlobalEvents.connect("level_changed", self, "_level_changed")
	__ = GlobalEvents.connect("ui_pause_menu_restart_pressed", self, "_ui_pause_menu_restart_pressed")
	__ = no_button.connect("pressed", self, "_no_pressed")
	__ = yes_button.connect("pressed", self, "_yes_pressed")

	for button in $Panel/VBoxContainer/HBoxContainer.get_children():
		__ = button.connect("focus_entered", self, "_button_hovered")
		__ = button.connect("mouse_entered", self, "_button_hovered")

	hide()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and GlobalUI.menu == GlobalUI.Menus.RESTART_PROMPT and not GlobalUI.menu_locked:
		_no_pressed()
		get_tree().set_input_as_handled()


func show_menu() -> void:
	show()
	title_text.show()
	anim_player.play("show")
	enable_buttons()

	no_button.grab_focus()


func hide_menu() -> void:
	anim_player.play_backwards("show")
	disable_buttons()
	yield(anim_player, "animation_finished")
	if not anim_player.is_playing() and not GlobalUI.menu == GlobalUI.Menus.RESTART_PROMPT:
		hide()
		$BGBlur.hide()


func enable_buttons() -> void:
	yes_button.disabled = false
	no_button.disabled = false


func disable_buttons() -> void:
	yes_button.disabled = true
	no_button.disabled = true


func _level_changed(_world: int, _level: int) -> void:
	if GlobalUI.menu == GlobalUI.Menus.RETURN_PROMPT:
		hide_menu()


func _ui_pause_menu_restart_pressed() -> void:
	show_menu()


func _no_pressed() -> void:
	if GlobalUI.menu_locked: return
	GlobalEvents.emit_signal("ui_button_pressed", true)
	GlobalUI.menu = GlobalUI.Menus.PAUSE_MENU
	GlobalEvents.emit_signal("ui_pause_menu_restart_prompt_no_pressed")
	hide_menu()


func _yes_pressed() -> void:
	if GlobalUI.menu_locked: return
	yes_button.release_focus()
	GlobalLevel.reset_checkpoint()
	GlobalEvents.emit_signal("ui_pause_menu_restart_prompt_yes_pressed")
	GlobalEvents.emit_signal("level_changed", GlobalLevel.current_world, GlobalLevel.current_level)
	yield(GlobalEvents, "ui_faded")
	hide_menu()

func _button_hovered() -> void:
	GlobalEvents.emit_signal("ui_button_hovered")

