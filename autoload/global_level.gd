extends Node

const WORLD_NAMES := [
	"World 0", "Foggy Overlands", "Drowsy Lands", "Snow Fall", "The End"]

const LEVEL_DATABASE := [
	0, 9, 8, 9, 1
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
	[false, false, false, true, false, false, false, false, true, true],
	[false, false],
]

const CANVAS_SUBSECTION_DATABASE := [
	#W0
	[false],
	#W1
	[false, false, false, false, false, false, false, false, false, true],
	#W2
	[false, false, false, true, false, false, false, false, false, false],
	#W3
	[false, false, false, false, false, true, false, false, false, true],
	[false, false],
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
	__ = GlobalEvents.connect("story_fernand_beat", self, "_story_fernand_beat")
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

	if GlobalLevel.checkpoint_in_sub:
		GlobalLevel.in_subsection = true
	else:
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
	GlobalUI.menu = GlobalUI.Menus.NONE
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

	var prev_time = GlobalSave.get_stat("seconds_played")
	GlobalSave.load_stats()
	GlobalSave.set_stat("seconds_played", prev_time)

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

	var already_waited: bool = false
	if not GlobalSave.get_stat("welcome_shown"):
		yield(GlobalEvents, "ui_faded")
		already_waited = true
		GlobalEvents.emit_signal("ui_welcome_shown")

	if GlobalUI.menu == GlobalUI.Menus.WELCOME:
		while GlobalUI.menu == GlobalUI.Menus.WELCOME:
			yield(get_tree(), "physics_frame")

	if not GlobalSave.get_stat("adrenaline_shown") and GlobalSave.get_stat("rank") >= GlobalStats.Ranks.GOLD:
		if not already_waited:
			yield(GlobalEvents, "ui_faded")
		GlobalEvents.emit_signal("ui_adrenaline_shown")


func unlock_next_level() -> void:
	if GlobalLevel.current_level + 1 <= LEVEL_DATABASE[GlobalLevel.current_world]:
		GlobalSave.set_stat("world_max", GlobalLevel.current_world)
		GlobalSave.set_stat("level_max", GlobalLevel.current_level + 1)
		#print("upping level")
		GlobalEvents.emit_signal("save_file_saved", true)
	else:
		if not int(GlobalSave.get_stat("world_max")) == GlobalLevel.WORLD_COUNT:
			GlobalSave.set_stat("world_max", GlobalLevel.current_world + 1)
			GlobalSave.set_stat("level_max", 1)
			GlobalEvents.emit_signal("save_file_saved", true)
			#print("upping world")

	if GlobalLevel.current_world == 4:
		GlobalSave.set_stat("level_max", 1)

	yield(GlobalEvents, "ui_faded")

	GlobalEvents.emit_signal("ui_notification_shown", "%s - %s %s" % [GlobalLevel.WORLD_NAMES[GlobalSave.get_stat("world_max")], GlobalSave.get_stat("level_max"), tr("notification.level_now_active")])


func reset_checkpoint() -> void:
	checkpoint_world = 0
	checkpoint_level = 0
	checkpoint_active = false
	checkpoint_in_sub = false


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

	yield(GlobalEvents, "ui_faded")

	if GlobalSave.get_stat("world_max") == 4 and not GlobalSave.get_stat("game_beat"):
		GlobalEvents.emit_signal("ui_game_beat_shown")

	yield(get_tree(), "physics_frame")

	if GlobalUI.menu == GlobalUI.Menus.BEAT_GAME:
		while GlobalUI.menu == GlobalUI.Menus.BEAT_GAME:
			yield(get_tree(), "physics_frame")

	if not GlobalSave.get_stat("all_gems_collected") and GlobalSave.get_gem_count() == GlobalStats.total_gems:
		GlobalEvents.emit_signal("ui_all_gems_shown")


func _level_checkpoint_activated() -> void:
	checkpoint_active = true
	checkpoint_world = current_world
	checkpoint_level = current_level


func _player_died() -> void:
	GlobalLevel.in_boss = false
	GlobalLevel.in_subsection = false
	GlobalUI.menu_locked = true

	get_tree().paused = true

	if Globals.game_state == Globals.GameStates.LEVEL:
		GlobalEvents.emit_signal("level_changed", GlobalSave.get_stat("world_last"), GlobalSave.get_stat("level_last"))
		error_detection()
	else:
		yield(GlobalEvents, "ui_faded")
		load_world_selector()
		error_detection()


func _story_fernand_beat() -> void:
	get_tree().paused = true
	yield(GlobalEvents, "ui_faded")
	for node in get_node(GlobalPaths.LEVEL_HOLDER).get_children():
		node.queue_free()
	yield(get_tree(), "physics_frame")
	#get_tree().paused = false
	GlobalEvents.emit_signal("level_changed", 4, 1)
	GlobalSave.set_stat("world_max", 4)
	GlobalSave.set_stat("level_max", 1)
	GlobalSave.set_stat("world_last", 1)
	GlobalSave.set_stat("level_last", 1)

	GlobalEvents.emit_signal("save_file_saved")


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
