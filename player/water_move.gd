extends Node

onready var fsm: Node = get_parent()
onready var player: Player = get_parent().get_parent()
onready var player_body: KinematicBody2D = get_parent().get_parent().get_node("KinematicBody2D")


func _process(_delta: float) -> void:
#	if not Main.get_action_strength() == 0 or \
#			not Main.get_action_strength().y == 0:
#		set_input_speed()
	if player_body.is_on_floor():
		fsm.change_state(fsm.water_idle)


func basic_movement(var delta: float):
	player_body.current_speed = player_body.water_speed
	down_check()
	player.falling = player_body.linear_velocity.y > 0
	player_body.current_speed *= Main.get_action_strength()
	player_body.linear_velocity.x = lerp(
			player_body.linear_velocity.x, player_body.current_speed,
			0.14
			)
	player_body.linear_velocity.y += delta * player_body.current_gravity
	player_body.linear_velocity = player_body.move_and_slide(
			player_body.linear_velocity,
			Vector2.UP
			)


func _physics_process(var delta: float) -> void:
	sprint_and_jump(delta)
	basic_movement(delta)


func set_input_speed() -> void:
	player.walking = not Main.get_action_strength() == 0
	player_body.current_speed = player_body.water_speed


func sprint_and_jump(_delta: float) -> void:
	if Input.is_action_just_pressed("move_jump"):
		player_body.air_time = 0
		player_body.linear_velocity.y = -player_body.water_jump_speed


func down_check() -> void:
	if player_body.is_on_floor() and \
			Input.is_action_just_pressed("move_down") and not\
			player_body.down_check_cast.is_colliding():
		player_body.position.y += 2


func start() -> void:
	player_body.current_gravity = player_body.water_gravity


func stop() -> void:
	player_body.current_gravity = player_body.gravity
	player_body.current_speed = 0
