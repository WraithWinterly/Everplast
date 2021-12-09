extends KinematicBody2D


onready var mob_component := $MobComponentManager as MobComponentManager
onready var fly_movement := $MobComponentManager/FlyMovement as Node2D
onready var anim_sprite := $MobComponentManager/SpriteHolder/AnimatedSprite as AnimatedSprite


func _ready() -> void:
	var __: int
	__ = mob_component.connect("hit", self, "_hit")


func _hit() -> void:
	if fly_movement.state == fly_movement.States.FLY:
		anim_sprite.animation = "normal"
