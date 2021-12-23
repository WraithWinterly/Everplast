extends ColorRect


func _physics_process(_delta: float) -> void:
	rect_size.x = get_viewport().size.x * 1.25
	rect_size.y = get_viewport().size.x * 1.25
