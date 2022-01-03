extends Sprite


func _ready() -> void:
	if Globals.game_state == Globals.GameStates.WORLD_SELECTOR: return

	frame = int(clamp(GlobalLevel.current_world - 1, 0, INF))

	if flip_h:
		$Sprite.position = Vector2(12, 5.5)
	else:
		$Sprite.position = Vector2(4, 5.5)
