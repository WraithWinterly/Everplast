extends KinematicBody2D


onready var anim_sprite: AnimatedSprite = $EnemyComponentManager/SpriteHolder/AnimatedSprite


func _ready() -> void:
	var rng = int(rand_range(0, 2))
	if rng == 0:
		anim_sprite.animation = "default"
	else:
		anim_sprite.animation = "alt"
