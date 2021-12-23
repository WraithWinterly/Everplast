extends Node2D

export var speed: int = 25
export var anim_speed_scale_default: int = 1
export var anim_speed_scale_run: int = 3
export var flip_animation_player_path: NodePath
export var enemy_path: NodePath
export var animated_sprite_path: NodePath
var current_speed: int
var facing_right: bool = true
var linear_velocity: Vector2

var limit_turn: bool = false
# Used by fly component
var dying: bool = false

onready var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")
onready var flip_animation_player: AnimationPlayer
onready var enemy: KinematicBody2D
onready var animated_sprite: AnimatedSprite = get_node(animated_sprite_path)
onready var raycast_floor_left := $RayCastFloorLeft as RayCast2D
onready var raycast_floor_right := $RayCastFloorRight as RayCast2D
onready var raycast_wall_left := $RayCastWallLeft as RayCast2D
onready var raycast_wall_right := $RayCastWallRight as RayCast2D


func _ready() -> void:
	yield(get_tree(), "idle_frame")

	var __: int
	__ = GlobalEvents.connect("mob_used_springboard", self, "_mob_used_springboard")
	if is_physics_processing():
		enemy = get_node(enemy_path)
		flip_animation_player = get_node(flip_animation_player_path)

	raycast_floor_left.add_exception(enemy)
	raycast_floor_right.add_exception(enemy)
	raycast_wall_left.add_exception(enemy)
	raycast_wall_right.add_exception(enemy)


func _physics_process(delta: float) -> void:
	# Fix for crashing underneath a FlyMovement
	if enemy == null:
		yield(get_tree(), "idle_frame")
		return

	if get_parent().is_physics_processing() and not dying:
		var player_pos = get_node(GlobalPaths.PLAYER).global_position

		if limit_turn:
			if not player_pos.y + 20 <= global_position.y:
				if int(player_pos.x) > int(enemy.global_position.x):
					if not facing_right:
						attempt_flip(false)
				elif int(player_pos.x) < int(enemy.global_position.x):
					if facing_right:
						attempt_flip(true)
		else:
			if int(player_pos.x) > int(enemy.global_position.x):
				if not facing_right:
					attempt_flip(false)
			elif int(player_pos.x) < int(enemy.global_position.x):
				if facing_right:
					attempt_flip(true)

		if ((raycast_floor_left.is_colliding() and not facing_right) or (raycast_floor_right.is_colliding() and facing_right)) \
				and not (raycast_wall_left.is_colliding() and not facing_right) and not (raycast_wall_right.is_colliding() and facing_right):
			limit_turn = true
			animated_sprite.animation = "chase"
			animated_sprite.speed_scale = anim_speed_scale_run
			current_speed = speed
			if facing_right:
				current_speed *= 1
			else:
				current_speed *= -1
			linear_velocity.x = lerp(linear_velocity.x, current_speed, 0.05)
		else:
			limit_turn = false
			linear_velocity.x = 0
			animated_sprite.animation = "default"
			animated_sprite.speed_scale = anim_speed_scale_default

		#print(linear_velocity.x)
		# Don't play running anim while shoved against a wall
		# Dunno why 7.5 but works


		#linear_velocity.x = lerp(linear_velocity.x, current_speed, 0.05)
		linear_velocity.y += gravity * delta
		linear_velocity = enemy.move_and_slide(linear_velocity, Vector2.UP)

#	print(linear_velocity.x)
#	if is_equal_approx(linear_velocity.x, 0):
#		if not animated_sprite.animation == "default":
#			print("ya")
#			animated_sprite.animation = "default"
#			animated_sprite.speed_scale = anim_speed_scale_default
#			animated_sprite.playing = true


func attempt_flip(flip_left: bool = true) -> void:
	if enemy.get_slide_count() > 0:
		for i in enemy.get_slide_count():
			var collider = enemy.get_slide_collision(i).collider
			if not collider == null:
				if collider.is_in_group("Enemy"):
					return
	if flip_left:
		facing_right = false
		flip_animation_player.play("flip")

	else:
		facing_right = true
		flip_animation_player.play_backwards("flip")


func _mob_used_springboard(body: Node, amount: int) -> void:
	if body == enemy:
		linear_velocity.y = -amount * 3
