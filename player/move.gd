extends Node

onready var fsm: Node = get_parent()
onready var player: Player = get_parent().get_parent()
onready var player_body: KinematicBody2D = get_parent().get_parent().get_node("KinematicBody2D")


func _process(delta: float) -> void:
	if Main.get_action_strength_keyboard() == 0 and \
			Main.get_action_strength_controller() == 0:
		fsm.change_state(fsm.idle)
	if not player_body.is_on_floor() and player.falling:
		fsm.change_state(fsm.fall)


func _physics_process(delta: float) -> void:
	player_body.basic_movement()
	if Input.is_action_pressed("move_sprint") and player_body.is_on_floor():
		fsm.change_state(fsm.sprint)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("move_jump") and player_body.is_on_floor():
		fsm.change_state(fsm.jump)


func start():
	player_body.may_dash = true
#	if Input.is_action_just_pressed("move_jump") and player.kinematic_body.is_on_floor():
#		player_body.air_time = 0
#		player_body.linear_velocity.y -= player_body.jump_speed
	player.sprinting = false


func stop():
	player_body.current_speed = 0
