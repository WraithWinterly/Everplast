extends Node2D


func spawn() -> void:
	$AnimatedSprite/SpawnSound.play()
	$AnimatedSprite.animation = "idle"
	$AnimatedSprite/AnimationPlayer.play("spawn")
