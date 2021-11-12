extends RigidBody2D

var damage: int = 0
var speed: int = 0

onready var sound: AudioStreamPlayer = $Sound
onready var collision_shape: CollisionShape2D = $CollisionShape2D
onready var anim_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	sound.play()
	match PlayerStats.get_stat("equipped_item"):
		"nail gun":
			damage = 5
			speed = 300
		"laser gun":
			damage = 10
			speed = 700
		"water gun":
			damage = 1
			speed = 500


func _body_entered(_body: Node) -> void:
	yield(get_tree(), "physics_frame")
	collision_shape.set_deferred("disabled", true)
	set_deferred("mode", MODE_KINEMATIC)
	anim_player.play("collected")
	yield(anim_player, "animation_finished")
	call_deferred("free")


func _screen_exited() -> void:
	call_deferred("free")
