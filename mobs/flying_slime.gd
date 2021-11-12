extends KinematicBody2D


onready var enemy_component: EnemyComponentManager = $EnemyComponentManager
onready var fly_movement: Node2D = $EnemyComponentManager/FlyMovement
onready var anim_sprite: AnimatedSprite = $EnemyComponentManager/SpriteHolder/AnimatedSprite


func _ready() -> void:
	var __: int
	__ = enemy_component.connect("hit", self, "_hit")


func _hit() -> void:
	if fly_movement.state == fly_movement.States.FLY:
		fly_movement.state = fly_movement.States.NORMAL
		anim_sprite.animation = "normal"
		$"EnemyComponentManager/AttackTouch".flying_enemy = false
