extends Node

onready var fsm: Node = get_parent()
onready var player: KinematicBody2D = get_parent().get_parent()

var ignore := false


func _process(_delta: float) -> void:
	if ignore: return

	if player.is_on_floor() and abs(GlobalInput.get_action_strength()) == 0:
		fsm.change_state(fsm.water_idle)


func basic_movement(var delta: float):

	player.current_speed = player.water_speed

	down_check()

	player.falling = player.linear_velocity.y > 0

	player.current_speed *= GlobalInput.get_action_strength()

	player.linear_velocity.x = lerp(
			player.linear_velocity.x, player.current_speed,
			0.14
			)

	player.linear_velocity.y += delta * player.current_gravity
	player.linear_velocity = player.move_and_slide(
			player.linear_velocity, Vector2.UP)


func _physics_process(var delta: float) -> void:
	sprint_and_jump(delta)
	basic_movement(delta)


func set_input_speed() -> void:
	player.walking = not GlobalInput.get_action_strength() == 0
	player.current_speed = player.water_speed


func sprint_and_jump(_delta: float) -> void:
	if Input.is_action_just_pressed("move_jump"):
		player.air_time = 0
		player.linear_velocity.y = -player.water_jump_speed


func down_check() -> void:
	if player.is_on_floor() and \
			Input.is_action_just_pressed("move_down") and not\
			player.down_check_cast.is_colliding():
		player.position.y += 2


func start() -> void:
	ignore = true
	yield(get_tree(), "physics_frame")
	ignore = false
	player.current_gravity = player.WATER_GRAVITY


func stop() -> void:
	player.current_gravity = player.gravity
	player.current_speed = 0
