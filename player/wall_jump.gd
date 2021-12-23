extends Node

const WALL_JUMP_FORCE := Vector2(280, 240)

onready var fsm: Node = get_parent()
onready var player: KinematicBody2D = get_parent().get_parent()
onready var jump_sound: AudioStreamPlayer = get_parent().get_parent().get_node("JumpSound")


func _physics_process(_delta: float) -> void:
	player.basic_movement()

	if player.falling:
		fsm.change_state(fsm.fall)
	elif player.is_on_floor():
		fsm.change_state(fsm.walk)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("move_jump"):
		if (player.wall_checks[0].is_colliding() and not player.facing_right) or (player.wall_checks[1].is_colliding()):
			fsm.change_state(fsm.wall_jump)

	if event.is_action_pressed("ability") and player.can_dash():
		fsm.change_state(fsm.dash)


func start():
	var wall_jump_sound: AudioStreamPlayer = $"../../WallJump"
	wall_jump_sound.pitch_scale = rand_range(0.95, 1.05)
	wall_jump_sound.play()
	GlobalInput.start_normal_vibration()

	player.may_dash = true
	player.second_jump_used = true

	player.facing_right = not player.facing_right

	if player.facing_right:
		player.linear_velocity.x = WALL_JUMP_FORCE.x
	else:
		player.linear_velocity.x = -WALL_JUMP_FORCE.x

	player.linear_velocity.y = -WALL_JUMP_FORCE.y
