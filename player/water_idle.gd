extends Node

onready var player_body: KinematicBody2D = get_parent().get_parent().get_node("KinematicBody2D")
onready var fsm: Node = get_parent()


func _process(delta: float) -> void:
	if not Main.get_action_strength() == 0:
		fsm.change_state(fsm.water_move)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("move_jump"):
		fsm.change_state(fsm.water_move)


func _physics_process(delta: float) -> void:
		player_body.basic_movement()


func start() -> void:
	player_body.current_gravity = player_body.water_gravity


func stop() -> void:
	player_body.current_gravity = player_body.gravity
	player_body.current_speed = 0

