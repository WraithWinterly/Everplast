extends Node2D

export var speed: int = 25
export var flip_animation_player_path: NodePath
export var enemy_path: NodePath

var current_speed: int
var facing_right: bool = true
var linear_velocity: Vector2
var ignore: bool = false


onready var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")
onready var flip_animation_player: AnimationPlayer = get_node(flip_animation_player_path)
onready var enemy: KinematicBody2D = get_node(enemy_path)
onready var raycast_floor_left: RayCast2D = $RayCastFloorLeft
onready var raycast_floor_right: RayCast2D = $RayCastFloorRight
onready var raycast_wall_left: RayCast2D = $RayCastWallLeft
onready var raycast_wall_right: RayCast2D = $RayCastWallRight


func _physics_process(delta: float) -> void:
	if get_parent().is_physics_processing():
		current_speed = speed
		if enemy.is_on_floor():
			if (not raycast_floor_right.is_colliding() or raycast_wall_right.is_colliding()) and facing_right:
				attempt_flip(true)
			elif (not raycast_floor_left.is_colliding() or raycast_wall_left.is_colliding()) and not facing_right:
				attempt_flip(false)

		if facing_right:
			current_speed *= 1
		else:
			current_speed *= -1

		linear_velocity.x = lerp(linear_velocity.x, current_speed, 0.05)
		linear_velocity.y += gravity * delta
		linear_velocity = enemy.move_and_slide(linear_velocity, Vector2.UP)


func attempt_flip(flip_left: bool = true) -> void:
	if ignore:
		if (facing_right and not raycast_wall_left.is_colliding()) \
				or not facing_right and not raycast_floor_right.is_colliding():
			ignore = false
		if raycast_floor_left.is_colliding() and raycast_floor_right.is_colliding() and ignore:
			return
	if flip_left:
		if not raycast_wall_left.is_colliding():
			facing_right = false
			flip_animation_player.play("flip")
		else:
			ignore = true
	else:
		if not raycast_wall_right.is_colliding():
			facing_right = true
			flip_animation_player.play_backwards("flip")
		else:
			ignore = true
