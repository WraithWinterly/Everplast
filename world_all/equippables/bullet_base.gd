extends RigidBody2D

var grace: bool = false
var ignore: bool = false
var player_bullet: bool = false

var grace_period: int = 0

var damage: int
var speed: int

onready var sound: AudioStreamPlayer = $Sound
onready var collision_shape: CollisionShape2D = $CollisionShape2D
onready var anim_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	sound.play()

	match GlobalSave.get_stat("equipped_item"):
		"nail gun":
			damage = 10
			speed = 300
		"laser gun":
			damage = 5
			speed = 700
		"water gun":
			damage = 1
			speed = 500


func _process(_delta: float) -> void:
	angular_velocity = 0


func _physics_process(_delta: float) -> void:
	if ignore: return
	if grace: return

	var bodies := get_colliding_bodies()

	if bodies.size() > 0:
		yield(get_tree(), "physics_frame")
		ignore = true
		collision_shape.set_deferred("disabled", true)
		set_deferred("mode", MODE_KINEMATIC)
		angular_velocity = 0
		linear_velocity = Vector2(0, 0)
		applied_torque = 0
		anim_player.play("hide")
		yield(anim_player, "animation_finished")
		call_deferred("free")


func _screen_exited() -> void:
	call_deferred("free")
