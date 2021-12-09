extends Node

signal state_changed()
signal landed()

var enabled: bool = true

onready var player: KinematicBody2D = get_parent()
onready var idle: Node = $Idle
onready var walk: Node = $Walk
onready var sprint: Node = $Sprint
onready var jump: Node = $Jump
onready var fall: Node = $Fall
onready var dash: Node = $Dash
onready var wall_slide: Node = $WallSlide
onready var wall_jump: Node = $WallJump
onready var water_idle: Node = $WaterIdle
onready var water_move: Node = $WaterMove
onready var last_state: Node = $Idle
onready var current_state: Node = $Idle


func _ready() -> void:
	var __: int
	__ = GlobalEvents.connect("level_complete_started", self, "_level_complete_started")

	for child in get_children():
		child.set_process(false)
		child.set_process_input(false)
		child.set_physics_process(false)

	yield(GlobalEvents, "ui_faded")

	idle.set_process(true)
	idle.set_process_input(true)
	idle.set_physics_process(true)


func change_state(new_state: Node, bypass: bool = false):
	if not enabled: return

	if Globals.death_in_progress and not bypass: return

	last_state = current_state
	current_state.set_process(false)
	current_state.set_process_input(false)
	current_state.set_physics_process(false)

	if current_state.has_method("stop"):
		current_state.call("stop")
	current_state = new_state
	emit_signal("state_changed")

	if current_state.has_method("start"):
		current_state.call("start")

	current_state.set_process(true)
	current_state.set_process_input(true)
	current_state.set_physics_process(true)


func _level_complete_started() -> void:
	 change_state(idle)
