extends Node

var sliding_right := true

onready var player: KinematicBody2D = get_parent().get_parent()
onready var fsm: Node = get_parent()


func _ready() -> void:
	pass


func _physics_process(delta) -> void:
	if player.is_on_floor():
		fsm.change_state(fsm.idle)
	elif (not abs(GlobalInput.get_action_strength()) > 0 and not (Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right"))) or not player.on_wall() and not Input.is_action_pressed("move_jump"):
		if not player.on_wall():
			fsm.change_state(fsm.fall)

	player.linear_velocity.y = delta * (player.current_gravity * 5.5)
	player.linear_velocity = player.move_and_slide(player.linear_velocity, Vector2.UP, true)


func _input(event) -> void:
	if event.is_action_pressed("move_jump"):
		fsm.change_state(fsm.wall_jump)


func start() -> void:
	sliding_right = player.facing_right

	player.linear_velocity.x = 0
	player.may_dash = false
	player.linear_velocity = Vector2(0, 0)
