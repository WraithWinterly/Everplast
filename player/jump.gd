extends Node

onready var fsm: Node = get_parent()
onready var player: KinematicBody2D = get_parent().get_parent()
onready var jump_sound: AudioStreamPlayer = get_parent().get_parent().get_node("JumpSound")

var checks_ignored := true

func _physics_process(_delta: float) -> void:
	player.basic_movement()

	attempt_correction(2)

	if player.falling:
		fsm.change_state(fsm.fall)

	elif player.is_on_floor() and player.floor_checks[0].is_colliding() and player.floor_checks[1].is_colliding():
		fsm.change_state(fsm.walk)

#	elif player.floor_checks[0].is_colliding() or player.floor_checks[1].is_colliding():
#		#if not player.can_wall_slide(): return
#
#		player.may_dash = true
#		player.second_jump_used = false
#		fsm.change_state(fsm.walk)

	if not player.floor_checks[0].is_colliding() or not player.floor_checks[1].is_colliding():
		checks_ignored = false



func _input(event: InputEvent) -> void:
	if event.is_action_pressed("move_jump"):
		if player.can_wall_slide():
			fsm.change_state(fsm.wall_jump)
		elif player.can_second_jump():
			player.second_jump_used = true
			jump()

	elif event.is_action_pressed("ability"):
		if player.can_dash():
			fsm.change_state(fsm.dash)
		else:
			player.dash_failed()


# Jumping on the top of a corner wil round it out
func attempt_correction(amount: int):
	var delta = get_physics_process_delta_time()
	if player.linear_velocity.y < 0 and player.test_move(player.global_transform,
			Vector2(0, player.linear_velocity.y * delta)):
		for corner_distance in range(1, amount * 2):
			for direction in [-1.0, 1.0]:
				if not player.test_move(
						player.global_transform.translated(Vector2(
						corner_distance * direction / 2, 0)),
							Vector2(0, player.linear_velocity.y * delta)):
					player.translate(Vector2(corner_distance * direction / 2, 0))
					if player.linear_velocity.x * direction < 0:
						player.linear_velocity.x = 0
					return


func start() -> void:
	player.may_dash = true
	jump_sound.play()
	player.air_time = 0
	jump()



func jump() -> void:
	checks_ignored = true
	player.air_time = 0

	# Falling Platform Jump Height Fix
	var collider: Object = null

	if not player.floor_checks[1].get_collider() == null:
		if player.floor_checks[1].get_collider().is_in_group("FallingPlatform"):
			collider = player.floor_checks[1].get_collider()
	elif not player.floor_checks[0].get_collider() == null:
		if player.floor_checks[0].get_collider().is_in_group("FallingPlatform"):
			collider = player.floor_checks[0].get_collider()

	if not collider == null:
		player.linear_velocity = player.move_and_slide(player.linear_velocity, Vector2.UP)
		var floor_velocity: float = abs(player.get_floor_velocity().y)
		yield(get_tree(), "physics_frame")
		player.linear_velocity.y = -player.jump_speed
		player.linear_velocity.y -= floor_velocity
		return

	player.linear_velocity.y = -player.jump_speed
