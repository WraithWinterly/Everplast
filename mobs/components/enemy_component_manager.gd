extends Node2D
class_name EnemyComponentManager
# Enemy's prespective; hit_area -> player hurt area

signal hit()
signal died()

export var orb_amount: int = 10
export var knockback: int = 150
export var damage: int = 1
export var max_health: int = 1

var health: int = 1
var dead: bool = false
var hurt_player: bool = false


onready var death_animation_player: AnimationPlayer = $SpriteHolder/AnimatedSprite/HurtAnimationPlayer
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


func damage_self(damage_type: int, body = null) -> void:
	emit_signal("hit")

	match damage_type:
		Globals.HurtTypes.JUMP:
			remove_health(Globals.player_jump_damage)
			Signals.emit_signal("player_hurt_enemy", Globals.HurtTypes.JUMP)
		Globals.HurtTypes.BULLET:
			remove_health(body.damage)

	if health_label_animation_player.is_playing():
		health_label_animation_player.stop()
	if PlayerStats.get_stat("rank") >= PlayerStats.Ranks.GOLD:
		health_label.text = "%s / %s" % [health, max_health]
		health_label_animation_player.play("label")

	if health <= 0:
		match damage_type:
			Globals.HurtTypes.JUMP:
				die(Globals.HurtTypes.JUMP)
				return
			Globals.HurtTypes.BULLET:
				die(Globals.HurtTypes.BULLET)
				return

	hit_sound.play()
	if animated_sprite.scale.x == 1:
		death_animation_player.play("hurt")




func remove_health(number) -> void:
	health -= number
	if health < 0: health = 0


func die(hurt_type: int) -> void:
	dead = true
	death_sound.play()
	emit_signal("died")
	set_physics_process(false)
	death_animation_player.stop()
	death_animation_player.play("death")
	collision_shape.set_deferred("disabled", true)

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
