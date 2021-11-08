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
	["clear"],
	["kill"],
	["save"],
	["help"],
]


func tp(location_x: float, location_y: float) -> String:
	var location = Vector2(location_x, location_y)
	var player_body: KinematicBody2D = get_node_or_null(Globals.player_body_path)
	if not player_body == null:
		player_body.position = location
		player_body.linear_velocity = Vector2(0, 0)
		return str("Player position has been changed to (%s, %s)" % [location_x, location_y])
	return str("FAILED: Player is not in the game.")


func change_level(world: int, level: int) -> String:
	Signals.emit_signal("level_change_attempted", world, level)
	debug_console.last_world = Vector2(world, level)
	return "Attempted to change to World %s, Level %s" % [world, level]


func spawn(loader: String, amount: int) -> String:
	var spawn = load("res://" + loader + ".tscn")
	if spawn is PackedScene:
		for _n in amount:
			var loaded = spawn.instance()
			loaded.global_position = get_node(Globals.player_body_path).global_position
			loaded.global_position.x -= 30
			get_node(Globals.level_path).add_child(loaded)
		return "%s Loaded." % loader
	else:
		return "Failed to load %s" % loader


func set_stat(stat_name: String, stat_value) -> String:
	if PlayerStats.get_stat(stat_name) is float:
		stat_value = stat_value as float
	elif PlayerStats.get_stat(stat_name) is int:
		stat_value = stat_value as int
	elif PlayerStats.get_stat(stat_name) is String:
		stat_value = stat_value as String

	PlayerStats.set_stat(stat_name, stat_value)
	return "Attempted to set stat %s to %s" % [stat_name, stat_value]


func get_stat(stat: String) -> String:
	return str(PlayerStats.get_stat(stat))


func get_stats() -> String:
	return str(PlayerStats.data)

func clear() -> String:
	debug_console.output.text = ""
	return "Console cleared."


func kill() -> String:
	var player = get_node(Globals.player_path)
	if player == null:
		return "Failed to find player."
	else:
		Signals.emit_signal("start_player_death")
		return "Killed Player."


func save() -> String:
	Signals.emit_signal("save")
	return "Game Saved."


func help() -> String:
	var help_string: String = "Debug Commands:\n"
	for command in valid_commands:
		help_string += "%s" % command[0]
		if command.size() > 1:
			for parameter in command[1]:
				help_string += " <%s>" % get_enum_name(parameter)
		help_string += "\n"

	return help_string


func give(item: String) -> void:
	pass


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
