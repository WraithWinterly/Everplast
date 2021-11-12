extends Node

var wall_jump_force: int = 300

onready var fsm: Node = get_parent()
onready var player: Player = get_parent().get_parent()
onready var player_body: KinematicBody2D = get_parent().get_parent().get_node("KinematicBody2D")
onready var jump_sound: AudioStreamPlayer = get_parent().get_parent().get_node("JumpSound")


func _physics_process(_delta: float) -> void:
	player_body.basic_movement()
	if player.falling:
		fsm.change_state(fsm.fall)

	if player_body.is_on_floor():
		player_body.may_dash = true
		fsm.change_state(fsm.walk)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("move_jump") and not player_body.second_jump_used:
		player_body.may_dash = true
		player_body.second_jump_used = true
		player_body.linear_velocity.y = 0
		player_body.air_time = 0
		player_body.linear_velocity.y -= player_body.jump_speed
	elif event.is_action_pressed("move_dash") and player_body.can_dash():
		fsm.change_state(fsm.dash)


func start():
	player_body.may_dash = true
	player_body.second_jump_used = false
	if player.facing_right:
		player_body.linear_velocity.x += wall_jump_force
	else:
		player_body.linear_velocity.x -= wall_jump_force
	jump_sound.play()
	player_body.linear_velocity.y = 0

	player_body.air_time = 0
	player_body.linear_velocity.y -= player_body.jump_speed
