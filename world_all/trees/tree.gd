extends Sprite

export var always_palm := false
export var always_green := false

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
	elif GlobalLevel.current_world == 2 or always_palm:
		frame = rng.randi_range(3, 5)
		is_palm = true
	elif GlobalLevel.current_world == 3:
		frame = rng.randi_range(6, 9)
		$CPUParticles2D.queue_free()
		$CPUParticles2D2.queue_free()
		$CPUParticles2D3.queue_free()
	else:
		frame = rng.randi_range(0, 2)

	if get_node(GlobalPaths.LEVEL).windy_level and is_palm:
		material = load("res://world_all/trees/wind.tres")
