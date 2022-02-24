extends Node

onready var fsm: Node = get_parent()
onready var player: KinematicBody2D = get_parent().get_parent()


func _process(_delta: float) -> void:
	if is_equal_approx(GlobalInput.get_action_strength(), 0):
		fsm.change_state(fsm.idle)
	if not player.on_floor() and player.falling:
		fsm.change_state(fsm.fall)


func _physics_process(_delta: float) -> void:
	player.basic_movement()
	if player.sprinting_pressed and player.is_on_floor():
		fsm.change_state(fsm.sprint)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("move_jump") and player.is_on_floor():
		fsm.change_state(fsm.jump)


func start() -> void:
	player.may_dash = true
	player.sprinting = false


func stop() -> void:
	player.current_speed = 0
