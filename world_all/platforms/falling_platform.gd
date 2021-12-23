extends Node2D

var activated := false

onready var area_2d: Area2D = $KinematicBody2D/Area2D
onready var anim_player: AnimationPlayer = $AnimationPlayer
onready var coll_shape: CollisionShape2D = $KinematicBody2D/CollisionShape2D
onready var sound: AudioStreamPlayer = $AudioStreamPlayer


func _ready() -> void:
	var __: int
	__ = area_2d.connect("body_entered", self, "_body_entered")


func _body_entered(body: Node) -> void:
	if body.is_in_group("Player") and not activated:
		activated = true
		anim_player.play("move")
		sound.play()
		GlobalInput.start_normal_vibration()

		yield(anim_player, "animation_finished")
		yield(get_tree().create_timer(3), "timeout")
		anim_player.play("regen")
		yield(anim_player, "animation_finished")
		activated = false
