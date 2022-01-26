extends StaticBody2D

enum BulletTypes {
	SNOWBALL,
}

export var bullet_type: int = BulletTypes.SNOWBALL

var speed: int = 150
var rng := RandomNumberGenerator.new()
var enabled := true

onready var pos_2d: Position2D = $Base/Top/Sprite/Position2D
onready var anim_player: AnimationPlayer = $Base/Top/AnimationPlayer
onready var timer: Timer = $Timer
onready var explosion_sound: AudioStreamPlayer2D = $Explosion


func _ready() -> void:
	if Globals.game_state == Globals.GameStates.LEVEL:
		rng.seed = 123
		rng.seed += int(name)
		timer.start(rand_range(0, 1))


# Called by animation player
func shoot() -> void:
	if not enabled: return
	match bullet_type:
		BulletTypes.SNOWBALL:
			var pitch_change: float = rand_range(-0.15, 0.15)
			if not is_equal_approx(pitch_change, 0):
				explosion_sound.pitch_scale += pitch_change

			explosion_sound.play()
			var bullet_inst: Node2D = load("res://world_all/cannon/snowball_cannon_bullet.tscn").instance()
			get_node(GlobalPaths.LEVEL).add_child(bullet_inst)
			var bullet: RigidBody2D = bullet_inst.get_node("CannonBulletBase")
			bullet.global_position = pos_2d.global_position
			bullet.global_rotation = pos_2d.global_rotation
			bullet.apply_impulse(Vector2(), Vector2(speed, 0).rotated(pos_2d.global_rotation))


func _on_Timer_timeout() -> void:
	rng.seed -= int(name)
	rng.seed -= int(name)
	var type: int = rng.randi_range(1, 3)
	anim_player.play("type_%s" % type)


func disable() -> void:
	enabled = false

func enable() -> void:
	enabled = true
