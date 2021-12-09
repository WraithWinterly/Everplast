extends Node

const jump_buffer_time: int = 3
const cayote: float = 0.07

var current_jump_buffer_time: int = 0

var may_jump := true
var jump_buffer := false

onready var fsm: Node = get_parent()
onready var player: KinematicBody2D = get_parent().get_parent()
onready var timer := Timer.new()


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

	player.basic_movement()


	if player.can_wall_slide():
		fsm.change_state(fsm.wall_slide)

	elif player.is_on_floor():
		if jump_buffer:
			player.second_jump_used = false
			player.may_dash = true
			fsm.change_state(fsm.jump)
			return
		fsm.emit_signal("landed")
		player.may_dash = true
		if abs(GlobalInput.get_action_strength()) > 0:
			if player.sprinting_pressed:
				fsm.change_state(fsm.sprint)
			else:
				fsm.change_state(fsm.walk)
		else:
			fsm.change_state(fsm.idle)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ability"):
		if player.can_dash():
			fsm.change_state(fsm.dash)
		else:
			player.dash_failed()

	if event.is_action_pressed("move_jump"):
		if player.can_wall_slide():
			fsm.change_state(fsm.wall_jump)
		elif not player.second_jump_used:
			if may_jump:
				fsm.change_state(fsm.jump)
				player.cayote_used = true
				may_jump = false

			#elif not player.second_jump_used and Globals.game_state == Globals.GameStates.LEVEL:
			elif player.can_second_jump():
				player.second_jump_used = true
				fsm.change_state(fsm.jump)
				may_jump = false
			else:
				jump_buffer = true


func start() -> void:
	jump_buffer = false
	current_jump_buffer_time = jump_buffer_time
	if not fsm.last_state == fsm.jump and not fsm.last_state == fsm.fall:
		player.air_time = 0
		may_jump = true
		timer.start()
	else:
		may_jump = false

	if fsm.last_state == fsm.jump and player.cayote_used:
		player.second_jump_used = false
		player.cayote_used = false


func stop() -> void:
	jump_buffer = false
	current_jump_buffer_time = jump_buffer_time
	player.air_time = 0


func _timeout() -> void:
	may_jump = false
