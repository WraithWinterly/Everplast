extends Control

onready var anim_player: AnimationPlayer = $AnimationPlayer
onready var no_button: Button = $Panel/VBoxContainer/HBoxContainer/No
onready var yes_button: Button = $Panel/VBoxContainer/HBoxContainer/Yes


func _ready() -> void:
	var __: int
	__ = GlobalEvents.connect("level_changed", self, "_level_changed")
	__ = no_button.connect("pressed", self, "no_pressed")
	__ = yes_button.connect("pressed", self, "yes_pressed")
	hide()
	yield(GlobalEvents, "ui_faded")

	if get_node(GlobalPaths.SETTINGS).connected_controllers > 1:
		show_menu()


func _input(event: InputEvent) -> void:
	if GlobalUI.menu == GlobalUI.Menus.CONTROLLER_WARNING and event is InputEventAction:
		event = event as InputEventAction
		if event.action == "ui_cancel":
			get_tree().set_input_as_handled()
			hide_menu()
			GlobalEvents.emit_signal("ui_button_pressed")

func show_menu() -> void:
	if GlobalUI.menu == GlobalUI.Menus.INITIAL_SETUP:
		while GlobalUI.menu == GlobalUI.Menus.INITIAL_SETUP:
			yield(get_tree(), "physics_frame")

	$Panel/VBoxContainer/PromptText.text = "You have multiple controllers connected. You should select which controller you are using.\nCurrent Controller: %s"\
			 % Input.get_joy_name(get_node(GlobalPaths.SETTINGS).data.controller_index)
	GlobalUI.menu = GlobalUI.Menus.CONTROLLER_WARNING
	show()
	anim_player.play("show")
	yes_button.grab_focus()
	GlobalEvents.emit_signal("ui_button_pressed_to_prompt")


func hide_menu() -> void:
	anim_player.play_backwards("show")
	GlobalEvents.emit_signal("ui_controller_warning_no_pressed")

	#GlobalUI.menu = GlobalUI.Menus.MAIN_MENU
	yield(anim_player, "animation_finished")
	if not anim_player.is_playing() and not GlobalUI.menu == GlobalUI.Menus.CONTROLLER_WARNING:
		hide()
		$BGBlur.hide()


func _level_changed(_world: int, _level: int) -> void:
	hide_menu()

func no_pressed() -> void:
	hide_menu()
	GlobalEvents.emit_signal("ui_button_pressed", true)

func yes_pressed() -> void:
	GlobalEvents.emit_signal("ui_button_pressed")
	hide_menu()
	GlobalEvents.emit_signal("ui_controller_warning_yes_pressed")
