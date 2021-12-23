extends Node

onready var player: KinematicBody2D = get_parent().get_parent()
onready var fsm: Node = get_parent()

# Add mobile toggle sprint later

func _physics_process(_delta: float) -> void:
	player.basic_movement()

	if not player.sprinting_pressed:
		fsm.change_state(fsm.idle)
	elif not abs(GlobalInput.get_action_strength()) > 0:
		fsm.change_state(fsm.walk)
	elif not player.on_floor() and player.falling:
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
