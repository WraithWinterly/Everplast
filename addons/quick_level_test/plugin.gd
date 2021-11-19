tool
extends EditorPlugin

var regex := RegEx.new()
#
#func _enter_tree() -> void:
#	regex.compile("(world|level)([0-9]+)")


func _exit_tree() -> void:
	pass

const FILE: String = "user://editor.json"

var data: Dictionary = {
	"enabled": false,
	"world": 0,
	"level": 0,
	"pos_x": 0,
	"pos_y": 0,
}

#func _ready() -> void:
#	print(get_tree().edited_scene_root)
#	load_file()
#	yield(get_tree(), "physics_frame")
#	data.enabled = false
#	save_file()


func _unhandled_key_input(event: InputEventKey) -> void:
	if event.pressed and event.scancode == KEY_F7:
		var editor_scene = get_tree().get_edited_scene_root()
		regex.compile("(world|level)([0-9]+)")
		data.enabled = true
		var filename: String = editor_scene.filename
		for regmatch in regex.search_all(filename):
			match regmatch.strings[1]:
				"world":
					data.world = regmatch.strings[2].to_int()
				"level":
					data.level = regmatch.strings[2].to_int()

		var editor_viewport = get_editor_interface().get_editor_viewport()

		data.pos_x = editor_scene.get_local_mouse_position().x
		data.pos_y = editor_scene.get_local_mouse_position().y
		print("Enabling Level Test on World %s, Level %s, POS %s" % [data.world, data.level, Vector2(data.pos_x, data.pos_y)])
		save_file()
		get_editor_interface().play_main_scene()


func save_file() -> void:
	var file: File = File.new()
	file.open(FILE, File.WRITE)
	file.store_string(to_json(data))
	file.close()
	load_file()


func load_file() -> void:
	var file: File = File.new()
	if file.file_exists(FILE):
		file.open(FILE, File.READ)
		var loaded_data = parse_json(file.get_as_text())
		file.close()
		if typeof(loaded_data) == TYPE_DICTIONARY:
			data = loaded_data
		else: save_file()
	else: save_file()
