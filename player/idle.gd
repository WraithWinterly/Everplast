extends Node

onready var player: Player = get_parent().get_parent()
onready var player_body: KinematicBody2D = get_parent().get_parent().get_node("KinematicBody2D")
onready var fsm = get_parent()


func _process(delta: float) -> void:
	if not Main.get_action_strength_keyboard() == 0 or \
			not Main.get_action_strength_controller() == 0:
		fsm.change_state(fsm.walk)


func _physics_process(delta: float) -> void:
	player_body.basic_movement()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("move_jump") and player_body.is_on_floor():
		fsm.change_state(fsm.jump)

func _start() -> void:
	player.sprinting = false
	player_body.can_dash = true
