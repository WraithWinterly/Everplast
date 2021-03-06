extends Node2D

enum States {
	FLY,
	NORMAL
}

export var speed: int = 25
export var fly_speed: int = 30
export var flip_animation_player_path: NodePath
export var enemy_path: NodePath
export var fly_amount_max: int = 55
export var fly_amount_min: int = 45

var fly_amount: int
var current_fly_amount: float = 0
var current_speed: int
var facing_right: bool = true
var linear_velocity: Vector2
var flying: bool = true
var ignore: bool = false
var state: int = States.FLY
var ignore_next: bool = false

onready var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")
onready var flip_animation_player: AnimationPlayer = get_node(flip_animation_player_path)
onready var enemy: KinematicBody2D = get_node(enemy_path)
onready var raycast_floor_left: RayCast2D = $RayCastFloorLeft
onready var raycast_floor_right: RayCast2D = $RayCastFloorRight
onready var raycast_wall_left: RayCast2D = $RayCastWallLeft
onready var raycast_wall_right: RayCast2D = $RayCastWallRight
onready var basic_movement: Node2D = $BasicMovement


func _ready() -> void:
	var __: int
	__ = get_parent().connect("died", self, "_died")
	__ = get_parent().connect("hit", self, "_hit")

	fly_amount = int(rand_range(fly_amount_max, fly_amount_min))
	basic_movement.set_process(false)
	basic_movement.set_physics_process(false)
	basic_movement.enemy = enemy
	basic_movement.flip_animation_player = flip_animation_player


func _physics_process(delta: float) -> void:
	if state == States.NORMAL:
		basic_movement.set_process(true)
		basic_movement.set_physics_process(true)

	elif state == States.FLY:
		basic_movement.set_process(false)
		basic_movement.set_physics_process(false)

		current_speed = fly_speed

		if facing_right:
			current_speed *= 1
			if current_fly_amount > fly_amount:
				current_fly_amount = 0
				if ignore_next:
					ignore_next = false
					return
				attempt_flip(true)
		else:
			current_speed *= -1
			if current_fly_amount > fly_amount:
				current_fly_amount = 0
				if ignore_next:
					ignore_next = false
					return
				attempt_flip(false)


		if raycast_wall_right.is_colliding():
			attempt_flip(true)
			ignore_next = true
		elif raycast_wall_left.is_colliding():
			attempt_flip(false)
			ignore_next = true

		current_fly_amount += abs(linear_velocity.x) * delta
		linear_velocity.x = lerp(linear_velocity.x, current_speed, 0.05)
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


func _hit() -> void:
	if state == States.FLY:
		state = States.NORMAL
		get_parent().get_node("AttackTouch").flying_enemy = false


func _died() -> void:
	get_node("BasicMovement").dying = true
