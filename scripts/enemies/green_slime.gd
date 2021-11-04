extends KinematicBody2D

var knockback: int = 150
var damage: int = 1
var orb_amount: int = 10
var max_health: int = 1
var check_for_player: bool = false
var hurt_player: bool = false
var dead: bool = false

onready var death_animation_player: AnimationPlayer = $SpriteHolder/AnimatedSprite/DeathAnimationPlayer
onready var animated_sprite: AnimatedSprite = $SpriteHolder/AnimatedSprite
onready var collision_shape: CollisionShape2D = $CollisionShape2D
onready var hit_area: Area2D = $HitArea
onready var hurt_area: Area2D = $HurtArea
onready var hurt_area_jump :Area2D = $HurtAreaJump
onready var health_label: Label = $HealthLabel
onready var health_label_animation_player: AnimationPlayer = $HealthLabel/AnimationPlayer
onready var hit_sound: AudioStreamPlayer = $HitSound


func _ready() -> void:
	set_physics_process(true)
	collision_shape.set_deferred("disabled", false)
	health_label.hide()
	Signals.connect("player_invincibility_stopped", self, "_player_invincibility_stopped")
	# Enemy's prespective; hit_area -> player hurt area
	collision_shape.set_deferred("disabled", false)
	hit_area.set_deferred("monitoring", true)
	hurt_area.set_deferred("monitoring", true)
	hurt_area_jump.set_deferred("monitoring", true)

	health_label.hide()


func damage_self(damage_type: int, body = null) -> void:
	if damage_type == Globals.HurtTypes.JUMP:
		# health -= Globals.player_jump_damage
		hit_sound.play()
		if animated_sprite.scale.x == 1:
			death_animation_player.play("death")
		else:
			death_animation_player.play("death_invert")
		if health_label_animation_player.is_playing():
			health_label_animation_player.stop()
		if PlayerStats.get_stat("rank") >= PlayerStats.Ranks.GOLD:
			var health_label_amount = max_health
			health_label.text = "%s / %s" % [health_label_amount, max_health]
			health_label_animation_player.play("label")
		Signals.emit_signal("player_hurt_enemy", Globals.HurtTypes.JUMP)
		die(Globals.HurtTypes.JUMP)
	elif damage_type == Globals.HurtTypes.BULLET:
		hit_sound.play()
		if animated_sprite.scale.x == 1:
			death_animation_player.play("death")
		else:
			death_animation_player.play("death_invert")
		if health_label_animation_player.is_playing():
			health_label_animation_player.stop()
		if PlayerStats.get_stat("rank") >= PlayerStats.Ranks.GOLD:
			var health_label_amount = max_health
			health_label.text = "%s / %s" % [health_label_amount, max_health]
			health_label_animation_player.play("label")
		die(Globals.HurtTypes.BULLET)


func die(hurt_type: int) -> void:
	dead = true
	death_animation_player.stop()

	if animated_sprite.scale.x == 1:
		death_animation_player.play("death")
	else:
		death_animation_player.play("death_invert")

	hit_area.set_deferred("monitoring", false)
	collision_shape.set_deferred("disabled", true)
	set_physics_process(false)

	var health_label_amount = max_health# - health
	health_label.text = "%s / %s" % [health_label_amount, max_health]

	var orb_loader: PackedScene = load(FileLocations.orb)
	var orb_instance: KinematicBody2D = orb_loader.instance()
	var level: Node2D = get_node(Globals.level_path)
	var player_body: KinematicBody2D = get_node(Globals.player_body_path)

	orb_instance.value = orb_amount
	if hurt_type == Globals.HurtTypes.JUMP:
		orb_instance.global_position = Vector2(player_body.global_position.x + 2, player_body.global_position.y + 10)
	else:
		orb_instance.global_position = Vector2(global_position.x + 2, global_position.y- 10)
	level.call_deferred("add_child", orb_instance)
	yield(death_animation_player, "animation_finished")
	call_deferred("free")


func _player_invincibility_stopped() -> void:
	yield(get_tree(), "physics_frame")
	yield(get_tree(), "physics_frame")
	check_for_player = false
