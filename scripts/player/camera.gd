extends Camera2D

enum {
	NORMAL,
	SUB
}

const max_offset := Vector2(100, 75)
const normal_zoom := Vector2(0.2, 0.2)
const sprint_zoom := Vector2(0.21, 0.21)
const decay: float = 0.8
const max_roll: float = 0.1

var current_zoom: Vector2 = normal_zoom
var trauma: float = 0.0
var trauma_power: float = 2.5
var noise_y: int = 0
var state: int = NORMAL

onready var noise = OpenSimplexNoise.new()
onready var player = get_parent().get_parent()
onready var player_body: KinematicBody2D = get_parent().get_parent().get_node("KinematicBody2D")
onready var fsm: Node = get_parent().get_parent().get_node("FSM")


func _ready() -> void:
	Signals.connect("sublevel_changed", self, "_sublevel_changed")
	fsm.connect("state_changed", self, "_state_changed")
	randomize()
	noise.seed = randi()
	noise.period = 4
	noise.octaves = 2
	update_camera_positions(NORMAL)

func add_trauma(amount) -> void:
	trauma = min(trauma + amount, 1.0)


func set_trauma(amount) -> void:
	trauma = min(amount, 1.0)


func _process(delta) -> void:
	if trauma:
		trauma = max(trauma - decay * delta, 0)
		shake()


func _physics_process(delta: float) -> void:
	zoom = lerp(zoom, current_zoom, 0.15)
	if player.sprinting:
		current_zoom = sprint_zoom
	else:
		current_zoom = normal_zoom


func shake() -> void:
	var amount = pow(trauma, trauma_power)
	noise_y += 1
	rotation = max_roll * amount * noise.get_noise_2d(noise.seed, noise_y)
	offset.x = max_offset.x * amount * noise.get_noise_2d(noise.seed*2, noise_y)
	offset.y = max_offset.y * amount * noise.get_noise_2d(noise.seed*3, noise_y)


func _state_changed() -> void:
	if fsm.current_state == fsm.dash and not player_body.is_on_wall():
		add_trauma(0.4)


func _sublevel_changed(_pos: Vector2) -> void:
	if state == NORMAL:
		state = SUB
		update_camera_positions(state)
	else:
		state = NORMAL
		update_camera_positions(state)


func update_camera_positions(var mode: int) -> void:
	if mode == NORMAL:
		var level: Node2D = get_node_or_null(Globals.level_path)
		if not level == null:
			var limit_left_top_position = level.get_node_or_null("CameraPositions/TopLeft")
			var limit_right_bottom_position = level.get_node_or_null("CameraPositions/BottomRight")
			if not limit_left_top_position == null and not limit_right_bottom_position == null:
				limit_left = limit_left_top_position.position.x
				limit_top = limit_left_top_position.position.y
				limit_right = limit_right_bottom_position.position.x
				limit_bottom = limit_right_bottom_position.position.y
	else:
		var level: Node2D = get_node_or_null(Globals.level_path)
		if not level == null:
			var limit_left_top_position = level.get_node_or_null("CameraPositions/SubTopLeft")
			var limit_right_bottom_position = level.get_node_or_null("CameraPositions/SubBottomRight")
			if not limit_left_top_position == null and not limit_right_bottom_position == null:
				limit_left = limit_left_top_position.position.x
				limit_top = limit_left_top_position.position.y
				limit_right = limit_right_bottom_position.position.x
				limit_bottom = limit_right_bottom_position.position.y
