extends KinematicBody2D

enum States {
	CHASE,
	JUMP
}

const NAME: String = "Ostrich"

var facing_right: bool = true
var active: bool = false
var linear_velocity := Vector2()

const JUMP_SPEED: int = 400
const CHASE_SPEED: int = 125

var current_speed: int = 0
var state: int = States.CHASE

onready var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity") / 30

onready var mob_component: Node2D = $EnemyComponentManager
onready var timer: Timer= $Timer
onready var flip_anim_player: AnimationPlayer= $FlipAnimationPlayer

onready var vis_noti: VisibilityNotifier2D = $VisibilityNotifier2D

onready var ray_right: RayCast2D= $RayCastRight
onready var ray_left: RayCast2D = $RayCastLeft
onready var ray_right_top: RayCast2D= $RayCastRightTop
onready var ray_left_top: RayCast2D = $RayCastLeftTop

func _ready() -> void:
	var __: int
	__ = GlobalEvents.connect("story_boss_activated", self, "_story_boss_activated")
	__ = mob_component.connect("died", self, "_died")
	__ = mob_component.connect("hit", self, "_hit")


func _physics_process(_delta: float) -> void:
	if not active: return

	match state:
		States.CHASE:
			chase_ai()
		States.JUMP:
			jump_ai()

	if not state == States.JUMP:
		if facing_right and ray_right.is_colliding():
			if ray_right_top.is_colliding():
				flip()
			else:
				linear_velocity.y -= JUMP_SPEED
				state = States.JUMP
		elif not facing_right and ray_left.is_colliding():
			if ray_left_top.is_colliding():
				flip()
			else:
				linear_velocity.y -= JUMP_SPEED
				state = States.JUMP

	linear_velocity.y += gravity
	linear_velocity.x = lerp(linear_velocity.x, current_speed, 0.1)
	linear_velocity = move_and_slide(linear_velocity, Vector2.UP)


func flip() -> void:
	if facing_right:
		facing_right = false
		flip_anim_player.play("flip")
	else:
		facing_right = true
		flip_anim_player.play_backwards("flip")


func chase_ai() -> void:
	var player_pos: Vector2 = get_node(GlobalPaths.PLAYER).global_position

	if not player_pos.y + 20 <= global_position.y :
		if player_pos.x <= global_position.x - 7:
			if facing_right:
				flip()
		elif player_pos.x > global_position.x + 7:
			if not facing_right:
				flip()

	if facing_right:
		current_speed = 1
	else:
		current_speed = -1

	current_speed *= CHASE_SPEED

	$Sprite.playing = true

func jump_ai() -> void:
	$Sprite.playing = false
	if is_on_floor():
		state = States.CHASE


func _story_boss_activated(idx: int) -> void:
	if not idx == GlobalStats.Bosses.OSTRICH: return

	flip()
	GlobalEvents.emit_signal("ui_dialogued","Huh? A visitor...", NAME)
	GlobalEvents.emit_signal("ui_dialogued","You know... I don't even have a name. I am literally called \"Ostrich\"", NAME)
	GlobalEvents.emit_signal("ui_dialogued","Sigh... I'M HUUNGRRRYYYY.", NAME)
	active = true


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

	yield(get_tree().create_timer(0.5), "timeout")

	GlobalEvents.emit_signal("story_boss_killed", GlobalStats.Bosses.OSTRICH)
	GlobalEvents.emit_signal("ui_dialogued", "Wow...", NAME)
	GlobalEvents.emit_signal("ui_dialogued", "This is embarrassing.", NAME)
	GlobalEvents.emit_signal("ui_dialogued", "I am going to let our master down...", NAME)
	GlobalEvents.emit_signal("ui_dialogued", "Just take it, I do not even care anymore...", NAME)
	set_physics_process(false)
	set_process(false)
