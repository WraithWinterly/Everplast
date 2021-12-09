extends Node2D

export var flip_h := false


func _ready() -> void:
	$Sprite.flip_h = flip_h
	match GlobalLevel.current_world:
		2:
			$Sprite.animation = "2"
		3:
			$Sprite.animation = "3"
		4:
			$Sprite.animation = "4"

