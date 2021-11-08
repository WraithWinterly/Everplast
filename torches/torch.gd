extends Node2D

export var flip_h: bool = false

func _ready():
	$Sprite.flip_h = flip_h
	match LevelController.current_world:
		2:
			$Sprite.animation = "2"
		3:
			$Sprite.animation = "3"
		4:
			$Sprite.animation = "4"
		
