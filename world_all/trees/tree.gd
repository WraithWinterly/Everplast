extends Sprite

export var always_palm := false
export var always_green := false
export var always_snow := false

onready var rng := RandomNumberGenerator.new()

var is_palm := false


func _ready() -> void:
	update_trees()


func update_trees() -> void:
	if Globals.game_state == Globals.GameStates.WORLD_SELECTOR:
		if always_palm:
			is_palm = true
			frame = rng.randi_range(3, 5)
		return

	rng.seed = 69420
	rng.seed += int(name)

	if always_green:
		if always_palm:
			frame = rng.randi_range(3, 4)
			is_palm = true
		else:
			frame = rng.randi_range(0, 2)
	if GlobalLevel.current_world == 2 or always_palm:
		frame = rng.randi_range(3, 5)
		is_palm = true
	if GlobalLevel.current_world == 3 or always_snow:
		frame = rng.randi_range(6, 9)
		$CPUParticles2D.queue_free()
		$CPUParticles2D2.queue_free()
		$CPUParticles2D3.queue_free()
	else:
		frame = rng.randi_range(0, 2)

	if get_node(GlobalPaths.LEVEL).windy_level and (is_palm or is_snow_palm()):
		material = load("res://world_all/trees/wind.tres")

func is_snow_palm() -> bool:
	return frame == 7 or frame == 8
