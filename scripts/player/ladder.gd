extends Node

onready var fsm: Node = get_parent()
onready var player: Player = get_parent().get_parent()
onready var player_body: KinematicBody2D = get_parent().get_parent().get_node("KinematicBody2D")


func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("move_up") and player_body.up_check_cast.is_colliding():
		player_body.basic_movement()
		player_body.linear_velocity.y = -player_body.ladder_speed
		player_body.current_gravity = player_body.ladder_gravity
		#player.set_input_speed()
	else:
		if player.in_water:
			fsm.change_state(fsm.water_move)
		else:
			fsm.change_state(fsm.idle)


func start():
	player_body.current_gravity = player_body.ladder_gravity


func stop():
	player_body.current_gravity = player_body.normal_gravity

