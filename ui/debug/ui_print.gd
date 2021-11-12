extends Control

var prev_label: Label = null


func _ready() -> void:
	var __: int
	__ = UI.connect("screen_print", self, "_screen_print")
	pause_mode = PAUSE_MODE_PROCESS


func _screen_print(what: String) -> void:
	var label: Label = Label.new()
	label.rect_position = Vector2(10, 10)
	if is_instance_valid(prev_label):
		label.rect_position.y = prev_label.rect_position.y + 15
	prev_label = label
	add_child(label)
	label.text = what
	yield(get_tree().create_timer(3), "timeout")
	label.queue_free()
