extends Control
class_name Main

export(String, "release,beta,alpha,dev") var version_prefix = "dev"
export var version_numbers: Array = [0, 0]
export var world_names: Array = [
	"World 0", "Foggy Overlands", "Drowsy Lands", "Snow Fall", "Tied Vines", "44 4f 4e 27 54 20 46 41 49 4c", "Molten Grounds"]

var version: String = ""

onready var level_holder: Node2D = $LevelHolder
onready var main_menu: Control = $GUI/MainMenu
onready var ts_buttons: Control = $GUI/TSButtons
onready var hud: Control = $GUI/HUD
onready var pause_menu: Control = $GUI/PauseMenu


static func get_action_strength_keyboard() -> float:
	return float(Input.get_action_strength("move_right") - \
			Input.get_action_strength("move_left")
	)


static func get_action_strength_controller() -> float:
	return float(Input.get_action_strength("ctr_move_right") - \
			Input.get_action_strength("ctr_move_left")
	)


static func get_action_strength() -> float:
	if abs(get_action_strength_keyboard()) > 0:
		return get_action_strength_keyboard()
	else:
		return get_action_strength_controller()


func _enter_tree() -> void:
	version = "v%s.%s-%s" % [version_numbers[0], version_numbers[1], version_prefix]
	#print("Everplast Rebirth: %s" % version)


func _ready() -> void:
	VisualServer.set_default_clear_color(Color(0, 0, 0, 0))
	OS.min_window_size = Vector2(1280, 720)
	UI.connect("changed", self, "_ui_changed")
	ts_buttons.hide()
	pause_menu.hide()


func _ui_changed(menu: int) -> void:
	match menu:
#		UI.NONE:
#			if UI.last_menu == UI.PAUSE_MENU_RETURN_PROMPT:
#				yield(UI, "faded")
#				hud.hide()
		UI.MAIN_MENU:
			if UI.last_menu == UI.PAUSE_MENU_RETURN_PROMPT:
				yield(UI, "faded")
				#hud.hide()
				ts_buttons.hide()


func _level_changed(_world: int, _level: int) -> void:
	yield(UI, "faded")
	ts_buttons.show()


func _game_paused() -> void:
	if Globals.is_mobile:
		ts_buttons.hide()


func _game_unpaused() -> void:
	if Globals.is_mobile:
		ts_buttons.show()

