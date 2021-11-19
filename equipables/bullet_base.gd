extends RigidBody2D

var damage: int = 0
var speed: int = 0
var grace_period: int = 3

var grace: bool = true
var ignore: bool = false

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
	while grace_period > 0:
		grace_period -= 1
		yield(get_tree(), "physics_frame")
		if grace_period <= 0:
			grace = false


func _physics_process(_delta: float) -> void:
	if ignore: return
	if grace: return
	var bodies := get_colliding_bodies()
	if bodies.size() > 0:
		ignore = true
		yield(get_tree(), "physics_frame")
		collision_shape.set_deferred("disabled", true)
		set_deferred("mode", MODE_KINEMATIC)
		anim_player.play("collected")
		yield(anim_player, "animation_finished")
		call_deferred("free")

#func _body_entered(_body: Node) -> void:
#	if grace: return
#	yield(get_tree(), "physics_frame")
#	collision_shape.set_deferred("disabled", true)
#	set_deferred("mode", MODE_KINEMATIC)
#	anim_player.play("collected")
#	yield(anim_player, "animation_finished")
#	call_deferred("free")


func _screen_exited() -> void:
	call_deferred("free")
