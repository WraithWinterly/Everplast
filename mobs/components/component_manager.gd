extends Node2D
class_name MobComponentManager
# Enemy's prespective; hit_area -> player hurt area

signal hit()
signal died()
signal hit_player()

export var orb_amount: int = 10
export var knockback: int = 150
export var attack_damage: int = 1
export var max_health: int = 1

var health: int = 1

var dead := false
var damaging_self := false

onready var hurt_anim_player: AnimationPlayer = $SpriteHolder/AnimatedSprite/HurtAnimationPlayer
onready var animated_sprite: AnimatedSprite = $SpriteHolder/AnimatedSprite
onready var collision_shape: CollisionShape2D = get_parent().get_node("CollisionShape2D")

onready var health_label: Label = $Index/HealthLabel
onready var health_label_animation_player: AnimationPlayer = $Index/HealthLabel/AnimationPlayer
onready var hit_sound: AudioStreamPlayer = $HitSound
onready var death_sound: AudioStreamPlayer = $DeathSound


func _ready() -> void:
	collision_shape.set_deferred("disabled", false)
	health_label.hide()
	set_physics_process(true)
	health = max_health


func damage(damage_type: int, body = null) -> void:
	emit_signal("hit")
	match damage_type:
		Globals.HurtTypes.JUMP:
			remove_health(GlobalStats.get_player_jump_damage())
			GlobalEvents.emit_signal("player_hurt_enemy", Globals.HurtTypes.JUMP)
		Globals.HurtTypes.BULLET:
			remove_health(body.damage)
		Globals.HurtTypes.SPIKES:
			remove_health(1)

	if health_label_animation_player.is_playing():
		health_label_animation_player.stop()

	if GlobalSave.get_stat("rank") >= GlobalStats.Ranks.SILVER:
		health_label.text = "%s / %s" % [health, max_health]
		if not health_label_animation_player.is_playing():
			health_label_animation_player.play("label")

	if health <= 0:
		match damage_type:
			Globals.HurtTypes.JUMP:
				die(Globals.HurtTypes.JUMP)
			Globals.HurtTypes.BULLET:
				die(Globals.HurtTypes.BULLET)
			Globals.HurtTypes.SPIKES:
				die(Globals.HurtTypes.SPIKES)
		damaging_self = true
	else:
		hit_sound.play()
		hurt_anim_player.play("hurt")


func remove_health(number) -> void:
	health -= number
	if health < 0: health = 0


func die(hurt_type: int) -> void:
	if damaging_self: return
	emit_signal("died")
	dead = true
	death_sound.play()
	set_physics_process(false)
	hurt_anim_player.stop()
	hurt_anim_player.play("death")
	collision_shape.set_deferred("disabled", true)

	if orb_amount > 0:
		var orb_loader: PackedScene = load(GlobalPaths.ORB)
		var orb_instance: KinematicBody2D = orb_loader.instance()
		var level: Node2D = get_node(GlobalPaths.LEVEL)
		var player_body: KinematicBody2D = get_node(GlobalPaths.PLAYER)

		orb_instance.value = orb_amount
		if hurt_type == Globals.HurtTypes.JUMP:
			orb_instance.global_position = Vector2(player_body.global_position.x + 2, player_body.global_position.y + 10)
		else:
			orb_instance.global_position = Vector2(global_position.x + 2, global_position.y- 10)
		level.call_deferred("add_child", orb_instance)

	yield(hurt_anim_player, "animation_finished")
	call_deferred("free")
