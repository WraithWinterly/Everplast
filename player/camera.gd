extends Camera2D

enum {
	NORMAL,
	SUB
}

const MAX_OFFSET := Vector2(100, 75)
const NORMAL_ZOOM := Vector2(0.2, 0.2)
const SPRINT_ZOOM := Vector2(0.21, 0.21)

const DECAY: float = 0.8
const MAX_ROLL: float = 0.1
const DRAG_TOP : float = 0.53
const DRAG_BOTTOM: float = 0.2

var current_zoom := NORMAL_ZOOM

var default_drag_top: float = drag_margin_top
var default_drag_bottom: float = drag_margin_bottom


var trauma: float = 0.0
var trauma_power: float = 2.5

var state: int = NORMAL
var noise_y: int = 0

onready var noise := OpenSimplexNoise.new()
onready var player: KinematicBody2D = $"../../KinematicBody2D"
onready var fsm: Node = $"../../KinematicBody2D/FSM"


func _ready() -> void:
	var __: int
	__ = GlobalEvents.connect("level_subsection_changed", self, "_level_subsection_changed")
	__ = GlobalEvents.connect("story_w3_fernand_anim_finished", self, "_story_w3_fernand_anim_finished")
	__ = fsm.connect("state_changed", self, "_state_changed")

	randomize()

	noise.seed = randi()
	noise.period = 4
	noise.octaves = 2

	yield(get_tree(), "idle_frame")

	update_camera_positions(NORMAL)

	if GlobalLevel.checkpoint_in_sub:
		update_camera_positions(SUB)
		state = SUB


func _process(delta) -> void:
	if trauma:
		trauma = max(trauma - DECAY * delta, 0)
		shake()


func _physics_process(_delta: float) -> void:
	#return
	zoom = lerp(zoom, current_zoom, 0.1484375)

	if player.sprinting:
		current_zoom = SPRINT_ZOOM
	else:
		current_zoom = NORMAL_ZOOM


func add_trauma(amount) -> void:
	trauma = min(trauma + amount, 1.0)


func set_trauma(amount) -> void:
	trauma = min(amount, 1.0)


func shake() -> void:
	var amount = pow(trauma, trauma_power)

	noise_y += 1
	rotation = MAX_ROLL * amount * noise.get_noise_2d(noise.seed, noise_y)
	offset.x = MAX_OFFSET.x * amount * noise.get_noise_2d(noise.seed*2, noise_y)
	offset.y = MAX_OFFSET.y * amount * noise.get_noise_2d(noise.seed*3, noise_y)


func update_camera_positions(mode: int) -> void:
	if mode == NORMAL:
		var level: Node2D = get_node_or_null(GlobalPaths.LEVEL)

		if not level == null:
			var limit_left_top_position = level.get_node_or_null("LevelComponents/CameraPositions/TopLeft")
			var limit_right_bottom_position = level.get_node_or_null("LevelComponents/CameraPositions/BottomRight")
			if not limit_left_top_position == null and not limit_right_bottom_position == null:
				limit_left = limit_left_top_position.position.x
				limit_top = limit_left_top_position.position.y
				limit_right = limit_right_bottom_position.position.x
				limit_bottom = limit_right_bottom_position.position.y
	else:
		var level: Node2D = get_node_or_null(GlobalPaths.LEVEL)

		if not level == null:
			var limit_left_top_position = level.get_node_or_null("LevelComponents/CameraPositions/SubTopLeft")
			var limit_right_bottom_position = level.get_node_or_null("LevelComponents/CameraPositions/SubBottomRight")
			if not limit_left_top_position == null and not limit_right_bottom_position == null:
				limit_left = limit_left_top_position.position.x
				limit_top = limit_left_top_position.position.y
				limit_right = limit_right_bottom_position.position.x
				limit_bottom = limit_right_bottom_position.position.y

	drag_margin_top = 0
	drag_margin_bottom = 0

	yield(get_tree(), "physics_frame")
	yield(get_tree(), "physics_frame")

	drag_margin_top = DRAG_TOP
	drag_margin_bottom = DRAG_BOTTOM


func _level_subsection_changed(_pos: Vector2) -> void:
	yield(GlobalEvents, "ui_faded")

	if state == NORMAL:
		state = SUB
		update_camera_positions(state)
	else:
		state = NORMAL
		update_camera_positions(state)


func _state_changed() -> void:
	if fsm.current_state == fsm.dash:
		set_trauma(0.4)

func _story_w3_fernand_anim_finished() -> void:
	yield(GlobalEvents, "ui_faded")
	current = true
