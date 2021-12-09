extends Node

var dash_speed: int = 225
var dash_time: float = 0

onready var fsm: Node = get_parent()
onready var player: KinematicBody2D = get_parent().get_parent()
onready var rng := RandomNumberGenerator.new()
onready var dash_sound: AudioStreamPlayer = get_parent().get_parent().get_node("DashSound")


func _physics_process(delta: float) -> void:
	player.linear_velocity.x = lerp(player.linear_velocity.x, player.current_speed, 0.05)
	player.linear_velocity = player.move_and_slide(player.linear_velocity, Vector2.UP, true)

	if player.is_on_wall() or player.is_on_floor():
		fsm.change_state(fsm.fall)

	dash_time += 1
	if dash_time >= int(0.35 * 1 / delta):
		fsm.change_state(fsm.fall)


func start() -> void:
	player.dashing = true
	player.second_jump_used = true
	dash_time = 0
	player.linear_velocity = Vector2(0, 0)
	if player.facing_right:
		player.linear_velocity.x += dash_speed
	else:
		player.linear_velocity.x -= dash_speed
	player.may_dash = false
	dash_sound.pitch_scale = rng.randf_range(0.8, 1.2)
	dash_sound.play()
	GlobalEvents.emit_signal("player_dashed")


func stop() -> void:
	dash_time = 0
	player.linear_velocity.x = 0
	yield(get_tree(), "physics_frame")
	player.dashing = false


func _timeout() -> void:
	fsm.change_state(fsm.fall)
