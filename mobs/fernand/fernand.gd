extends KinematicBody2D


enum States {
	FLY,
	CHASE,
	SHOOT_PLAYER,
}
const NAME: String = "Fernand"

var facing_right: bool = true
var active: bool = false
var linear_velocity := Vector2()

const SHOOT_SPEED: int = 20
const FLY_SPEED: int = 45
const CHASE_SPEED: int = 120

var current_speed: int = 0
var state: int = States.FLY

onready var mob_component: Node2D = $EnemyComponentManager
onready var timer: Timer= $Timer
onready var flip_anim_player: AnimationPlayer= $FlipAnimationPlayer

onready var water_gun: Area2D = $"Position2D/Water Gun/EquippableBase"
onready var position_2d : Position2D = $Position2D
onready var fake_pos : Position2D = $FakePos

onready var vis_noti: VisibilityNotifier2D = $VisibilityNotifier2D

onready var ray_right: RayCast2D= $RayCastRight
onready var ray_left: RayCast2D = $RayCastLeft


func _ready() -> void:
	var __: int
	__ = GlobalEvents.connect("story_boss_activated", self, "_story_boss_activated")
	__ = mob_component.connect("died", self, "_died")
	__ = mob_component.connect("hit", self, "_hit")
	$"Position2D/Water Gun/EquippableBase".mode = 2

func _physics_process(_delta: float) -> void:
	if not active: return


	#update_gun_direction()
	if facing_right and ray_right.is_colliding():
		flip()
	elif not facing_right and ray_left.is_colliding():
		flip()


	current_speed = 0

	if facing_right:
		current_speed = 1
	else:
		current_speed = -1

	match state:
		States.FLY:
			fly_ai()

		States.CHASE:
			chase_ai()

		States.SHOOT_PLAYER:
			shoot_player_ai()

	linear_velocity.y = 0
	linear_velocity.x = lerp(linear_velocity.x, current_speed, 0.1)
	linear_velocity = move_and_slide(linear_velocity, Vector2.UP)


func state_switching() -> void:
	var prev_state = state
	randomize()
	timer.start(rand_range(0.5, 2))
	var new_state = randi() % 3
	state = new_state
	while new_state == prev_state:
		new_state = randi() % 3
		state = new_state
		yield(get_tree(), "physics_frame")
	if state == States.FLY:
		flip()
	yield(timer, "timeout")
	state_switching()


func flip() -> void:
	if facing_right:
		facing_right = false
		flip_anim_player.play("flip")
	else:
		facing_right = true
		flip_anim_player.play_backwards("flip")


func fly_ai() -> void:
	current_speed *= FLY_SPEED


func chase_ai() -> void:
	var player_pos: Vector2 = get_node(GlobalPaths.PLAYER).global_position
	if player_pos.x <= global_position.x - 7:
		if facing_right:
			flip()
	elif player_pos.x > global_position.x + 7:
		if not facing_right:
			flip()
	current_speed *= CHASE_SPEED


func shoot_player_ai() -> void:
	if not vis_noti.is_on_screen(): return
	var look_pos: Vector2 = get_node(GlobalPaths.PLAYER).global_position + Vector2(6, 6)
	randomize()
	var variation: float = rand_range(-5, 5)
	look_pos.x += variation
	variation = rand_range(-5, 5)
	look_pos.y += variation
	position_2d.look_at(look_pos)
	current_speed *= SHOOT_SPEED

	update_gun_direction()
	if water_gun.may_fire:
		water_gun.fire()


func update_gun_direction() -> void:
	if position_2d.rotation_degrees >= 180:
		position_2d.rotation_degrees = -180
	elif position_2d.rotation_degrees <= -180:
		position_2d.rotation_degrees = 180

	if position_2d.rotation_degrees > 90 or position_2d.rotation_degrees < -90:
		position_2d.position = Vector2(-8.5, 1)
		water_gun.scale.x = 1
		water_gun.scale.y = -1

	else:
		position_2d.position = Vector2(7, 1)
		water_gun.scale.x = 1
		water_gun.scale.y = 1


func _story_boss_activated(idx: int) -> void:
	if not idx == GlobalStats.Bosses.FERNAND: return

	GlobalEvents.emit_signal("ui_dialogued","Oh... you found me.", NAME)
	GlobalEvents.emit_signal("ui_dialogued","I was hired- wait, no. I am here to destroy you!", NAME)
	GlobalEvents.emit_signal("ui_dialogued","You won't see the last of me!", NAME)

	active = true
	state_switching()


func _hit() -> void:
	pass


func _died() -> void:
	if Globals.death_in_progress:
		return

	$DeathSound.play()
	$DeathAnimationPlayer.play("death")
	$Position2D.hide()
	$CollisionShape2D.set_deferred("disabled", true)

	mob_component.set_process(false)
	mob_component.set_physics_process(false)
	mob_component.set_physics_process_internal(false)

	yield(get_tree().create_timer(0.5), "timeout")

	GlobalEvents.emit_signal("story_boss_killed", GlobalStats.Bosses.FERNAND)
	GlobalEvents.emit_signal("ui_dialogued", "No... HOW???", NAME)
	GlobalEvents.emit_signal("ui_dialogued", "You know what? It's okay.", NAME)
	GlobalEvents.emit_signal("ui_dialogued", "YOU ARE NOT DONE YET!", NAME)
	GlobalEvents.emit_signal("ui_dialogued", "Oh, just wait, you'll see more of me.", NAME)
	GlobalEvents.emit_signal("ui_dialogued", "Here, I\'ll give this to you. YOU WILL NEED IT. But you will fail anyways, so here you go.", NAME)
	set_physics_process(false)
	set_process(false)

