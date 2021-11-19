extends Node

var current_world: int = 0
var current_level: int = 0

var checkpoint_active: bool = false
var checkpoint_world: int = 0
var checkpoint_level: int = 0

var level_database := [
	0, 9, 5, 4, 4, 4, 4
]

var canvas_database := [
	#W0
	[false],
	#W1
	[false, false, false, true, false, true, true, false, true, false],
	#W2
	[false, false, false, false, false, false, false, false, false, false],
	#W3
	[false, false, false, false, false, false, false, false, false, false],
	#W4
	[false, false, false, false, false, false, false, false, false, false],
	#W5
	[false, false, false, false, false, false, false, false, false, false],
	#W6
	[false, false, false, false, false, false, false, false, false, false],
]

var canvas_sub_database := [
	#W0
	[false],
	#W1
	[false, false, false, false, false, false, false, false, false, true],
	#W2
	[false, false, false, false, false, false, false, false, false, false],
	#W3
	[false, false, false, false, false, false, false, false, false, false],
	#W4
	[false, false, false, false, false, false, false, false, false, false],
	#W5
	[false, false, false, false, false, false, false, false, false, false],
	#W6
	[false, false, false, false, false, false, false, false, false, false],
]

var level_sound := AudioStreamPlayer.new()


func _ready() -> void:
	var __: int
	__ = UI.connect("faded", self, "error_detection")
	__ = UI.connect("changed", self, "_ui_changed")
	__ = Signals.connect("checkpoint_activated", self, "_checkpoint_activated")
	__ = Signals.connect("level_changed", self, "_level_changed")
	__ = Signals.connect("level_change_attempted", self, "_level_change_attempted")
	__ = Signals.connect("player_death", self, "_player_death")
	__ = Signals.connect("level_completed", self, "_level_completed")
	level_sound.bus = "Audio"
	level_sound.stream = load(FileLocations.level_enter_sound)
	add_child(level_sound)
	pause_mode = PAUSE_MODE_PROCESS
	var prev_level = get_node_or_null("/root/Main/Level")
	if not prev_level == null:
		prev_level.call_deferred("free")


func has_canvas() -> bool:
	if Globals.in_subsection:
		return canvas_sub_database[current_world][current_level]
	else:
		return canvas_database[current_world][current_level]


func _checkpoint_activated() -> void:
	checkpoint_active = true
	checkpoint_world = LevelController.current_world
	checkpoint_level = LevelController.current_level


func reset_checkpoint() -> void:
	checkpoint_world = 0
	checkpoint_level = 0
	checkpoint_active = false


func error_detection() -> void:
	var in_world_selector: bool = false
	for node in Globals.get_main().get_node("LevelHolder").get_children():
		if node.name == "WorldSelector":
			in_world_selector = true
			continue
	if in_world_selector:
		for node in Globals.get_main().level_holder.get_children():
			if not node.name == "WorldSelector":
				node.queue_free()
	else:
		for node in Globals.get_main().level_holder.get_children():
			if not node.name == "Level":
				node.queue_free()


func replace_scenes(world: int, level: int) -> void:
	var prev_level = get_node_or_null(Globals.level_path)
	if not prev_level == null:
		prev_level.call_deferred("free")
	yield(get_tree(), "physics_frame")
#	var new_level: PackedScene = load("res://scenes/world%s/level%s.tscn"
#		% [world, level])
	var new_level: PackedScene = load(FileLocations.get_level(world, level))
	# If you crashed here you tried to load a level that doesn't exist
	Globals.get_main().level_holder.call_deferred("add_child", new_level.instance(), true)
	error_detection()


func world_selector_load() -> void:
	Globals.in_subsection = false
	#AudioServer.remove_bus_effect(2, 1)
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	LevelController.current_world = -1
	LevelController.current_level = -1
	Globals.game_state = Globals.GameStates.WORLD_SELECTOR
	if Globals.get_main().get_node("LevelHolder").get_children().size() > 0:
		get_node(Globals.level_path).call_deferred("free")
	var world_selector: PackedScene = load(FileLocations.world_selector)
	Globals.get_main().level_holder.call_deferred("add_child", world_selector.instance(), true)
	error_detection()
	get_tree().paused = false
	PlayerStats.emit_signal("stat_updated")


func _ui_changed(menu: int) -> void:
	match menu:
		UI.NONE:
			match UI.last_menu:
				UI.PAUSE_MENU_RETURN_PROMPT:
					yield(UI, "faded")
					get_node(Globals.level_path).call_deferred("free")
					world_selector_load()
				UI.PROFILE_SELECTOR:
					yield(UI, "faded")
					world_selector_load()
					reset_checkpoint()
		UI.MAIN_MENU:
			if UI.last_menu == UI.PAUSE_MENU_RETURN_PROMPT:
				reset_checkpoint()
				Globals.update_game_state()
				yield(UI, "faded")
				get_node(Globals.level_path).call_deferred("free")


func _player_death() -> void:
	Globals.in_subsection = false
	get_tree().paused = true
	yield(UI, "faded")
	world_selector_load()
	get_tree().paused = false
	error_detection()


func _level_changed(world: int, level: int) -> void:
	Globals.in_subsection = false
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	level_sound.play()
	if checkpoint_active:
		if not (checkpoint_world == world and checkpoint_level == level):
			LevelController.reset_checkpoint()
	get_tree().paused = true
	current_world = world
	current_level = level
	yield(UI, "faded")
	replace_scenes(world, level)
	get_tree().paused = false
	error_detection()


func _level_change_attempted(world: int, level: int) -> void:
	var new_level = load(FileLocations.get_level(world, level))
	if new_level is PackedScene:
		Signals.emit_signal("level_changed", world, level)
	else:
		Signals.emit_signal("error_level_changed")
	error_detection()


func _level_completed() -> void:
	get_tree().paused = true
	if int(LevelController.current_world) == PlayerStats.get_stat("world_max") and int(LevelController.current_level) == PlayerStats.get_stat("level_max"):
		unlock_next_level()
#	else:
#		unlock_next_level()
	yield(UI, "faded")
	get_tree().paused = false
	reset_checkpoint()
	world_selector_load()
	Signals.emit_signal("save")


func unlock_next_level() -> void:
	if LevelController.current_level + 1 <= level_database[LevelController.current_world]:
		PlayerStats.set_stat("world_max", LevelController.current_world)
		PlayerStats.set_stat("level_max", LevelController.current_level + 1)
	else:
		PlayerStats.set_stat("world_max", LevelController.current_world + 1)
		PlayerStats.set_stat("level_max", 1)
	yield(UI, "faded")
	UI.emit_signal("show_notification", "%s - %s Now Active!" % [Globals.get_main().world_names[PlayerStats.get_stat("world_max")], PlayerStats.get_stat("level_max")])
	#Signals.emit_signal("save")
