extends Node2D
class_name Player

var audio_effect_filter: AudioEffectFilter = AudioEffectFilter.new()

var in_water: bool = false
var climbing_ladder: bool = false
var sprinting: bool = false
var falling: bool = false
var facing_right: bool = true

onready var kinematic_body: KinematicBody2D = $KinematicBody2D
onready var animated_sprite: AnimatedSprite = $Smoothing2D/AnimatedSprite
onready var flash_animation_player: AnimationPlayer = \
			$Smoothing2D/AnimatedSprite/FlashAnimationPlayer
onready var invincible_timer: Timer = $InvincibleTimer
onready var fsm: Node = $FSM
onready var hurt_sound: AudioStreamPlayer = $HurtSound
onready var die_sound: AudioStreamPlayer = $DieSound
onready var collision_shape: CollisionShape2D = $KinematicBody2D/CollisionShape2D
onready var area_2d: Area2D = $KinematicBody2D/Area2D

onready var dash_failed_sound: AudioStreamPlayer = $DashFailedSound


func _ready() -> void:
	Globals.death_in_progress = false
	Globals.player_invincible = false
	Signals.connect("start_player_death", self, "_start_player_death")
	Signals.connect("player_death", self, "_player_death")
	Signals.connect("player_hurt_from_enemy", self, "_player_hurt_from_enemy")
	area_2d.connect("area_entered", self, "_area_entered")
	area_2d.connect("area_exited", self, "_area_exited")
	LevelController.error_detection()


func _physics_process(delta):
	if kinematic_body.is_on_floor():
		kinematic_body.second_jump_used = false


func _start_player_death() -> void:
	if not Globals.death_in_progress:
		Globals.player_invincible = false
		hurt_sound.pitch_scale = 0.65
		hurt_sound.play()
		die_sound.play()


func _player_death() -> void:
	in_water = false
	climbing_ladder = false
	sprinting = false
	falling = false
	collision_shape.set_deferred("disabled", true)


func dash_failed() -> void:
	pass


func start_invincibility() -> void:
	yield(get_tree(), "physics_frame")
	Globals.player_invincible = true
	invincible_timer.start()
	flash_animation_player.play("flash")


func stop_invincibility() -> void:
	Signals.emit_signal("player_invincibility_stopped")
	Globals.player_invincible = false
	flash_animation_player.stop()
	animated_sprite.modulate = Color(1, 1, 1, 1)


func _player_hurt_from_enemy(hurt_type: int, knockback: int, damage: int):
	if Globals.player_invincible: return;
	if PlayerStats.get_stat("health") <= 0:
		Signals.emit_signal("start_player_death")
	else:
		start_invincibility()
		hurt_sound.pitch_scale = 0.9
		hurt_sound.play()


func _on_InvincibleTimer_timeout() -> void:
	stop_invincibility()


func _area_entered(area: Area2D) -> void:
	if area.is_in_group("water"):
		in_water = true
		AudioServer.add_bus_effect(0, audio_effect_filter)
		fsm.change_state(fsm.water_idle)


func _area_exited(area: Area2D) -> void:
	if area.is_in_group("water"):
		in_water = false
		AudioServer.remove_bus_effect(0, 1)
		fsm.change_state(fsm.idle)

