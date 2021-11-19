tool
extends Node
class_name LevelTest

const FILE: String = "user://editor.json"

var data: Dictionary = {
	"enabled": false,
	"world": 0,
	"level": 0,
	"pos_x": 0,
	"pos_y": 0,
}

func _ready() -> void:
	load_file()
	if data.enabled:
		data.enabled = false
		save_file()
		if PlayerStats.data[0].size() > 0:
		#UI.emit_signal("changed", UI.MAIN_MENU_QUICK_PLAY)
			yield(UI, "faded")
			Signals.emit_signal("level_changed", data.world, data.level)
			yield(UI, "faded")
			yield(UI, "faded")
			yield(get_tree(), "physics_frame")
			var player: KinematicBody2D = get_node(Globals.player_body_path)
			player.global_position.x = data.pos_x
			player.global_position.y = data.pos_y


func save_file() -> void:
	var file: File = File.new()
	var __: int = file.open(FILE, File.WRITE)
	file.store_string(to_json(data))
	file.close()
	load_file()


func load_file() -> void:
	var file: File = File.new()
	if file.file_exists(FILE):
		var __: int = file.open(FILE, File.READ)
		var loaded_data = parse_json(file.get_as_text())
		file.close()
		if typeof(loaded_data) == TYPE_DICTIONARY:
			data = loaded_data
		else: save_file()
	else: save_file()
