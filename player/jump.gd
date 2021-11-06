extends Node

onready var fsm: Node = get_parent()
onready var player: Player = get_parent().get_parent()
onready var player_body: KinematicBody2D = get_parent().get_parent().get_node("KinematicBody2D")
onready var jump_sound: AudioStreamPlayer = get_parent().get_parent().get_node("JumpSound")


func _physics_process(delta: float) -> void:
	attempt_correction(3)
	player_body.basic_movement()
	if player.falling:
		fsm.change_state(fsm.fall)

	if player_body.is_on_floor():
		player_body.may_dash = true
		fsm.change_state(fsm.walk)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("move_jump") \
			and player_body.can_second_jump():
		player_body.second_jump_used = true
		player_body.linear_velocity.y = 0
		player_body.air_time = 0
		player_body.linear_velocity.y -= player_body.jump_speed
	elif event.is_action_pressed("move_dash"):
		if player_body.can_dash():
			fsm.change_state(fsm.dash)
		else:
			player.dash_failed()


func attempt_correction(amount: int):
	var delta = get_physics_process_delta_time()
	if player_body.linear_velocity.y < 0 and player_body.test_move(
				player_body.global_transform, Vector2(
					0, player_body.linear_velocity.y * delta)):
		for corner_distance in range(1, amount * 2 ):
			for direction in [-1.0, 1.0]:
				#player_body.linear_velocity.y += 2
				if not player_body.test_move(
						player_body.global_transform.translated(Vector2(
						corner_distance * direction / 2, 0)),
							Vector2(0, player_body.linear_velocity.y * delta)):
					player_body.translate(Vector2(corner_distance * direction / 2, 0))
					if player_body.linear_velocity.x * direction < 0:
						player_body.linear_velocity.x = 0
					return


func start():
	jump_sound.play()
	player_body.linear_velocity.y = 0
	player_body.linear_velocity += player_body.get_floor_velocity()
	player_body.air_time = 0
	player_body.linear_velocity.y -= player_body.jump_speed
	#yield(get_tree().create_timer(0.1), "timeout")
