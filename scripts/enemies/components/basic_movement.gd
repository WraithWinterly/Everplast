extends Node2D

export var speed: int = 25
export var raycast_floor_path: NodePath
export var raycast_wall_path: NodePath
export var flip_animation_player_path: NodePath
export var enemy_path: NodePath

var current_speed: int
var facing_right: bool = true
var linear_velocity: Vector2

onready var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")
onready var enemy: KinematicBody2D = get_node(enemy_path)
onready var flip_animation_player: AnimationPlayer = get_node(flip_animation_player_path)
onready var raycast_floor: RayCast2D = get_node(raycast_floor_path)
onready var raycast_wall: RayCast2D = get_node(raycast_wall_path)


func _physics_process(delta: float) -> void:
	if enemy.is_physics_processing():
		current_speed = speed
		if enemy.is_on_floor():
			if not raycast_floor.is_colliding() or raycast_wall.is_colliding():
				if facing_right:
					facing_right = false
					raycast_floor.position = Vector2(-4, 4)
					raycast_wall.cast_to = Vector2(-7, 0)
					if enemy.is_on_floor():
						flip_animation_player.play("flip")
				else:
					facing_right = true
					raycast_floor.position = Vector2(14, 4)
					raycast_wall.cast_to = Vector2(7, 0)
					if enemy.is_on_floor():
						flip_animation_player.play_backwards("flip")

		if facing_right:
			current_speed *= 1
		else:
			current_speed *= -1

		linear_velocity.x = lerp(linear_velocity.x, current_speed, 0.05)
		linear_velocity.y += gravity * delta
		linear_velocity = enemy.move_and_slide(linear_velocity, Vector2.UP)
