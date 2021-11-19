extends Node

var dash_speed: int = 200
var dash_time: float = 0

onready var rng := RandomNumberGenerator.new()
onready var dash_sound: AudioStreamPlayer = get_parent().get_parent().get_node("DashSound")
onready var player: Node2D = get_parent().get_parent()
onready var player_body: KinematicBody2D = get_parent().get_parent().get_node("KinematicBody2D")
onready var fsm: Node = get_parent()


func _physics_process(delta: float) -> void:
	player_body.linear_velocity.x = lerp(player_body.linear_velocity.x, player_body.current_speed, 0.05)
	player_body.linear_velocity = player_body.move_and_slide(player_body.linear_velocity, Vector2.UP, true)

	if player_body.is_on_wall() or player_body.is_on_floor():
		fsm.change_state(fsm.fall)

	dash_time += 1
	if dash_time >= int(0.35 * 1 / delta):
		fsm.change_state(fsm.fall)


func start() -> void:
	player.dashing = true
	player_body.second_jump_used = true
	dash_time = 0
	player_body.linear_velocity = Vector2(0, 0)
	if player.facing_right:
		player_body.linear_velocity.x += dash_speed
	else:
		player_body.linear_velocity.x -= dash_speed
	player_body.may_dash = false
	dash_sound.pitch_scale = rng.randf_range(0.8, 1.2)
	dash_sound.play()
	Signals.emit_signal("player_dashed")


func stop() -> void:
	dash_time = 0
	player_body.linear_velocity.x = 0
	yield(get_tree(), "physics_frame")
	player.dashing = false


func _timeout() -> void:
	fsm.change_state(fsm.fall)
