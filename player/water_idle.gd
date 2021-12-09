extends Node

onready var player: KinematicBody2D = get_parent().get_parent()
onready var fsm: Node = get_parent()


func _process(_delta: float) -> void:

	if not abs(GlobalInput.get_action_strength()) == 0:
		fsm.change_state(fsm.water_move)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("move_jump"):
		fsm.change_state(fsm.water_move)


func _physics_process(_delta: float) -> void:
	player.basic_movement()


func start() -> void:
	player.sprinting_pressed = false
	player.current_gravity = player.WATER_GRAVITY


func stop() -> void:
	player.current_gravity = player.gravity
	player.current_speed = 0

