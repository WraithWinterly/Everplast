extends KinematicBody2D

export var value: int = 10

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var linear_velocity: Vector2 = Vector2(0, 0)
var collecting: bool = false

onready var orb_sound: AudioStreamPlayer2D = $OrbSound
onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
onready var area: Area2D = $Area2D
onready var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")


func _ready() -> void:
	area.connect("body_entered", self, "_body_entered")


func _physics_process(delta: float) -> void:
	linear_velocity.y += gravity * delta
	linear_velocity = move_and_slide(linear_velocity, Vector2.UP)


func _body_entered(body: Node) -> void:
	if collecting: return
	if not body.is_in_group("Player"): return
	collecting = true
	Signals.emit_signal("orb_collected", value)
	orb_sound.play()
	animation_player.play("collect")
	collision_shape_2d.set_deferred("disabled", true)
	set_physics_process(false)
	rng.seed = 349093452345908
	rng.randomize()
	orb_sound.pitch_scale = rng.randf_range(0.7, 0.8)
	yield(animation_player, "animation_finished")
	call_deferred("free")
