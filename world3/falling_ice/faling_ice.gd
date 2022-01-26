extends KinematicBody2D

export var instant_fall := false

var rng := RandomNumberGenerator.new()

var prev_pos: Vector2
var linear_velocity := Vector2(0, 0)

var gravity := 9.8

var damage := 10
var kb := 200

var falling := false
var no_damage := false


onready var area_2d: Area2D = $Detection
onready var sprite: Sprite = $Sprite
onready var anim_sprite: AnimatedSprite = $AnimatedSprite
onready var anim_player: AnimationPlayer = $Sprite/AnimationPlayer
onready var ice_break_sound: AudioStreamPlayer2D = $IceBreak
onready var ice_rumble_sound: AudioStreamPlayer2D = $IceRumble
onready var timer: Timer = $Timer
onready var visi_noti: VisibilityNotifier2D = $VisibilityNotifier2D


func _ready() -> void:
	randomize()
	sprite.frame = rng.randi_range(0, 3)
	anim_sprite.animation = "default"
	anim_sprite.hide()

	if instant_fall:
		sprite.frame = rng.randi_range(4, 7)
		anim_sprite.animation = "instant"
		gravity *= 2

	prev_pos = global_position


func _physics_process(_delta: float) -> void:
	if not Globals.game_state == Globals.GameStates.LEVEL: return

	if falling:
		linear_velocity.y += gravity
	else:
		linear_velocity.y = 0

	if is_on_floor() or not visi_noti.is_on_screen():
		if not no_damage and falling:
			break_ice()

	linear_velocity.x = 0
	linear_velocity = move_and_slide(linear_velocity, Vector2.UP)


func fall():
	if not falling and not no_damage:
		falling = true


func break_ice():
	anim_player.playback_speed = 1
	randomize()
	ice_break_sound.pitch_scale = rand_range(1.15, 1.35)
	ice_break_sound.play()
	no_damage = true
	timer.start(3.5)
	anim_sprite.show()
	anim_sprite.playing = true
	sprite.hide()


func regen():
	global_position = prev_pos
	anim_player.play("regen")
	sprite.show()


func rumble() -> void:
	if instant_fall:
		anim_player.playback_speed = 999
	GlobalInput.start_low_vibration()
	anim_player.play("rumble")
	randomize()
	ice_rumble_sound.pitch_scale = rand_range(0.95, 1.05)
	ice_rumble_sound.play()


func _on_Detection_body_entered(body: Node) -> void:
	if not Globals.game_state == Globals.GameStates.LEVEL: return
	if body.is_in_group("Player") and not no_damage:
		rumble()


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "rumble":
		fall()
	elif anim_name == "regen":
		no_damage = false


func _on_Timer_timeout() -> void:
	regen()


func _on_HitArea_body_entered(body: Node) -> void:
	if not Globals.game_state == Globals.GameStates.LEVEL: return

	if not no_damage:
		if body.is_in_group("Player"):
			GlobalEvents.emit_signal("player_hurt_from_enemy", Globals.HurtTypes.TOUCH, kb, damage)
			break_ice()
		elif body.is_in_group("Mob") or body.is_in_group("Bullet"):
			if not falling:
				fall()
			break_ice()


func _on_AnimatedSprite_animation_finished() -> void:
	anim_sprite.playing = false
	anim_sprite.hide()
	falling = false
