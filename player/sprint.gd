extends Node

onready var player: Node2D = get_parent().get_parent()
onready var player_body: KinematicBody2D = get_parent().get_parent().get_node("KinematicBody2D")
onready var fsm: Node = get_parent()

# Add mobile toggle sprint later

func _physics_process(_delta: float) -> void:
	player_body.basic_movement()
	if not Input.is_action_pressed("move_sprint"):
		fsm.change_state(fsm.walk)
	elif not abs(Main.get_action_strength()) > 0:
		fsm.change_state(fsm.idle)
	elif player.falling:
		fsm.change_state(fsm.fall)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("move_jump"):
		fsm.change_state(fsm.jump)


func start() -> void:
	player.sprinting = true


#func stop() -> void:
#	yield(get_tree(), "physics_frame")
#	yield(get_tree(), "physics_frame")
#	if player_body.is_on_floor():
#		player.sprinting = false
