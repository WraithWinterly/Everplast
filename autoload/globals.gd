extends Node

enum GameStates {
	MENU,
	WORLD_SELECTOR,
	LEVEL,
}

enum HurtTypes {
	TOUCH,
	TOUCH_AIR,
	JUMP,
	BULLET,
	SPIKES,
}

var version_string := ""

var game_state: int = GameStates.MENU

var death_in_progress := false
var player_invincible := false
var demo_version := false


func _ready() -> void:
	var __: int
	__ = GlobalEvents.connect("level_changed", self, "_level_changed")

	pause_mode = PAUSE_MODE_PROCESS


func _level_changed(_world: int, _level: int) -> void:
	yield(get_tree(), "physics_frame")
	game_state = GameStates.LEVEL

