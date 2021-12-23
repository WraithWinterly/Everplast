extends Area2D

export var coin_amount: int = 1

var rng := RandomNumberGenerator.new()

onready var coin_sound: AudioStreamPlayer2D = $CoinSound
onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	var __: int = connect("body_entered", self, "_body_entered")


func _body_entered(body: Node) -> void:
	if not body.is_in_group("Player"): return

	GlobalInput.start_low_vibration()
	GlobalEvents.emit_signal("player_collected_coin", coin_amount)
	coin_sound.play()
	animation_player.play("collect")
	collision_shape_2d.set_deferred("disabled", true)
	rng.seed = 349093452345908
	rng.randomize()

	match coin_amount:
		10:
			coin_sound.pitch_scale = rng.randf_range(0.5, 0.6)
			coin_sound.volume_db = -7
		100:
			coin_sound.pitch_scale = rng.randf_range(0.4, 0.5)
			coin_sound.volume_db = -2
		_:
			coin_sound.pitch_scale = rng.randf_range(0.7, 0.8)
			coin_sound.volume_db = -15

	yield(animation_player, "animation_finished")
	call_deferred("free")
