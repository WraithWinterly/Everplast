extends Node2D


func _ready() -> void:
	randomize()
	$Sprite.texture = load(FileLocations.clouds[int(rand_range(0, 2))])
	$AnimationPlayer.play("move")
	$AnimationPlayer.playback_speed = rand_range(0.6, 1.4)
