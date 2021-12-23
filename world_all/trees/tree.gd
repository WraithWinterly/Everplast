extends Sprite

export var always_palm := false

onready var rng := RandomNumberGenerator.new()


func _ready() -> void:
	update_trees()


func update_trees() -> void:
	if Globals.game_state == Globals.GameStates.WORLD_SELECTOR:
		if always_palm:
			rng.randomize()
			frame = rng.randi_range(3, 5)
		return

	rng.seed = 30204
	rng.randomize()

	if GlobalLevel.current_world == 2 or always_palm:
		rng.randomize()
		frame = rng.randi_range(3, 5)
	else:
		rng.randomize()
		frame = rng.randi_range(0, 2)
