extends Label


func _ready() -> void:
	text = get_tree().root.get_node("Main").version


