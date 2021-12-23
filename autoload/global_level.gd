extends Node

const WORLD_NAMES := [
	"World 0", "Foggy Overlands", "Drowsy Lands", "Snow Fall", "This is a world?"]

const LEVEL_DATABASE := [
	0, 9, 8, 4, 4, 4, 4
]

const WORLD_COUNT := 4

const CANVAS_DATABASE := [
	#W0
	[false],
	#W1
	[false, false, false, true, false, true, true, false, true, false],
	#W2
	[false, false, false, true, false, false, true, false, false, false],
	#W3
	[false, false, false, false, false, false, false, false, false, false],
	#W4
	[false, false, false, false, false, false, false, false, false, false],
]

const CANVAS_SUBSECTION_DATABASE := [
	#W0
	[false],
	#W1
	[false, false, false, false, false, false, false, false, false, true],
	#W2
	[false, false, false, true, false, false, false, false, false, false],
	#W3
	[false, false, false, false, false, false, false, false, false, false],
	#W4
	[false, false, false, false, false, false, false, false, false, false],
]


var current_world: int = 0
var current_level: int = 0
var selected_world: int = 0
var selected_level: int = 0
var checkpoint_index: int = 0
var checkpoint_world: int = 0
var checkpoint_level: int = 0

var checkpoint_active := false
var checkpoint_in_sub := false
var in_subsection := false
var in_boss := false


func _ready() -> void:
	var __: int
	__ = GlobalEvents.connect("level_changed", self, "_level_changed")
	__ = GlobalEvents.connect("level_completed", self, "_level_completed")
	__ = GlobalEvents.connect("level_checkpoint_activated", self, "_level_checkpoint_activated")
	__ = GlobalEvents.connect("player_died", self, "_player_died")
	__ = GlobalEvents.connect("ui_faded", self, "_ui_faded")
	__ = GlobalEvents.connect("ui_profile_selector_profile_pressed", self, "_ui_profile_selector_profile_pressed")
	__ = GlobalEvents.connect("ui_pause_menu_return_prompt_yes_pressed", self, "_ui_pause_menu_return_prompt_yes_pressed")

	pause_mode = PAUSE_MODE_PROCESS

	var prev_level = get_node_or_null("/root/Main/Level")
	if not prev_level == null:
		prev_level.call_deferred("free")


func _level_changed(world: int, level: int) -> void:

	GlobalInput.start_high_vibration()

	if world > WORLD_COUNT:
		world = WORLD_COUNT
	if level > LEVEL_DATABASE[world]:
		level = LEVEL_DATABASE[world]

	GlobalLevel.in_subsection = false

	if checkpoint_active:
		if not (checkpoint_world == world and checkpoint_level == level):
			reset_checkpoint()

	get_tree().paused = true
	GlobalLevel.in_boss = false
	current_world = world
	current_level = level
	yield(GlobalEvents, "ui_faded")

	replace_scenes(world, level)
	get_tree().paused = false
	error_detection()


func replace_scenes(world: int, level: int) -> void:
	var prev_level = get_node_or_null(GlobalPaths.LEVEL)
	if not prev_level == null:
		prev_level.call_deferred("free")

	yield(get_tree(), "physics_frame")

	var new_level: PackedScene = load(GlobalPaths.get_level(world, level))

	if new_level:
		get_node(GlobalPaths.LEVEL_HOLDER).call_deferred("add_child", new_level.instance(), true)
		error_detection()
	else:
		level_failed()


func level_failed() -> void:
	GlobalUI.menu = GlobalUI.Menus.MAIN_MENU
	Globals.game_state = Globals.GameStates.MENU
	var __: int = get_tree().change_scene("res://main.tscn")


func error_detection() -> void:
	var in_world_selector: bool = false

	for node in get_node(GlobalPaths.LEVEL_HOLDER).get_children():
		if node.name == "WorldSelector":
			in_world_selector = true
			continue

	if in_world_selector:
		for node in get_node(GlobalPaths.LEVEL_HOLDER).get_children():
			if not node.name == "WorldSelector":
				node.queue_free()
	else:
		for node in get_node(GlobalPaths.LEVEL_HOLDER).get_children():
			if not node.name == "Level":
				node.queue_free()



func load_world_selector() -> void:
	#reset_checkpoint()

	GlobalEvents.emit_signal("level_world_selector_loaded")
	GlobalLevel.in_subsection = false

#	current_world = -1
#	current_level = -1

	Globals.game_state = Globals.GameStates.WORLD_SELECTOR

	if get_node(GlobalPaths.LEVEL_HOLDER).get_children().size() > 0:
		get_node(GlobalPaths.LEVEL).call_deferred("free")

	var world_selector: PackedScene = load(GlobalPaths.WORLD_SELECTOR)
	get_node(GlobalPaths.LEVEL_HOLDER).call_deferred("add_child", world_selector.instance(), true)
	error_detection()

	get_tree().paused = false
	GlobalEvents.emit_signal("level_world_selector_loaded")
	GlobalEvents.emit_signal("save_stat_updated")


func unlock_next_level() -> void:
	if GlobalLevel.current_level + 1 <= LEVEL_DATABASE[GlobalLevel.current_world]:
		GlobalSave.set_stat("world_max", GlobalLevel.current_world)
		GlobalSave.set_stat("level_max", GlobalLevel.current_level + 1)
	else:
		GlobalSave.set_stat("world_max", GlobalLevel.current_world + 1)
		GlobalSave.set_stat("level_max", 1)

	yield(GlobalEvents, "ui_faded")

	GlobalEvents.emit_signal("ui_notification_shown", "%s - %s %s" % [GlobalLevel.WORLD_NAMES[GlobalSave.get_stat("world_max")], GlobalSave.get_stat("level_max"), tr("notification.level_now_active")])


func reset_checkpoint() -> void:
	checkpoint_world = 0
	checkpoint_level = 0
	checkpoint_active = false


func has_canvas() -> bool:
	if GlobalLevel.in_subsection:
		return CANVAS_SUBSECTION_DATABASE[current_world][current_level]
	else:
		return CANVAS_DATABASE[current_world][current_level]


func _level_completed() -> void:
	GlobalLevel.in_boss = false
	get_tree().paused = true

	if int(GlobalLevel.current_world) == GlobalSave.get_stat("world_max") and int(GlobalLevel.current_level) == GlobalSave.get_stat("level_max"):
		unlock_next_level()

	yield(GlobalEvents, "ui_faded")

	get_tree().paused = false
	reset_checkpoint()
	load_world_selector()
	GlobalEvents.emit_signal("save_file_saved")


func _level_checkpoint_activated() -> void:
	checkpoint_active = true
	checkpoint_world = current_world
	checkpoint_level = current_level


func _player_died() -> void:
	GlobalLevel.in_boss = false
	GlobalLevel.in_subsection = false

	get_tree().paused = true

	yield(GlobalEvents, "ui_faded")

	load_world_selector()
	error_detection()

	yield(GlobalEvents, "ui_faded")

	selected_world = GlobalSave.get_stat("world_last")
	selected_level = GlobalSave.get_stat("level_last")

	yield(get_tree(), "physics_frame")

	GlobalUI.menu_locked = true
	GlobalUI.menu_locked = false

	GlobalEvents.emit_signal("ui_button_pressed")
	GlobalEvents.emit_signal("ui_level_enter_menu_pressed")

	GlobalUI.menu = GlobalUI.Menus.LEVEL_ENTER

	get_tree().paused = true


func _ui_faded() -> void:
	error_detection()


func _ui_profile_selector_profile_pressed() -> void:
	yield(GlobalEvents, "ui_faded")
	load_world_selector()



func _ui_pause_menu_return_prompt_yes_pressed() -> void:
	if Globals.game_state == Globals.GameStates.WORLD_SELECTOR:
		reset_checkpoint()
		yield(GlobalEvents, "ui_faded")
		get_node(GlobalPaths.LEVEL).call_deferred("free")
	elif Globals.game_state == Globals.GameStates.LEVEL:
		yield(GlobalEvents, "ui_faded")
		load_world_selector()
