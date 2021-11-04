extends Node

const FILE: String = \
		"user://fast_load.json"


var available: bool = false

var data: Dictionary = {
	"last_profile": -1,
}

onready var main: Main = get_tree().root.get_node("Main")


func _ready() -> void:
	UI.connect("changed", self, "_ui_changed")
	UI.connect("faded", self, "_ui_changed")
	Signals.connect("level_changed", self, "_level_changed")
	Signals.connect("save", self, "_game_save")

	load_stats()
	update_stats()


func update_stats() -> void:
	if data.last_profile == -1:
		available = false
		return
	else:
		PlayerStats.load_stats()
		available = PlayerStats.verify(data.last_profile)
		print("updated")
		print(available)


func save_stats() -> void:
	var file: File = File.new()
	#file.open_encrypted_with_pass(FILE, File.WRITE, KEY)
	file.open(FILE, File.WRITE)
	file.store_string(to_json(data))
	file.close()
	load_stats()


func load_stats() -> void:
	var file: File = File.new()
	if file.file_exists(FILE):
		#file.open_encrypted_with_pass(FILE, File.READ, KEY)
		file.open(FILE, File.READ)
		var test = parse_json(file.get_as_text())
		if test is Dictionary:
			data = parse_json(file.get_as_text())
		else:
			save_stats()
			return

		file.close()
	else:
		save_stats()


func reset() -> void:
	data.last_profile = -1
	update_stats()
	save_stats()


func _ui_changed(menu: int = 0) -> void:
	match menu:
		UI.MAIN_MENU:
			load_stats()
			update_stats()
	match UI.last_menu:
		UI.PAUSE_MENU_RETURN_PROMPT, UI.PROFILE_SELECTOR:
			load_stats()
			update_stats()


func _game_save() -> void:
	data.last_profile = PlayerStats.current_save_profile
	save_stats()
	update_stats()


func _level_changed(_world: int, _level: int) -> void:
	data.last_profile = PlayerStats.current_save_profile
	save_stats()
	update_stats()
