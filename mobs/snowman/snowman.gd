extends Node2D

const DELAY := 1
const THROW_SPEED: int = 350
var throw_allowed := true
var facing_right := true

onready var enemy_base: MobComponentManager = $MobComponentManager
onready var area_2d: Area2D = $MobComponentManager/HurtArea
onready var timer: Timer = $Timer
onready var pos_2d: Position2D = $Position2D
onready var flip_anim_player: AnimationPlayer = $MobComponentManager/SpriteHolder/AnimatedSprite/FlipAnimationPlayer


func _ready() -> void:
	timer.start(DELAY)


func _physics_process(_delta: float) -> void:
	if enemy_base.damaging_self: return

	for body in area_2d.get_overlapping_bodies():
		if body.is_in_group("Player"):
			throw_snowball()

	var player_pos: Vector2 = get_node(GlobalPaths.PLAYER).global_position

	if not player_pos.y + 20 <= global_position.y:
		if int(player_pos.x) > int(global_position.x):
			if not facing_right:
				flip(false)
		elif int(player_pos.x) < int(global_position.x):
			if facing_right:
				flip(true)


func throw_snowball() -> void:
	if not throw_allowed: return

	var player_pos: Vector2 = get_node(GlobalPaths.PLAYER).global_position

	pos_2d.look_at(player_pos)
	randomize()
	pos_2d.rotation_degrees += rand_range(-10, 10)

	var snowball: RigidBody2D = load(GlobalPaths.SNOWBALL).instance()

	get_node(GlobalPaths.LEVEL).add_child(snowball)
	snowball.global_position = pos_2d.global_position

	snowball.apply_impulse(Vector2(), Vector2(THROW_SPEED, 0).rotated(pos_2d.global_rotation))
	throw_allowed = false


func flip(flip_left: bool) -> void:
	if flip_left:
		facing_right = false
		flip_anim_player.play("flip")
	else:
		facing_right = true
		flip_anim_player.play_backwards("flip")


func _on_Timer_timeout() -> void:
	throw_allowed = true
	timer.start(DELAY)
