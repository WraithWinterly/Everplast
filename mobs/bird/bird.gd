extends KinematicBody2D


func _ready() -> void:
	if int(GlobalLevel.current_world) == 1 and int(GlobalLevel.current_level) == 7:
		$MobComponentManager/SpriteHolder/AnimatedSprite.animation = "green"
