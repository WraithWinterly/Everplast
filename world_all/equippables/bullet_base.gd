extends RigidBody2D

var grace: bool = false
var ignore: bool = false
var player_bullet: bool = false

var grace_period: int = 0

onready var sound: AudioStreamPlayer = $Sound
onready var collision_shape: CollisionShape2D = $CollisionShape2D
onready var anim_player: AnimationPlayer = $AnimationPlayer
onready var destroy_area: Area2D = $DestroyArea
onready var area_2d: Area2D = $Area2D


func _ready() -> void:
	sound.play()

	match GlobalSave.get_stat("equipped_item"):
		"nail gun":
			area_2d.damage = 10
			area_2d.speed = 300
		"laser gun":
			area_2d.damage = 5
			area_2d.speed = 700
		"water gun":
			area_2d.damage = 1
			area_2d.speed = 500

func _process(_delta: float) -> void:
	angular_velocity = 0


func _physics_process(_delta: float) -> void:
	if ignore: return
	if grace: return

	var bodies := destroy_area.get_overlapping_bodies()

	if bodies.size() > 0:
		ignore = true
		collision_shape.set_deferred("disabled", true)
		#set_deferred("mode", MODE_KINEMATIC)
		#angular_velocity = 0
		linear_velocity = Vector2(0, 0)
		applied_torque = 0
		anim_player.play("hide")
		yield(anim_player, "animation_finished")
		call_deferred("free")


func _screen_exited() -> void:
	call_deferred("free")
