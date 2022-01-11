
extends Control

onready var menu_buttons: VBoxContainer = $MenuButtons
onready var play_button: Button = $MenuButtons/Play
onready var quick_play_button: Button = $MenuButtons/QuickPlay
onready var settings_button: Button = $MenuButtons/Settings
onready var quit_button: Button = $MenuButtons/Quit
onready var camera: Camera2D = $Camera2D
onready var previous_button_focus: Button = play_button
onready var menu_buttons_anim_player: AnimationPlayer = $MenuButtonAnimationPlayer
onready var backgrounds: Control = $Backgrounds

var run_camera := true
var can_pass_pre_menu := false


func _ready() -> void:
	var __: int
	__ = GlobalEvents.connect("level_changed", self, "_level_changed")
	__ = GlobalEvents.connect("ui_profile_selector_profile_pressed", self, "_ui_profile_selector_profile_pressed")
	__ = GlobalEvents.connect("ui_profile_selector_return_pressed", self, "_ui_profile_selector_return_pressed")
	__ = GlobalEvents.connect("ui_quick_play_prompt_no_pressed", self, "_ui_quick_play_prompt_no_pressed")
	__ = GlobalEvents.connect("ui_quick_play_prompt_yes_pressed", self, "_ui_quick_play_prompt_yes_pressed")
	__ = GlobalEvents.connect("ui_quit_prompt_no_pressed", self, "_ui_quit_prompt_no_pressed")
	__ = GlobalEvents.connect("ui_quit_prompt_yes_pressed", self, "_ui_quit_prompt_yes_pressed")
	__ = GlobalEvents.connect("ui_settings_back_pressed", self, "_ui_settings_back_pressed")
	__ = GlobalEvents.connect("ui_pause_menu_return_prompt_yes_pressed", self, "_ui_pause_menu_return_prompt_yes_pressed")
	__ = GlobalEvents.connect("ui_settings_language_back_pressed_initial", self, "_ui_settings_language_back_pressed_initial")
	__ = GlobalEvents.connect("ui_settings_initial_started", self, "_ui_settings_initial_started")
	__ = GlobalEvents.connect("ui_controller_warning_no_pressed", self, "_ui_controller_warning_no_pressed")
	__ = GlobalEvents.connect("ui_controller_warning_yes_pressed", self, "_ui_controller_warning_yes_pressed")

	__ = play_button.connect("pressed", self, "_play_pressed")
	__ = quick_play_button.connect("pressed", self, "_quick_play_pressed")
	__ = settings_button.connect("pressed", self, "_on_settings_pressed")
	__ = quit_button.connect("pressed", self, "_quit_pressed")

	for button in menu_buttons.get_children():
		__ = button.connect("focus_entered", self, "_button_hovered")
		__ = button.connect("mouse_entered", self, "_button_hovered")

	disable_buttons()
	$CenterContainer/PressButton.hide()
	GlobalUI.menu_locked = true
	show()
	add_background()
	# Set camera perspective to be zoomed in
	camera.current = true
#	yield(get_tree(), "idle_frame")
#	camera.current = false
	update_menu()

	if not GlobalUI.menu == GlobalUI.Menus.INITIAL_SETUP:
		play_button.grab_focus()


	yield(get_tree(), "idle_frame")
	yield(GlobalEvents, "ui_faded")
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	if GlobalUI.menu == GlobalUI.Menus.NONE:
		go_to_pre_menu()

	GlobalUI.menu_locked = false

#	yield(get_tree(), "physics_frame")
#	if GlobalUI.menu == GlobalUI.Menus.MAIN_MENU:
#		enable_buttons()

func _input(event: InputEvent) -> void:
	if (event is InputEventKey or event is InputEventJoypadButton) and can_pass_pre_menu and GlobalUI.menu == GlobalUI.Menus.PRE_MAIN_MENU:
		go_to_main_menu()


func _physics_process(_delta: float) -> void:
	if camera.current:
		camera.position.x += 0.5


func go_to_pre_menu() -> void:
	GlobalUI.menu = GlobalUI.Menus.PRE_MAIN_MENU
	can_pass_pre_menu = true
	$CenterContainer/PressButton.show()


func go_to_main_menu() -> void:
	GlobalUI.menu = GlobalUI.Menus.MAIN_MENU
	get_tree().set_input_as_handled()
	play_button.grab_focus()
	menu_buttons_anim_player.play("slide")
	$CenterContainer/PressButton.hide()
	$PressButton.play()
	enable_buttons()
	#GlobalEvents.emit_signal("ui_button_pressed")


func add_background() -> void:
	for bg in backgrounds.get_children():
		bg.call_deferred("free")

	match int(GlobalQuickPlay.data.last_world):
		0, 1:
			backgrounds.add_child(load("res://world1/backgrounds/canvas_mountain_w1.tscn").instance())
			camera.position.y = -75
		2:
			backgrounds.add_child(load("res://world2/backgrounds/canvas_mountain_w2.tscn").instance())
			camera.position.y = -100
		3:
			backgrounds.add_child(load("res://world3/backgrounds/canvas_mountain_w3.tscn").instance())
			camera.position.y = 75
		4:
			backgrounds.add_child(load("res://world1/backgrounds/canvas_mountain_w1.tscn").instance())
		_:
			backgrounds.add_child(load("res://world1/backgrounds/canvas_mountain_w1.tscn").instance())

	camera.current = true

func remove_background() -> void:
	for bg in backgrounds.get_children():
		bg.call_deferred("free")

	camera.current = false


func show_menu() -> void:
	$CenterContainer/PressButton.hide()
	enable_buttons()
	show()
	add_background()
	update_menu()


func hide_menu() -> void:
	disable_buttons()
	hide()
	yield(get_tree(), "physics_frame")
	if GlobalUI.fade_player_playing:
		yield(GlobalEvents, "ui_faded")
	remove_background()



func disable_buttons() -> void:
	for button in menu_buttons.get_children():
		button.disabled = true


func enable_buttons() -> void:
	for button in menu_buttons.get_children():
		button.disabled = false


func update_menu() -> void:
	GlobalQuickPlay.update_stats()

	if GlobalQuickPlay.available:
		quick_play_button.show()
	else:
		quick_play_button.hide()

# Start of GlobalEvents

func _level_changed(_world: int, _level: int) -> void:
	$CenterContainer/PressButton.hide()
	if Globals.game_state == Globals.GameStates.MENU:
		hide_menu()


func _ui_profile_selector_profile_pressed() -> void:
	yield(GlobalEvents, "ui_faded")
	remove_background()
	hide_menu()


func _ui_profile_selector_return_pressed() -> void:
	if GlobalUI.menu == GlobalUI.Menus.PROFILE_SELECTOR:
		#yield(GlobalEvents, "ui_faded")
		update_menu()
		enable_buttons()
		#show_menu()

		play_button.grab_focus()


func _ui_quick_play_prompt_no_pressed() -> void:
	if GlobalUI.menu_locked: return
	GlobalEvents.emit_signal("ui_button_pressed", true)
	enable_buttons()

	quick_play_button.grab_focus()


func _ui_quit_prompt_no_pressed() -> void:
	if GlobalUI.menu_locked: return
	enable_buttons()

	quit_button.grab_focus()


func _ui_quick_play_prompt_yes_pressed() -> void:
	if GlobalUI.menu_locked: return
	yield(GlobalEvents, "ui_faded")
	hide_menu()


func _ui_settings_back_pressed() -> void:
	if GlobalUI.menu_locked: return
	if Globals.game_state == Globals.GameStates.MENU:
		enable_buttons()

		settings_button.grab_focus()


func _ui_pause_menu_return_prompt_yes_pressed() -> void:
	if Globals.game_state == Globals.GameStates.WORLD_SELECTOR:
		yield(GlobalEvents, "ui_faded")
		show_menu()

		play_button.grab_focus()


# Initial Languge Setup
func _ui_settings_language_back_pressed_initial() -> void:
	go_to_pre_menu()


func _ui_settings_initial_started() -> void:
	disable_buttons()


func _ui_controller_warning_no_pressed() -> void:
	go_to_pre_menu()


func _ui_controller_warning_yes_pressed() -> void:
	go_to_main_menu()
# End of GlobalEvents


func _play_pressed() -> void:
	if GlobalUI.menu_locked: return
	disable_buttons()
	play_button.release_focus()
	GlobalEvents.emit_signal("ui_play_pressed")
	GlobalUI.menu = GlobalUI.Menus.PROFILE_SELECTOR
	disable_buttons()
	#hide_menu()


func _quick_play_pressed() -> void:
	if GlobalUI.menu_locked: return
	disable_buttons()
	quick_play_button.release_focus()
	GlobalEvents.emit_signal("ui_button_pressed_to_prompt")
	GlobalEvents.emit_signal("ui_quick_play_pressed")
	GlobalUI.menu = GlobalUI.Menus.QUICK_PLAY_PROMPT


func _on_settings_pressed() -> void:
	if GlobalUI.menu_locked: return
	disable_buttons()
	settings_button.release_focus()
	GlobalEvents.emit_signal("ui_button_pressed")
	GlobalEvents.emit_signal("ui_settings_pressed")
	GlobalUI.menu = GlobalUI.Menus.SETTINGS


func _quit_pressed() -> void:
	if GlobalUI.menu_locked: return
	disable_buttons()
	quit_button.release_focus()
	GlobalEvents.emit_signal("ui_button_pressed_to_prompt")
	GlobalEvents.emit_signal("ui_quit_pressed")
	GlobalUI.menu = GlobalUI.Menus.QUIT_PROMPT

func _button_hovered() -> void:
	GlobalEvents.emit_signal("ui_button_hovered")
