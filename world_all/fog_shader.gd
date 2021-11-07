extends ColorRect

func _physics_process(delta: float) -> void:
	rect_size.x = get_viewport().size.x
	rect_size.y = get_viewport().size.x
