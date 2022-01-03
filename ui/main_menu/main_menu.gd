
extends Control

onready var menu_buttons: VBoxContainer = $MenuButtons
onready var play_button: Button = $MenuButtons/Play
onready var quick_play_button: Button = $MenuButtons/QuickPlay
onready var settings_button: Button = $MenuButtons/Settings
onready var quit_button: Button = $MenuButtons/Quit
onready var camera: Camera2D = $Camera2D
onready var previous_button_focus: Button = play_button

onready var bg_color: Panel = $Background/CanvasLayerBack/Top
onready var top_color: Panel = $Background/ParallaxLayer/ColorRect
onready var parallax_layers := [$Background/ParallaxLayer, $Background/ParallaxLayer2,
								$Background/ParallaxLayer3]


func _ready() -> void:
	var __: int
	__ = GlobalEvents.connect("level_changed", self, "_level_changed")
	__ = GlobalEvents.connect("ui_profile_selector_return_pressed", self, "_ui_profile_selector_return_pressed")
	__ = GlobalEvents.connect("ui_quick_play_prompt_no_pressed", self, "_ui_quick_play_prompt_no_pressed")
	__ = GlobalEvents.connect("ui_quick_play_prompt_yes_pressed", self, "_ui_quick_play_prompt_yes_pressed")
	__ = GlobalEvents.connect("ui_quit_prompt_no_pressed", self, "_ui_quit_prompt_no_pressed")
	__ = GlobalEvents.connect("ui_quit_prompt_yes_pressed", self, "_ui_quit_prompt_yes_pressed")
	__ = GlobalEvents.connect("ui_settings_back_pressed", self, "_ui_settings_back_pressed")
	__ = GlobalEvents.connect("ui_pause_menu_return_prompt_yes_pressed", self, "_ui_pause_menu_return_prompt_yes_pressed")
	__ = GlobalEvents.connect("ui_settings_language_back_pressed_initial", self, "_ui_settings_language_back_pressed_initial")
	__ = GlobalEvents.connect("ui_settings_initial_started", self, "_ui_settings_initial_started")
	__ = play_button.connect("pressed", self, "_play_pressed")
	__ = quick_play_button.connect("pressed", self, "_quick_play_pressed")
	__ = settings_button.connect("pressed", self, "_on_settings_pressed")
	__ = quit_button.connect("pressed", self, "_quit_pressed")

	for button in menu_buttons.get_children():
		__ = button.connect("focus_entered", self, "_button_hovered")
		__ = button.connect("mouse_entered", self, "_button_hovered")

	GlobalUI.menu_locked = true
	show()

	# Set camera perspective to be zoomed in
	camera.current = true
	yield(get_tree(), "idle_frame")
	camera.current = false
	update_menu()

	if not GlobalUI.menu == GlobalUI.Menus.INITIAL_SETUP:

		play_button.grab_focus()

	yield(get_tree(), "idle_frame")

	yield(GlobalEvents, "ui_faded")
	GlobalUI.menu_locked = false


func show_menu() -> void:
	enable_buttons()
	show()
	bg_color.show()
	top_color.show()
	for bg in parallax_layers:
		bg.show()
	update_menu()


func hide_menu() -> void:
	disable_buttons()
	hide()
	yield(get_tree(), "physics_frame")
#	if GlobalUI.fade_player_playing:
#		yield(GlobalEvents, "ui_faded")
	bg_color.hide()
	top_color.hide()
	for bg in parallax_layers:
		bg.hide()


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
	if Globals.game_state == Globals.GameStates.MENU:
		hide_menu()


func _ui_profile_selector_return_pressed() -> void:
	if GlobalUI.menu == GlobalUI.Menus.PROFILE_SELECTOR:
		yield(GlobalEvents, "ui_faded")
		update_menu()
		show_menu()

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

	play_button.grab_focus()
	enable_buttons()


func _ui_settings_initial_started() -> void:
	disable_buttons()
# End of GlobalEvents


func _play_pressed() -> void:
	if GlobalUI.menu_locked: return
	disable_buttons()
	play_button.release_focus()
	GlobalEvents.emit_signal("ui_play_pressed")
	GlobalUI.menu = GlobalUI.Menus.PROFILE_SELECTOR
	yield(GlobalEvents, "ui_faded")
	hide_menu()


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
