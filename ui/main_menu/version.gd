extends Label


func _ready() -> void:
	yield(get_tree(), "physics_frame")
	text = Globals.version_string


