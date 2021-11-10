extends Node

enum GameStates{
	MENU,
	WORLD_SELECTOR,
	LEVEL,
}

enum HurtTypes {
	JUMP,
	BULLET,
}

enum EnemyHurtTypes {
	NORMAL,
	NORMAL_AIR
}

var is_mobile: bool = false
var menu_locked: bool = false
var death_in_progress: bool = false
var player_invincible: bool = false
var dialog_active: bool = false
var inventory_active: bool = false
var timed_powerup_active: bool = false
var player_jump_damage: int = 1
var selected_world: int = 0
var selected_level: int = 0
var game_state: int = GameStates.MENU



var player_path = "/root/Main/LevelHolder/Level/Player"
var player_body_path = "/root/Main/LevelHolder/Level/Player/KinematicBody2D"
var level_path = "/root/Main/LevelHolder/Level"
var player_camera_path = "%s/Smoothing2D/Camera2D" % player_path


func _enter_tree() -> void:
	if OS.get_name() == "Android" or OS.get_name() == "iOS":
		is_mobile = true


func _ready() -> void:
	Signals.connect("level_changed", self, "_level_changed")
	UI.connect("faded", self, "_ui_faded")
	UI.connect("changed", self, "_ui_changed")


func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST:
		var action = InputEventAction.new()
		if UI.current_menu == UI.NONE or UI.current_menu == UI.PAUSE_MENU:
			action.action = "pause"
		else:
			action.action = "ui_cancel"
		action.pressed = true
		Input.parse_input_event(action)


func _ui_faded() -> void:
	pass

func _ui_changed(menu: int) -> void:
	match menu:
		UI.NONE:
			match UI.last_menu:
				UI.PAUSE_MENU_RETURN_PROMPT,\
				UI.PROFILE_SELECTOR,\
				UI.NONE:
					update_game_state()

func update_game_state() -> void:
	if UI.current_menu == UI.NONE:
		if UI.last_menu == UI.PAUSE_MENU_RETURN_PROMPT or \
				UI.last_menu == UI.PROFILE_SELECTOR:
			Globals.game_state = Globals.GameStates.WORLD_SELECTOR

	elif UI.current_menu == UI.MAIN_MENU and UI.last_menu == UI.PAUSE_MENU_RETURN_PROMPT:
		Globals.game_state = Globals.GameStates.MENU


func _level_changed(_world: int, _level: int) -> void:
	Globals.game_state = Globals.GameStates.LEVEL
