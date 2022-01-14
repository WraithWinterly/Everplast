extends Node

onready var debug_console: Control = get_parent()

enum Arguments{
	INT,
	FLOAT,
	BOOL,
	STRING,
}

const valid_commands: Array = [
	["tp", [Arguments.FLOAT, Arguments.FLOAT]],
	["tpmod", [Arguments.FLOAT, Arguments.FLOAT]],
	["level", [Arguments.INT, Arguments.INT]],
	["spawn", [Arguments.STRING, Arguments.INT]],
	["set_stat", [Arguments.STRING, Arguments.STRING]],
	["get_stat", [Arguments.STRING]],
	["clear_stat_profile", [Arguments.STRING, Arguments.INT]],
	["clear_stat", [Arguments.STRING]],
	["unlockall"],
	["get_stats"],
	["get_stats_raw"],
	["get_settings"],
	["get_settings_raw"],
	["finish_level"],
	["get_gems"],
	["clear"],
	["kill"],
	["save"],
	["help"],
]


func tp(location_x: float, location_y: float) -> String:
	debug_console.hide_menu()
	var player: KinematicBody2D = get_node_or_null(GlobalPaths.PLAYER)
	if not player == null:
		var location = Vector2(location_x, location_y)
		player.position = location
		player.linear_velocity = Vector2(0, 0)
		return str("Player position has been changed to (%s, %s)" % [location_x, location_y])
	return str("FAILED: Player is not in the game.")


func tpmod(location_x: float, location_y: float) -> String:
	debug_console.hide_menu()
	var player: KinematicBody2D = get_node_or_null(GlobalPaths.PLAYER)
	if not player == null:
		var location = Vector2(player.global_position.x + location_x, player.global_position.y + location_y)
		player.position = location
		player.linear_velocity = Vector2(0, 0)
		return str("Player position has been changed to (%s, %s)" % [location_x, location_y])
	return str("FAILED: Player is not in the game.")


func level(world: int, level: int) -> String:
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


func clear_stat_profile(stat: String, profile: int) -> String:
	if GlobalSave.DEFAULT_DATA.has(stat):
		GlobalSave.data[profile][stat] = GlobalSave.DEFAULT_DATA[stat]
	else:
		return "Stat %s not found." % stat
	return "Stat %s set to %s on profile %s" % [stat, GlobalSave.data[profile][stat], profile]


func clear_stat(stat: String) -> String:
	if Globals.game_state == Globals.GameStates.MENU:
		return "You must be in the game."
	GlobalSave.set_stat(stat, GlobalSave.DEFAULT_DATA[stat])
	return "Stat %s set to %s" % [stat, get_stat(stat)]

func unlockall() -> String:
	if Globals.game_state == Globals.GameStates.MENU:
		return "You must be in a profile."

	GlobalSave.data[GlobalSave.profile].adrenaline_max = 100
	GlobalSave.data[GlobalSave.profile].adrenaline = 100
	GlobalSave.data[GlobalSave.profile].level = 100
	GlobalSave.data[GlobalSave.profile].adrenaline_speed *= GlobalStats.ADRENALINE_TIME_DECREASE_FROM_LEVEL_UP * 100
	GlobalSave.data[GlobalSave.profile].health_max = 100
	GlobalSave.data[GlobalSave.profile].health = 100
	GlobalSave.data[GlobalSave.profile].orbs = 10000
	GlobalSave.data[GlobalSave.profile].coins = 10000
	GlobalSave.data[GlobalSave.profile].rank = GlobalStats.Ranks.GLITCH
	GlobalSave.data[GlobalSave.profile].world_max = 4
	GlobalSave.data[GlobalSave.profile].level_max = 10

	for powerup in GlobalStats.VALID_POWERUPS:
		for i in 99:
			GlobalEvents.emit_signal("player_collected_powerup", powerup)

	for powerup in GlobalStats.VALID_COLLECTABLES:
		for i in 99:
			GlobalEvents.emit_signal("player_collected_collectable", powerup)

	for powerup in GlobalStats.VALID_EQUIPPABLES:
		GlobalEvents.emit_signal("player_collected_equippable", powerup)

	GlobalSave.data[GlobalSave.profile].gems[str(1)] = {}
	GlobalSave.data[GlobalSave.profile].gems[str(2)] = {}
	GlobalSave.data[GlobalSave.profile].gems[str(3)] = {}
	GlobalSave.data[GlobalSave.profile].gems[str(4)] = {}

	for level in GlobalLevel.LEVEL_DATABASE[1]:
		GlobalSave.data[GlobalSave.profile].gems["1"][str(level)] = [true, true, true]

	for world in GlobalLevel.LEVEL_DATABASE[2]:
		GlobalSave.data[GlobalSave.profile].gems["2"][str(world)] = [true, true, true]

	for world in GlobalLevel.LEVEL_DATABASE[3]:
		GlobalSave.data[GlobalSave.profile].gems["3"][str(world)] = [true, true, true]

	for world in GlobalLevel.LEVEL_DATABASE[4]:
		GlobalSave.data[GlobalSave.profile].gems["4"][str(world)] = [true, true, true]

	GlobalEvents.emit_signal("save_file_saved")

	return "Modified Profile %s" % GlobalSave.profile


func get_stats() -> String:
	var stats_string: String = "Save Data:\n"
	var data := GlobalSave.data
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


func finish_level() -> String:
	if Globals.game_state == Globals.GameStates.LEVEL:
		debug_console.hide_menu()
		GlobalEvents.emit_signal("level_completed")
		return "Finishing Level %s - %s..." % [GlobalLevel.WORLD_NAMES[GlobalLevel.current_world], GlobalLevel.current_level]
	else:
		return "You must be in a level."


func get_gems() -> String:
	if Globals.game_state == Globals.GameStates.LEVEL:
		GlobalEvents.emit_signal("player_collected_gem", 0)
		GlobalEvents.emit_signal("player_collected_gem", 1)
		GlobalEvents.emit_signal("player_collected_gem", 2)
		return "Gems collected for World %s - %s" % [GlobalLevel.current_world, GlobalLevel.current_level]
	else:
		return "You must be in a level."

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
				#help_string += " <%s>" % get_enum_name(parameter)
				help_string += " <%s>" % Arguments.keys()[parameter].to_lower()
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
