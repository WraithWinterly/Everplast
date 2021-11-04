extends Node

var current_world: int = 0
var current_level: int = 0

var checkpoint_active: bool = false
var checkpoint_world: int = 0
var checkpoint_level: int = 0

var level_database: Array = [
	2, 2, 2, 2, 2, 2, 2
]

var level_sound := AudioStreamPlayer.new()

onready var main: Main = get_tree().root.get_node("Main")


func _ready() -> void:
	level_sound.bus = "Audio"
	#level_sound.stream = load(FileLocations.level_enter_sound)
	add_child(level_sound)
	pause_mode = PAUSE_MODE_PROCESS
	UI.connect("faded", self, "error_detection")
	UI.connect("changed", self, "_ui_changed")
	Signals.connect("checkpoint_activated", self, "_checkpoint_activated")
	Signals.connect("level_changed", self, "_level_changed")
	Signals.connect("level_change_attempted", self, "_level_change_attempted")
	Signals.connect("player_death", self, "_player_death")
	Signals.connect("level_completed", self, "_level_completed")
	var prev_level = get_node_or_null("/root/Main/Level")
	if not prev_level == null: prev_level.call_deferred("free")


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
	for node in main.level_holder.get_children():
		if node.name == "WorldSelector":
			in_world_selector = true
			continue
	if in_world_selector:
		for node in main.level_holder.get_children():
			if not node.name == "WorldSelector":
				node.queue_free()
	else:
		for node in main.level_holder.get_children():
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
	main.level_holder.call_deferred("add_child", new_level.instance(), true)
	error_detection()


func world_selector_load() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	LevelController.current_world = -1
	LevelController.current_level = -1
	Globals.game_state = Globals.GameStates.WORLD_SELECTOR
	if main.level_holder.get_children().size() > 0:
		get_node(Globals.level_path).call_deferred("free")
	var world_selector: PackedScene = load(FileLocations.world_selector)
	main.level_holder.call_deferred("add_child", world_selector.instance(), true)
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
	get_tree().paused = true
	yield(UI, "faded")
	world_selector_load()
	get_tree().paused = false
	error_detection()


func _level_changed(world: int, level: int) -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	level_sound.play()
	if checkpoint_active:
		if not (checkpoint_world == world and checkpoint_level == level):
			LevelController.reset_checkpoint()
	get_tree().paused = true
	yield(UI, "faded")
	current_world = world
	current_level = level
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
	if PlayerStats.get_stat("world_max") <= LevelController.current_world:
		unlock_next_level()
	elif PlayerStats.get_stat("level_max") <= LevelController.current_level and \
			PlayerStats.get_stat("world_max") <= LevelController.current_world:
		unlock_next_level()
	yield(UI, "faded")
	get_tree().paused = false
	reset_checkpoint()
	Signals.emit_signal("save")
	world_selector_load()


func unlock_next_level() -> void:
	if LevelController.current_level + 1 <= level_database[LevelController.current_world]:
		PlayerStats.set_stat("world_max", LevelController.current_world)
		PlayerStats.set_stat("level_max", LevelController.current_level + 1)
	else:
		PlayerStats.set_stat("world_max", LevelController.current_world + 1)
		PlayerStats.set_stat("level_max", 1)
