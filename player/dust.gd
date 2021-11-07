extends Node2D

onready var animated_sprite: AnimatedSprite = $AnimatedSprite


func _ready() -> void:
	animated_sprite.connect("animation_finished", self, "_animation_finished")
	animated_sprite.frame = 0
	show()
	animated_sprite.playing = true


func _animation_finished() -> void:
	call_deferred("free")
