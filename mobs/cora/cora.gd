extends KinematicBody2D

enum States {
	BEGIN,
	AFTER,
}

export var snowman_1_path: NodePath
export var snowman_2_path: NodePath

const NAME: String = "Cora"

const THROW_SPEED: int = 500

var linear_velocity := Vector2()

var facing_right: bool = true
var active: bool = false

var current_speed: int = 0
var state: int = States.BEGIN
var throw_allowed := true

onready var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity") / 30

onready var snowman_1 = get_node(snowman_1_path)
onready var snowman_2 = get_node(snowman_2_path)

onready var mob_component: Node2D = $EnemyComponentManager
onready var timer: Timer= $Timer
onready var flip_anim_player: AnimationPlayer= $FlipAnimationPlayer

onready var vis_noti: VisibilityNotifier2D = $VisibilityNotifier2D

onready var ray_right: RayCast2D= $RayCastRight
onready var ray_left: RayCast2D = $RayCastLeft
onready var ray_right_top: RayCast2D= $RayCastRightTop
onready var ray_left_top: RayCast2D = $RayCastLeftTop
onready var pos_2d: Position2D = $Sprite/Position2D


func _ready() -> void:
	var __: int
	__ = GlobalEvents.connect("story_boss_activated", self, "_story_boss_activated")
	__ = mob_component.connect("died", self, "_died")
	__ = mob_component.connect("hit", self, "_hit")

	yield(get_tree(), "idle_frame")
	snowman_1.get_node("MobComponentManager").max_health = 20
	snowman_1.get_node("MobComponentManager").health = 20
	snowman_2.get_node("MobComponentManager").max_health = 20
	snowman_2.get_node("MobComponentManager").health = 20

	$EnemyComponentManager/HurtArea.monitoring = false

func _physics_process(_delta: float) -> void:
	if not active: return

	if snowman_1.get_node("MobComponentManager").dead and snowman_2.get_node("MobComponentManager").dead and state == States.BEGIN:
		state = States.AFTER
		start_boss()

	if state == States.BEGIN:
		pass

	if state == States.AFTER:
		run_cora()
#	match state:
#		States.CHASE:
#			chase_ai()
#		States.JUMP:
#			jump_ai()
#
#	if not state == States.JUMP:
#		if facing_right and ray_right.is_colliding():
#			if ray_right_top.is_colliding():
#				flip()
#			else:
#				linear_velocity.y -= JUMP_SPEED
#				state = States.JUMP
#		elif not facing_right and ray_left.is_colliding():
#			if ray_left_top.is_colliding():
#				flip()
#			else:
#				linear_velocity.y -= JUMP_SPEED
#				state = States.JUMP

	linear_velocity.y += gravity
	linear_velocity.x = lerp(linear_velocity.x, current_speed, 0.1)
	linear_velocity = move_and_slide(linear_velocity, Vector2.UP)


func run_cora() -> void:
	if not throw_allowed: return

	var player_pos: Vector2 = get_node(GlobalPaths.PLAYER).global_position

	pos_2d.look_at(player_pos)
	randomize()
	pos_2d.rotation_degrees += rand_range(-40, 40)

	var snowball: RigidBody2D = load(GlobalPaths.SNOWBALL_SNOWMAN).instance()

	get_node(GlobalPaths.LEVEL).add_child(snowball)
	snowball.global_position = pos_2d.global_position

	snowball.apply_impulse(Vector2(), Vector2(THROW_SPEED, 0).rotated(pos_2d.global_rotation))
	throw_allowed = false

	if not player_pos.y + 20 <= global_position.y:
		if int(player_pos.x) > int(global_position.x):
			if not facing_right:
				flip()
		elif int(player_pos.x) < int(global_position.x):
			if facing_right:
				flip()
	timer.start(0.15)


func start_boss() -> void:
	for i in 10:
		yield(get_tree(), "physics_frame")
	GlobalEvents.emit_signal("ui_dialogued","Worthless!!! As I thought!", NAME)
	#yield(GlobalEvents, "ui_dialogued")
	#$Shield.hide()
	$Shield/AnimationPlayer.play_backwards("use")
	$EnemyComponentManager/HurtArea.set_deferred("monitoring", true)
	for coll in $Shield/StaticBody2D.get_children():
		coll.set_deferred("disabled", true)
	yield($Shield/AnimationPlayer, "animation_finished")
	$Shield/StaticBody2D.queue_free()

func flip() -> void:
	if facing_right:
		facing_right = false
		flip_anim_player.play("flip")
	else:
		facing_right = true
		flip_anim_player.play_backwards("flip")


func _story_boss_activated(idx: int) -> void:
	if not idx == GlobalStats.Bosses.CORA: return

	flip()
	GlobalEvents.emit_signal("ui_dialogued","YOU!!!", NAME)
	GlobalEvents.emit_signal("ui_dialogued","I can NOT believe you made it past ALL OF THAT!!!", NAME)
	GlobalEvents.emit_signal("ui_dialogued","YOU ARE GOING TO PASS ME???", NAME)
	GlobalEvents.emit_signal("ui_dialogued","You are not prepared.", NAME)
	GlobalEvents.emit_signal("ui_dialogued","LET'S GO!!!", NAME)
	active = true
	yield(GlobalEvents, "ui_dialogue_hidden")
	$Shield/AnimationPlayer.play("use")

func _hit() -> void:
	pass


func _died() -> void:
	if Globals.death_in_progress:
		return

	$Sprite.playing = false
	$DeathSound.play()
	$DeathAnimationPlayer.play("death")
	$CollisionShape2D.set_deferred("disabled", true)

	mob_component.set_process(false)
	mob_component.set_physics_process(false)
	mob_component.set_physics_process_internal(false)
	get_tree().call_group("Cannon", "disable")
	get_tree().call_group("Snowball", "destroy")
	yield(get_tree().create_timer(0.5), "timeout")

	GlobalEvents.emit_signal("story_boss_killed", GlobalStats.Bosses.CORA)
	GlobalEvents.emit_signal("ui_dialogued", "Hehe", NAME)
	GlobalEvents.emit_signal("ui_dialogued", "Just wait...", NAME)
	GlobalEvents.emit_signal("ui_dialogued", "If you thought that was any hard... you are in for a suprise.", NAME)
	GlobalEvents.emit_signal("ui_dialogued", "Take this, you are not going to make it much farther. HAHAHA!", NAME)
	set_physics_process(false)
	set_process(false)



func _on_Timer_timeout() -> void:
	throw_allowed = true
