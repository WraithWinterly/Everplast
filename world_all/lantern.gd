extends Sprite


func _ready() -> void:
	frame = int(clamp(LevelController.current_world - 1, 0, 999))
	if flip_h:
		$Sprite.position = Vector2(12, 5.5)
	else:
		$Sprite.position = Vector2(4, 5.5)
