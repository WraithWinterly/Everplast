extends Node

onready var fsm = get_parent()
onready var player: KinematicBody2D = get_parent().get_parent()


func _process(_delta: float) -> void:
	if not GlobalInput.get_action_strength_keyboard() == 0 or \
			not GlobalInput.get_action_strength_controller() == 0:
		fsm.change_state(fsm.walk)


func _physics_process(_delta: float) -> void:
	player.basic_movement()
	player.sprinting = false
	if not abs(GlobalInput.get_action_strength()) > 0:
		player.sprinting_pressed = false


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("move_jump") and player.is_on_floor():
		if player.sprinting_pressed:
			player.sprinting = true
		fsm.change_state(fsm.jump)

func _start() -> void:
	player.sprinting = false
	player.can_dash = true
