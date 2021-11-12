extends Node2D

onready var area_2d: Area2D = $KinematicBody2D/Area2D
onready var anim_player: AnimationPlayer = $AnimationPlayer
onready var coll_shape: CollisionShape2D = $KinematicBody2D/CollisionShape2D
onready var sound: AudioStreamPlayer = $AudioStreamPlayer


func _ready() -> void:
	var __: int
	__ = area_2d.connect("body_entered", self, "_body_entered")


func _body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		anim_player.play("move")
		sound.play()
		yield(get_tree().create_timer(1), "timeout")
		coll_shape.set_deferred("disabled", true)
		yield(anim_player, "animation_finished")
		queue_free()
