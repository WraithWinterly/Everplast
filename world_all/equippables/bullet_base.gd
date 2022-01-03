extends RigidBody2D

var equippable_owner: String

var grace_period: int = 0
var damage: int
var speed: int

var grace := false
var ignore := false
var player_bullet := false

onready var sound: AudioStreamPlayer = $Sound
onready var collision_shape: CollisionShape2D = $CollisionShape2D
onready var anim_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	damage = GlobalStats.get_equippable_damage(equippable_owner)
	speed = GlobalStats.get_equippable_speed(equippable_owner)
	randomize()
	sound.pitch_scale += rand_range(-0.1, 0.1)
	sound.play()


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
