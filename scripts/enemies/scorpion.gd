extends KinematicBody2D

var knockback: int = 150
var damage: int = 2
var coin_amount: int = 1
var max_health: int = 2
var check_for_player: bool = false
var hurt_player: bool = false
var dead: bool = false
var health: int = 2

onready var death_animation_player: AnimationPlayer = $SpriteHolder/AnimatedSprite/DeathAnimationPlayer
onready var animated_sprite: AnimatedSprite = $SpriteHolder/AnimatedSprite
onready var collision_shape: CollisionShape2D = $CollisionShape2D
onready var hit_area: Area2D = $HitArea
onready var health_label: Label = $HealthLabel
onready var health_label_animation_player: AnimationPlayer = $HealthLabel/AnimationPlayer
onready var hit_sound: AudioStreamPlayer = $HitSound
onready var hurt_area: Area2D = $HurtArea
onready var particles: Particles2D = $Particles2D


func _ready() -> void:
	health = max_health
	hurt_area.set_deferred("monitoring", true)
	set_physics_process(true)
	hit_area.set_deferred("monitoring", true)
	collision_shape.set_deferred("disabled", false)
	health_label.hide()
	Signals.connect("player_invincibility_stopped", self, "_player_invincibility_stopped")
	# Enemy's prespective; hit_area -> player hurt area
	collision_shape.set_deferred("disabled", false)
	hit_area.set_deferred("monitoring", true)
	health_label.hide()


func damage_self(damage_type: int, bullet) -> void:
	if damage_type == Globals.HurtTypes.BULLET:
		particles.emitting = true
		health -= bullet.damage
		health = clamp(health, 0, INF)
		if animated_sprite.scale.x == 1:
			death_animation_player.play("hurt")
			hit_sound.play()
			if health_label_animation_player.is_playing():
				health_label_animation_player.stop()
			if PlayerStats.get_stat("rank") >= PlayerStats.Ranks.GOLD:
				var health_label_amount = max_health - health
				health_label.text = "%s / %s" % [health_label_amount, max_health]
				health_label_animation_player.play("label")
		if health <= 0:
			die(Globals.HurtTypes.BULLET)


func die(hurt_type: int) -> void:
	particles.emitting = true
	dead = true
	death_animation_player.stop()

	death_animation_player.play("death")

	hit_area.set_deferred("monitoring", false)
	collision_shape.set_deferred("disabled", true)
	set_physics_process(false)

	var health_label_amount = max_health - health
	health_label.text = "%s / %s" % [health_label_amount, max_health]

	var coin_loader: PackedScene = load(FileLocations.coin)
	var coin_instance: Area2D = coin_loader.instance()
	var level: Node2D = get_node(Globals.level_path)
	var player_body: KinematicBody2D = get_node(Globals.player_body_path)

	coin_instance.global_position = Vector2(player_body.global_position.x + 2, player_body.global_position.y + 10)
	level.call_deferred("add_child", coin_instance)
	yield(death_animation_player, "animation_finished")
	call_deferred("free")


func _player_invincibility_stopped() -> void:
	yield(get_tree(), "physics_frame")
	yield(get_tree(), "physics_frame")
	check_for_player = false
