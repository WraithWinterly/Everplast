extends Sprite


func _ready() -> void:
	update_trees()


func update_trees() -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 30204
	rng.randomize()
	if LevelController.current_world == 2:
			rng.randomize()
			frame = rng.randi_range(3, 5)
	else:
			rng.randomize()
			frame = rng.randi_range(0, 2)
