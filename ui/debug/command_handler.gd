extends Node

onready var debug_console: Control = get_parent()

enum {
	ARG_INT,
	ARG_FLOAT,
	ARG_BOOL,
	ARG_STRING,
}

const valid_commands: Array = [
	["tp", [ARG_FLOAT, ARG_FLOAT]],
	["change_level", [ARG_INT, ARG_INT]],
	["spawn", [ARG_STRING, ARG_INT]],
	["set_stat", [ARG_STRING, ARG_STRING]],
	["get_stat", [ARG_STRING]],
	["get_stats"],
	["get_stats_raw"],
	["get_settings"],
	["get_settings_raw"],
	["clear"],
	["kill"],
	["save"],
	["help"],
]


func tp(location_x: float, location_y: float) -> String:
	debug_console.hide_menu()
	var location = Vector2(location_x, location_y)
	var player_body: KinematicBody2D = get_node_or_null(Globals.player_body_path)
	if not player_body == null:
		player_body.position = location
		player_body.linear_velocity = Vector2(0, 0)
		return str("Player position has been changed to (%s, %s)" % [location_x, location_y])
	return str("FAILED: Player is not in the game.")


func change_level(world: int, level: int) -> String:
	debug_console.hide_menu()
	GlobalEvents.emit_signal("level_changed", world, level)
	debug_console.last_world = Vector2(world, level)
	return "Attempted to change to World %s, Level %s" % [world, level]


func spawn(loader: String, amount: int) -> String:
	var spawn = load("res://" + loader + ".tscn")
	if spawn is PackedScene:
		for _n in amount:
			var loaded = spawn.instance()
			get_node(GlobalPaths.LEVEL).add_child(loaded)
			loaded.global_position = get_node(GlobalPaths.PLAYER).global_position
			loaded.global_position.x -= 30
			debug_console.hide_menu()
		return "%s Loaded." % loader
	else:
		return "Failed to load %s" % loader


func set_stat(stat_name: String, stat_value) -> String:
	if GlobalSave.get_stat(stat_name) is float:
		stat_value = stat_value as float
	elif GlobalSave.get_stat(stat_name) is int:
		stat_value = stat_value as int
	elif GlobalSave.get_stat(stat_name) is String:
		stat_value = stat_value as String

	GlobalSave.set_stat(stat_name, stat_value)
	return "Attempted to set stat %s to %s" % [stat_name, stat_value]


func get_stat(stat: String) -> String:
	return str(GlobalSave.get_stat(stat))


func get_stats() -> String:
	var stats_string: String = "Save Data:\n"
	var data = GlobalSave.data

	var index: int = 0
	for dict in data:
		stats_string += "Profile %s:\n" % (index + 1)
		for stats in data[index]:
			stats_string += "     %s: %s\n" % [stats, data[index][stats]]
		index += 1
	return stats_string


func get_stats_raw() -> String:
	return str(GlobalSave.data)


func get_settings() -> String:
	var string: String = "Settings:\n"
	for key in get_node(GlobalPaths.SETTINGS).data.keys():
		var new_str: String = key
		new_str = new_str.replace("_", " ")
		new_str = new_str.capitalize()
		string += "     %s: " % new_str
		string += "%s\n" % get_node(GlobalPaths.SETTINGS).data[key]
	return string


func get_settings_raw() -> String:
	return str(get_node(GlobalPaths.SETTINGS).data)


func clear() -> String:
	debug_console.output.text = "Type help for help"
	return "Console cleared."


func kill() -> String:
	var player = get_node_or_null(GlobalPaths.PLAYER)
	if player == null:
		return "Failed to find player."
	else:
		debug_console.hide_menu()
		GlobalEvents.emit_signal("player_death_started")
		return "Killed Player."


func save() -> String:
	GlobalEvents.emit_signal("save_file_saved")
	return "Game Saved."


func help() -> String:
	var help_string: String = "Debug Commands:\n"
	var index: int = 0
	for command in valid_commands:
		help_string += "     %s" % command[0]
		if command.size() > 1:
			for parameter in command[1]:
				help_string += " <%s>" % get_enum_name(parameter)
		if not index == valid_commands.size() - 1:
			help_string += "\n"
			index += 1

	return help_string


func get_enum_name(index: int) -> String:
	match index:
		0:
			return "int"
		1:
			return "float"
		2:
			return "bool"
		3:
			return "string"
		_:
			return ""
