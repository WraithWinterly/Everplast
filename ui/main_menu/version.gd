extends Label


func _ready():
	text = get_tree().root.get_node("Main").version


