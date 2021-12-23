extends KinematicBody2D


onready var anim_sprite: AnimatedSprite = $MobComponentManager/SpriteHolder/AnimatedSprite


func _ready() -> void:
	var rng = int(rand_range(0, 2))
	if rng == 0:
		anim_sprite.animation = "default"
	else:
		anim_sprite.animation = "alt"

	if GlobalLevel.current_world == 2:
		$MobComponentManager.health = 10
		$MobComponentManager.max_health = 10
		$MobComponentManager.orb_amount = 10
		$MobComponentManager.attack_damage = 5
		$MobComponentManager/SpriteHolder/AnimatedSprite.modulate = Color8(200, 68, 68, 255)
		$MobComponentManager/WaterMovement.speed = 35
