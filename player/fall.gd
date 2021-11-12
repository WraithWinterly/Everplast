extends Node

const jump_buffer_time: int = 3
const cayote: float = 0.07

var current_jump_buffer_time: int = 0

var may_jump: bool = true
var jump_buffer: bool = false

onready var fsm: Node = get_parent()
onready var player: Player = get_parent().get_parent()
onready var player_body: KinematicBody2D = get_parent().get_parent().get_node("KinematicBody2D")
onready var timer: Timer = Timer.new()


func _ready() -> void:
	var __: int
	__ = timer.connect("timeout", self, "_timeout")
	add_child(timer)
	current_jump_buffer_time = jump_buffer_time
	timer.wait_time = cayote
	timer.one_shot = true


func _physics_process(_delta: float) -> void:
	if jump_buffer:
		current_jump_buffer_time -= 1
		if current_jump_buffer_time <= 0:
			jump_buffer = false

	player_body.basic_movement()

	if player_body.is_on_floor():
		if jump_buffer:
			fsm.change_state(fsm.jump)
			player_body.may_dash = true
			player_body.second_jump_used = false
			return
		fsm.emit_signal("landed")
		player_body.may_dash = true
		if abs(Main.get_action_strength()) > 0:
			if Input.is_action_pressed("move_sprint"):
				fsm.change_state(fsm.sprint)
			else:
				fsm.change_state(fsm.walk)
		else:
			fsm.change_state(fsm.idle)

	if player_body.can_wall_slide():
		fsm.change_state(fsm.wall_slide)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("move_dash"):
		if player_body.can_dash():
			fsm.change_state(fsm.dash)
		else:
			player.dash_failed()
	if event.is_action_pressed("move_jump"):
		if may_jump:
			fsm.change_state(fsm.jump)
			player_body.cayote_used = true
			may_jump = false
		#elif not player_body.second_jump_used and Globals.game_state == Globals.GameStates.LEVEL:
		elif player_body.can_second_jump():
			fsm.change_state(fsm.jump)
			player_body.second_jump_used = true
			may_jump = false
		else:
			jump_buffer = true


func start() -> void:
	jump_buffer = false
	current_jump_buffer_time = jump_buffer_time
	if not fsm.last_state == fsm.jump and not fsm.last_state == fsm.fall:
		player_body.air_time = 0
		may_jump = true
		timer.start()
	else:
		may_jump = false

	if fsm.last_state == fsm.jump and player_body.cayote_used:
		player_body.second_jump_used = false
		player_body.cayote_used = false


func stop() -> void:
	jump_buffer = false
	current_jump_buffer_time = jump_buffer_time
	player_body.air_time = 0


func _timeout() -> void:
	may_jump = false
