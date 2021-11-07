extends Node

var max_cayote: int = 10
var cayote: int = 0

onready var player: Node2D = get_parent().get_parent()
onready var player_body: KinematicBody2D = get_parent().get_parent().get_node("KinematicBody2D")
onready var fsm: Node = get_parent()


func _ready() -> void:
	cayote = max_cayote


func _physics_process(delta) -> void:
	if not player_body.on_wall():
		if cayote <= 0 or abs(Main.get_action_strength()) <= 0:
			fsm.change_state(fsm.fall)
		else:
			cayote -= 1
	elif player_body.is_on_floor():
		fsm.change_state(fsm.idle)

	player_body.linear_velocity.y = delta * (player_body.current_gravity * 5.5)
	player_body.linear_velocity = player_body.move_and_slide(player_body.linear_velocity, Vector2.UP, true)


func _input(event) -> void:
	if player_body.on_wall() and event.is_action_pressed("move_jump"):
		player.facing_right = not player.facing_right
		fsm.change_state(fsm.wall_jump)


func start() -> void:
	player_body.may_dash = false
	cayote = max_cayote
	player_body.linear_velocity = Vector2(0, 0)
