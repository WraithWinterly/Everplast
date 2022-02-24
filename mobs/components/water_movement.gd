extends Node2D

export var speed: int = 25
export var flip_animation_player_path: NodePath
export var enemy_path: NodePath

var current_speed: int
var facing_right: bool = true
var linear_velocity: Vector2
var swim_amount: float = 55
var current_swim_amount: float = 0
var ignore_next_turn: bool = false


onready var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")
onready var flip_animation_player: AnimationPlayer = get_node(flip_animation_player_path)
onready var enemy: KinematicBody2D = get_node(enemy_path)
onready var raycast_wall_left: RayCast2D = $RayCastWallLeft
onready var raycast_wall_right: RayCast2D = $RayCastWallRight


func _physics_process(delta: float) -> void:
	if get_parent().is_physics_processing():
		if raycast_wall_right.is_colliding() and facing_right:
			attempt_flip(true)
			ignore_next_turn = true
		elif raycast_wall_left.is_colliding() and not facing_right:
			attempt_flip(false)
			ignore_next_turn = true
		current_speed = speed
		if facing_right:
			current_speed *= 1
			if current_swim_amount > swim_amount:
				current_swim_amount = 0
				if ignore_next_turn:
					ignore_next_turn = false
					return
				attempt_flip(true)
		else:
			current_speed *= -1
			if current_swim_amount > swim_amount:
				current_swim_amount = 0
				if ignore_next_turn:
					ignore_next_turn = false
					return
				attempt_flip(false)

		current_swim_amount += abs(linear_velocity.x) * delta
		linear_velocity.x = lerp(linear_velocity.x, current_speed, 0.05)
		linear_velocity = enemy.move_and_slide(linear_velocity, Vector2.UP)


func attempt_flip(flip_left: bool = true) -> void:
	if flip_left:
		if not raycast_wall_left.is_colliding():
			facing_right = false
			flip_animation_player.play("flip")

	else:
		if not raycast_wall_right.is_colliding():
			facing_right = true
			flip_animation_player.play_backwards("flip")

