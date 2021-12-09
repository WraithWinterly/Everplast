extends Node

const FILE: String = "user://quick_play.json"

var data: Dictionary = {
	"last_profile": -1,
}

var available := false


func _ready() -> void:
	var __: int
	__ = GlobalEvents.connect("level_changed", self, "_level_changed")
	__ = GlobalEvents.connect("save_file_saved", self, "_save_file_saved")
	__ = GlobalEvents.connect("ui_pause_menu_return_prompt_yes_pressed", self, "_ui_pause_menu_return_prompt_yes_pressed")

	load_stats()
	update_stats()


func update_stats() -> void:
	if data.last_profile == -1:
		available = false
		return
	else:
		if Globals.game_state == Globals.GameStates.MENU:
			GlobalSave.load_stats()
		available = GlobalSave.verify(data.last_profile)


func save_stats() -> void:
	var file: File = File.new()
	#file.open_encrypted_with_pass(FILE, File.WRITE, KEY)
	var __: int = file.open(FILE, File.WRITE)
	file.store_string(to_json(data))
	file.close()
	load_stats()


func load_stats() -> void:
	var file: File = File.new()
	if file.file_exists(FILE):
		#file.open_encrypted_with_pass(FILE, File.READ, KEY)
		var __: int = file.open(FILE, File.READ)
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


func _level_changed(_world: int, _level: int) -> void:
	data.last_profile = GlobalSave.profile
	save_stats()
	update_stats()


func _save_file_saved(_noti: bool = false) -> void:
	data.last_profile = GlobalSave.profile
	save_stats()
	update_stats()


func _ui_pause_menu_return_prompt_yes_pressed() -> void:
	if Globals.game_state == Globals.GameStates.WORLD_SELECTOR:
		update_stats()
