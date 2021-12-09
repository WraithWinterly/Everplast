extends Sprite

export var always_palm := false


func _ready() -> void:
	update_trees()


func update_trees() -> void:
	var rng := RandomNumberGenerator.new()

	rng.seed = 30204
	rng.randomize()
	if GlobalLevel.current_world == 2 or always_palm:
		rng.randomize()
		frame = rng.randi_range(3, 5)
	else:
		rng.randomize()
		frame = rng.randi_range(0, 2)
