extends Node

const KEY: String = \
		"^0Y]rm)'fT1Ki<YH&rlp3gy1-2:~.IF8`OKgL&nkBXmE(!48^AgvmiQc$@H?^t"

const FILE: String = \
		"user://save.json"

const DEFAULT_DATA: Dictionary = {
	"welcome_shown": false,
	"level_upgrade_shown": false,
	"adrenaline_shown": false,
	"game_beat": false,
	"all_gems_collected": false,
	"seconds_played": 0.0,
	"health_max": 5.0,
	"health": 5.0,
	"coins": 0.0,
	"orbs" : 0.0,
	"level": 1.0,
	"adrenaline": 10.0,
	"adrenaline_max": 10.0,
	"adrenaline_speed": 3.0,
	"world_last": 1.0,
	"level_last": 1.0,
	"world_max": 1.0,
	"level_max": 1.0,
	"powerups" : [],
	"equippables" : [],
	"collectables" : [],
	"equipped_item": "none",
	"rank": float(GlobalStats.Ranks.NONE),
	"gems": {},
}

const BASE_PLAYER_LEVEL: int = 50
const PLAYER_LEVEL_MULTIPLIER := 2.6

var data := [{}, {}, {}, {}, {}]

var adrenaline_timer := Timer.new()
var seconds_timer := Timer.new()

var no_data_hash: int = data.hash()
var profile: int = 0


func _ready() -> void:
	var __: int
	__ = GlobalEvents.connect("level_changed", self, "_level_changed")
	__ = GlobalEvents.connect("save_file_saved", self, "_save_file_saved")
	__ = GlobalEvents.connect("save_file_created", self, "_save_file_created")
	__ = GlobalEvents.connect("player_died", self, "_player_died")
	__ = GlobalEvents.connect("player_dashed", self, "_player_dashed")
	__ = GlobalEvents.connect("player_level_increased", self, "_player_level_increased")
	__ = GlobalEvents.connect("player_equipped", self, "_player_equipped")
	__ = GlobalEvents.connect("player_used_powerup", self, "_player_used_powerup")
	__ = GlobalEvents.connect("player_collected_coin", self, "_player_collected_coin")
	__ = GlobalEvents.connect("player_collected_orb", self, "_player_collected_orb")
	__ = GlobalEvents.connect("player_collected_gem", self, "_player_collected_gem")
	__ = GlobalEvents.connect("ui_profile_selector_profile_pressed", self, "_ui_profile_selector_profile_pressed")
	__ = GlobalEvents.connect("ui_profile_selector_delete_prompt_yes_pressed", self, "_ui_profile_selector_delete_prompt_yes_pressed")
	__ = GlobalEvents.connect("ui_profile_selector_update_prompt_yes_pressed", self, "_ui_profile_selector_update_prompt_yes_pressed")
	__ = GlobalEvents.connect("ui_pause_menu_return_prompt_yes_pressed", self, "_ui_pause_menu_return_prompt_yes_pressed")

	__ = GlobalEvents.connect("ui_settings_erase_all_prompt_extra_yes_pressed", self, "_ui_settings_erase_all_prompt_extra_yes_pressed")
	__ = adrenaline_timer.connect("timeout", self, "_timer_timeout")
	__ = seconds_timer.connect("timeout", self, "_seconds_timeout")


	add_child(adrenaline_timer)
	add_child(seconds_timer)
	seconds_timer.autostart = true
	seconds_timer.wait_time = 1
	seconds_timer.process_mode = Timer.TIMER_PROCESS_PHYSICS
	seconds_timer.start(1)
	load_stats()

	pause_mode = PAUSE_MODE_PROCESS

func _notification(what: int) -> void:
	if what == NOTIFICATION_CRASH or what == NOTIFICATION_WM_QUIT_REQUEST:
		GlobalSave.save_stats()


func _physics_process(_delta):
	if not Globals.game_state == Globals.GameStates.LEVEL:
		return

	if get_stat("rank") <= GlobalStats.Ranks.SILVER:
		return

	if get_stat("adrenaline") >= get_stat("adrenaline_max"):
		adrenaline_timer.stop()
	else:
		if adrenaline_timer.is_stopped():
			adrenaline_timer.start(get_stat("adrenaline_speed"))

	if int(get_stat("health")) <= 0 and not Globals.death_in_progress:
		GlobalEvents.emit_signal("player_death_started")


func save_stats(_on_reset: bool = false) -> void:
	if Globals.game_state == Globals.GameStates.LEVEL:
		set_stat("world_last", GlobalLevel.current_world)
		set_stat("level_last", GlobalLevel.current_level)
	var file: File = File.new()
	#file.open_encrypted_with_pass(FILE, File.WRITE, KEY)
	var __ = file.open(FILE, File.WRITE)
	file.store_string(to_json(data))
	file.close()
	load_stats()


func load_stats() -> void:
	var file: File = File.new()
	if file.file_exists(FILE):
		#file.open_encrypted_with_pass(FILE, File.READ, KEY)
		var __ = file.open(FILE, File.READ)
		var loaded_data
		var test = parse_json(file.get_as_text())

		if test is Array:
			loaded_data = parse_json(file.get_as_text())
		else:
			reset_all()
			return

		if not typeof(loaded_data) == TYPE_ARRAY:
			reset_all()
			return
		file.close()

		var index: int = 0
		for dict in loaded_data:
			if typeof(dict) == TYPE_DICTIONARY:
				data[index] = dict
				index += 1
			else:
				delete_profile(index)
	else:
		reset_all()


func verify(index: int) -> bool:
	for i in data[index]:
		if not DEFAULT_DATA.has(i):
			return false
		elif not typeof(data[index][i]) == typeof(DEFAULT_DATA[i]):
			return false

	return data[index].size() == DEFAULT_DATA.size()


func get_stat(value: String): #-> Variant not supported
	if data[profile].has(value):
		return data[profile][value]
	else:
		printerr("Could not get value %s on base %s" % [value, profile])


func set_stat(value, value2): #-> Variant
	if GlobalStats.timed_powerup_active:
		if GlobalStats.active_timed_powerup == "ice spike":
			if value == "health" or value == "adrenaline":
				return

	if data[profile].has(value):
		data[profile][value] = value2
	else:
		printerr("Could not get value %s on base %s" % [value, profile])

	GlobalEvents.emit_signal("save_stat_updated")


func set_health(new_value):
	if new_value > get_stat("health_max"):
		new_value = get_stat("health_max")
	elif new_value < 0:
		new_value = 0

	set_stat("health", new_value)
	GlobalEvents.emit_signal("save_stat_updated")


func set_adrenaline(new_value):
	if new_value > get_stat("adrenaline_max"):
		new_value = get_stat("adrenaline_max")
	elif new_value < 0:
		new_value = 0

	set_stat("adrenaline", new_value)
	GlobalEvents.emit_signal("save_stat_updated")


func delete_profile(index: int):
	if GlobalQuickPlay.data.last_profile == index:
		GlobalQuickPlay.reset()
	data[index] = {}
	save_stats(true)
	load_stats()


func get_level_up_cost() -> int:
	var cost: int = BASE_PLAYER_LEVEL
	var level = get_stat("level")

	cost *= level * PLAYER_LEVEL_MULTIPLIER
	return int(cost)


func get_gem_count(idx: int = -1) -> int:
	var gem_dict: Dictionary
	var gem_count: int = 0

	if idx == -1:
		gem_dict = get_stat("gems")
	else:
		gem_dict = data[idx].gems

	if gem_dict.size() > 0:
		for world in gem_dict.keys():
			if gem_dict[world].size() > 0:
				for level in gem_dict[world]:
					if int(level) == 0: continue
					for i in gem_dict[world][level]:
						if i:

							gem_count += 1
	return gem_count


func has_item(array: Array, value: String) -> bool:
	for n in array:
		if n[0] == value:
			return true
	return false

func get_item_count(array: Array, value: String) -> int:
	for n in array:
		if n[0] == value:
			return n[1]
	return 0

func reset_all() -> void:
	data = [{}, {}, {}, {}, {}]
	save_stats(true)


func _level_changed(world: int, level: int) -> void:
	var prev_time = get_stat("seconds_played")
	load_stats()
	set_stat("seconds_played", prev_time)

	yield(GlobalEvents, "ui_faded")
	set_stat("world_last", world)
	set_stat("level_last", level)
	set_stat("adrenaline", get_stat("adrenaline_max"))


func _save_file_saved(on_reset: bool = false) -> void:
	save_stats(on_reset)


func _save_file_created(index: int) -> void:
	data[index] = DEFAULT_DATA
	save_stats(true)
	#load_stats()


func _player_died() -> void:
	if Globals.game_state == Globals.GameStates.LEVEL:
		var prev_last_world = GlobalLevel.current_world
		var prev_last_level = GlobalLevel.current_level
#		var prev_powerups = get_stat("powerups")
#		var prev_collectables = get_stat("collectables")
#		var prev_equippables = get_stat("equippables")
		var prev_equiped = get_stat("equipped_item")
		var prev_time = get_stat("seconds_played")
		yield(GlobalEvents, "ui_faded")
		load_stats()
		set_stat("world_last", prev_last_world)
		set_stat("level_last", prev_last_level)
		set_stat("equipped_item", prev_equiped)
		set_stat("seconds_played", prev_time)
#		set_stat("powerups", prev_powerups)
#		set_stat("collectables", prev_collectables)
#		set_stat("equippables", prev_equippables)
		set_stat("health", get_stat("health_max"))
		set_stat("adrenaline", get_stat("adrenaline_max"))
		save_stats()



func _player_dashed() -> void:
	if not get_stat("adrenaline") <= 0:
		if Globals.game_state == Globals.GameStates.LEVEL:
			set_stat("adrenaline", get_stat("adrenaline") - 1)



func _player_level_increased(type: String) -> void:
	match type:
		"health":
			set_stat("health_max", get_stat("health_max") + GlobalStats.STAT_INCREASE_FROM_LEVEL_UP)
			set_stat("health", get_stat("health_max"))
		"adrenaline":
			set_stat("adrenaline_max", get_stat("adrenaline_max") + GlobalStats.STAT_INCREASE_FROM_LEVEL_UP)
			set_stat("adrenaline", get_stat("adrenaline_max"))
			set_stat("adrenaline_speed", get_stat("adrenaline_speed") * GlobalStats.ADRENALINE_TIME_DECREASE_FROM_LEVEL_UP)
	set_stat("orbs", get_stat("orbs") - get_level_up_cost())
	set_stat("level", get_stat("level") + 1)
	GlobalEvents.emit_signal("save_file_saved")


func _player_equipped(equippable: String) -> void:
	set_stat("equipped_item", equippable)


func _player_used_powerup(item_name: String) -> void:
	match item_name:
		"carrot":
			set_health(get_stat("health") + GlobalStats.CARROT_BOOST)
		"coconut":
			set_health(get_stat("health") + GlobalStats.COCONUT_BOOST)
		"pear":
			set_health(get_stat("health") + GlobalStats.PEAR_HEALTH_BOOST)
			set_adrenaline(get_stat("adrenaline") + GlobalStats.PEAR_ADRENALINE_BOOST)
		"cherry":
			set_adrenaline(get_stat("adrenaline") + GlobalStats.CHERRY_BOOST)
			set_health(get_stat("health") + GlobalStats.CHERRY_BOOST_HEALTH)

	GlobalEvents.emit_signal("save_stat_updated")


func _player_collected_coin(amount: int) -> void:
	set_stat("coins", get_stat("coins") + amount)
	GlobalEvents.emit_signal("save_stat_updated")


func _player_collected_orb(amount: int) -> void:
	set_stat("orbs", get_stat("orbs") + amount)
	GlobalEvents.emit_signal("save_stat_updated")


func _player_collected_gem(index: int) -> void:
	index = int(clamp(index, 0, 2))
	var gem_dict = get_stat("gems")
	if str(GlobalLevel.current_world) in gem_dict:
		for key in gem_dict.keys():
			if int(key) == GlobalLevel.current_world:
				if str(GlobalLevel.current_level) in gem_dict.get(key):
					for level_key in gem_dict.get(key):
						if level_key == str(GlobalLevel.current_level):
							gem_dict[str(GlobalLevel.current_world)][str(GlobalLevel.current_level)][index] = true
				else:
					gem_dict[str(GlobalLevel.current_world)][str(GlobalLevel.current_level)] = [false, false, false]
					gem_dict[str(GlobalLevel.current_world)][str(GlobalLevel.current_level)][index] = true
	else:
		gem_dict[str(GlobalLevel.current_world)] = {}
		gem_dict[str(GlobalLevel.current_world)][str(GlobalLevel.current_level)] = [false, false, false]
		gem_dict[str(GlobalLevel.current_world)][str(GlobalLevel.current_level)][index] = true

	set_stat("gems", gem_dict)


func get_timeplay_string() -> String:
	var total_secs: int = get_stat("seconds_played")
	if total_secs == 0: return ""

	var days: int = int(total_secs) / 86400
	total_secs %= 86400

	var hours: int = total_secs / 3600
	total_secs %= 3600

	var mins: int = total_secs / 60

	total_secs %= 60
	var secs: int = total_secs

	return "%s %s, %s %s, %s %s, %s %s" % [days, tr("global.day"), hours, tr("global.hour"), mins, tr("global.minute"), secs, tr("global.second")]


func _ui_profile_selector_profile_pressed() -> void:
	seconds_timer.start(1)
	profile = GlobalUI.profile_index
	load_stats()


func _ui_profile_selector_delete_prompt_yes_pressed() -> void:
	delete_profile(GlobalUI.profile_index)


func _ui_profile_selector_update_prompt_yes_pressed() -> void:
	# update profile, update_profile, profile_updated
	var index: int = GlobalUI.profile_index
	var old_profile: Dictionary = data[index]

	data[index] = DEFAULT_DATA

	for element in old_profile:
		if DEFAULT_DATA.has(element) and typeof(old_profile.get(element)) == typeof(DEFAULT_DATA.get(element)):
			data[index][element] = old_profile[element]

	# Random fix
	if old_profile.rank is String:
		old_profile.rank = GlobalStats.Ranks.NONE

	save_stats(true)

func _ui_pause_menu_return_prompt_yes_pressed() -> void:
	save_stats()

func _ui_settings_erase_all_prompt_extra_yes_pressed() -> void:
	data = [{}, {}, {}, {}, {}]
	save_stats()


func _timer_timeout() -> void:
	if Globals.game_state == Globals.GameStates.LEVEL:
		set_adrenaline(get_stat("adrenaline") + 1)
		GlobalEvents.emit_signal("save_stat_updated")


func _seconds_timeout() -> void:
	if Globals.game_state == Globals.GameStates.MENU:
		return

	set_stat("seconds_played", get_stat("seconds_played") + 1)
	#print(get_stat("seconds_played"))
