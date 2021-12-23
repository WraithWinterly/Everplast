extends Node2D

export var flip_h := false


func _ready() -> void:
	$Sprite.flip_h = flip_h
	if flip_h:
		$Sprite.offset.x += 1

	if Globals.game_state == Globals.GameStates.WORLD_SELECTOR: return

	match GlobalLevel.current_world:
		2:
			$Sprite.animation = "2"
		3:
			$Sprite.animation = "3"
		4:
			$Sprite.animation = "4"

