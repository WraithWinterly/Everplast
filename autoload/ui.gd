extends Node

enum {
	MAIN_MENU,
	MAIN_MENU_QUICK_PLAY,
	MAIN_MENU_SETTINGS,
	MAIN_MENU_SETTINGS_CONTROLS,
	MAIN_MENU_SETTINGS_CREDITS,
	MAIN_MENU_QUIT_PROMPT,
	PROFILE_SELECTOR,
	PROFILE_SELECTOR_DELETE,
	PROFILE_SELECTOR_UPDATE_PROMPT,
	PROFILE_SELECTOR_DELETE_PROMPT,
	PAUSE_MENU,
	PAUSE_MENU_SETTINGS_CONTROLS,
	PAUSE_MENU_SETTINGS,
	PAUSE_MENU_SETTINGS_CREDITS,
	PAUSE_MENU_RETURN_PROMPT,
	NONE
}

# UI
signal screen_print(what)
signal faded()
signal changed(menu)
signal show_notification(notification)
signal button_pressed(other_sound)
signal profile_focus_index_changed()
signal notification_finished()

var last_menu: int = NONE
var current_menu: int = MAIN_MENU
var menu_transitioning: bool = false
var profile_index: int = 0
var profile_index_focus: int = 0
var prompt_no: bool = true


func _ready() -> void:
	pause_mode = PAUSE_MODE_PROCESS
	connect("changed", self, "_changed")
	Signals.connect("level_changed", self, "_level_changed")


func _input(event: InputEvent) -> void:
	if menu_transitioning:
		return
	if event.is_action_pressed("pause"):
		match current_menu:
			NONE:
				if not Globals.inventory_active:
					emit_signal("changed", PAUSE_MENU)
					emit_signal("button_pressed", true)
			PAUSE_MENU:
				emit_signal("changed", NONE)
				emit_signal("button_pressed")
	if event.is_action_pressed("ui_cancel"):
		match current_menu:
			MAIN_MENU:
				emit_signal("changed", MAIN_MENU_QUIT_PROMPT)
				emit_signal("button_pressed")
			MAIN_MENU_QUICK_PLAY:
				emit_signal("changed", MAIN_MENU)
				emit_signal("button_pressed", true)
			MAIN_MENU_SETTINGS:
				emit_signal("changed", MAIN_MENU)
				emit_signal("button_pressed", true)
			MAIN_MENU_SETTINGS_CONTROLS:
				emit_signal("changed", MAIN_MENU_SETTINGS)
				emit_signal("button_pressed", true)
			MAIN_MENU_SETTINGS_CREDITS:
				emit_signal("changed", MAIN_MENU_SETTINGS)
				emit_signal("button_pressed", true)
			MAIN_MENU_QUIT_PROMPT:
				emit_signal("changed", MAIN_MENU)
				emit_signal("button_pressed", true)
			PAUSE_MENU:
				emit_signal("changed", NONE)
				emit_signal("button_pressed")
			PAUSE_MENU_RETURN_PROMPT:
				emit_signal("changed", PAUSE_MENU)
				emit_signal("button_pressed")
			PAUSE_MENU_SETTINGS:
				emit_signal("changed", PAUSE_MENU)
				emit_signal("button_pressed", true)
			PAUSE_MENU_SETTINGS_CONTROLS:
				emit_signal("changed", PAUSE_MENU_SETTINGS)
				emit_signal("button_pressed", true)
			PAUSE_MENU_SETTINGS_CREDITS:
				emit_signal("changed", PAUSE_MENU_SETTINGS)
				emit_signal("button_pressed", true)
			PROFILE_SELECTOR:
				emit_signal("changed", MAIN_MENU)
				emit_signal("button_pressed", true)
			PROFILE_SELECTOR_DELETE:
				emit_signal("changed", PROFILE_SELECTOR)
				emit_signal("button_pressed", true)
			PROFILE_SELECTOR_DELETE_PROMPT:
				emit_signal("changed", PROFILE_SELECTOR_DELETE)
				emit_signal("button_pressed", true)
			PROFILE_SELECTOR_UPDATE_PROMPT:
				emit_signal("changed", PROFILE_SELECTOR)
				emit_signal("button_pressed", true)


func _changed(menu: int) -> void:
	if menu_transitioning:
		return
	last_menu = current_menu
	current_menu = menu


func _level_changed(_world: int, _level: int) -> void:
	emit_signal("changed", NONE)

