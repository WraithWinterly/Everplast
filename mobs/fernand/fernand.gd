extends KinematicBody2D


enum States {
	FLY,
	CHASE,
	SHOOT_PLAYER,
}

const NAME: String = "Fernand"

var rng := RandomNumberGenerator.new()
var linear_velocity := Vector2()

var state: int = States.FLY

var shoot_speed: int = 20
var chase_speed: int = 120
var fly_speed: int = 45


var current_speed: int = 0

var facing_right: bool = true
var active: bool = false
var is_end_version: bool = false


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
	__ = GlobalEvents.connect("story_w3_fernand_anim_finished", self, "_story_w3_fernand_anim_finished")
	__ = mob_component.connect("died", self, "_died")
	__ = mob_component.connect("hit", self, "_hit")

	get_node("Position2D/Water Gun/EquippableBase").mode = 2

	yield(get_tree(), "physics_frame")

	rng.seed = 203

	if is_end_version:
		mob_component.health = 350
		mob_component.max_health = 350
		shoot_speed = 1
		chase_speed = 300
		fly_speed = 100
		rng.seed = 99
		$"Position2D/Water Gun".queue_free()
		var gun = load("res://world_all/equippables/ice_gun.tscn").instance()
		$Position2D.add_child(gun, true)
		water_gun = gun.get_node("EquippableBase")
		water_gun.mode = 2

	$EnemyComponentManager/HurtArea.monitoring = false

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

	position_2d.global_rotation = lerp_angle(position_2d.global_rotation, fake_pos.global_rotation, 30 * get_physics_process_delta_time())


func state_switching() -> void:
	var prev_state: int = state


	timer.start(rng.randf_range(0.5, 2))

	var new_state = rng.randi() % 3

	state = new_state

	while new_state == prev_state:
		new_state = rng.randi() % 3
		state = new_state

		yield(get_tree(), "physics_frame")

	if state == States.FLY:
		flip()

	if state == States.FLY and is_end_version:
		state = States.SHOOT_PLAYER

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
	current_speed *= fly_speed


func chase_ai() -> void:
	var player_pos: Vector2 = get_node(GlobalPaths.PLAYER).global_position
	if player_pos.x <= global_position.x - 7:
		if facing_right:
			flip()
	elif player_pos.x > global_position.x + 7:
		if not facing_right:
			flip()
	current_speed *= chase_speed


func shoot_player_ai() -> void:
	if not vis_noti.is_on_screen() and not is_end_version: return
	var look_pos: Vector2 = get_node(GlobalPaths.PLAYER).global_position + Vector2(6, 6)

	var variation: float = rng.randf_range(-5, 5)
	look_pos.x += variation
	variation = rng.randf_range(-5, 5)
	look_pos.y += variation
	fake_pos.look_at(look_pos)
	current_speed *= shoot_speed

	update_gun_direction()

	if water_gun.may_fire:
		water_gun.fire()


func update_gun_direction() -> void:
	if fake_pos.rotation_degrees >= 180:
		fake_pos.rotation_degrees = -180
	elif fake_pos.rotation_degrees <= -180:
		fake_pos.rotation_degrees = 180

	if fake_pos.rotation_degrees > 90 or fake_pos.rotation_degrees < -90:
		fake_pos.position = Vector2(-8.5, 1)
		water_gun.scale.x = 1
		water_gun.scale.y = -1

	else:
		fake_pos.position = Vector2(7, 1)
		water_gun.scale.x = 1
		water_gun.scale.y = 1


func _story_boss_activated(idx: int) -> void:
	if not idx == GlobalStats.Bosses.FERNAND: return

	GlobalEvents.emit_signal("ui_dialogued","Oh... you found me.", NAME)
	GlobalEvents.emit_signal("ui_dialogued","I was hired- wait, no. I am here to destroy you!", NAME)
	GlobalEvents.emit_signal("ui_dialogued","You won't see the last of me!", NAME)
	$EnemyComponentManager/HurtArea.monitoring = true
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

	if is_end_version:
		position_2d.queue_free()
		get_tree().call_group("Cannon", "disable")
		get_tree().call_group("Snowball", "destroy")
		get_tree().paused = true
		GlobalEvents.emit_signal("ui_dialogued", "Well... it is over.", NAME)
		GlobalEvents.emit_signal("ui_dialogued", "There is nothing more I can do.", NAME)
		GlobalEvents.emit_signal("ui_dialogued", "You see, as a child, I was always the one left out.", NAME)
		GlobalEvents.emit_signal("ui_dialogued", "It enraged me, all I wanted was revenge.", NAME)
		GlobalEvents.emit_signal("ui_dialogued", "You think this world is real? The Everplast.", NAME)
		GlobalEvents.emit_signal("ui_dialogued", "Ever wondered how we talk to you while we are dead?", NAME)
		GlobalEvents.emit_signal("ui_dialogued", "None of this is real. It was all created for you.", NAME)
		GlobalEvents.emit_signal("ui_dialogued", "The Everplast is a world of peace and giving.", NAME)
		GlobalEvents.emit_signal("ui_dialogued", "And even that, I ruined.", NAME)
		GlobalEvents.emit_signal("ui_dialogued", "I ruined everything.", NAME)
		GlobalEvents.emit_signal("ui_dialogued", "I just always wanted to stand out. To be important.", NAME)
		GlobalEvents.emit_signal("ui_dialogued", "This is the end. There is no more. I can't do more. You are too powerful.", NAME)
		GlobalEvents.emit_signal("ui_dialogued", "Whether or not I return is a secret.", NAME)
		yield(get_tree(), "physics_frame")
		get_tree().paused = true
		yield(GlobalEvents, "ui_dialogue_hidden")
		GlobalEvents.emit_signal("save_file_saved")
		GlobalEvents.emit_signal("story_fernand_beat")
		pause_mode = PAUSE_MODE_PROCESS
		get_tree().paused = true
		queue_free()
	else:
		GlobalEvents.emit_signal("story_boss_killed", GlobalStats.Bosses.FERNAND)
		GlobalEvents.emit_signal("ui_dialogued", "No... HOW???", NAME)
		GlobalEvents.emit_signal("ui_dialogued", "You know what? It's okay.", NAME)
		GlobalEvents.emit_signal("ui_dialogued", "YOU ARE NOT DONE YET!", NAME)
		GlobalEvents.emit_signal("ui_dialogued", "Oh, just wait, you'll see more of me.", NAME)
		GlobalEvents.emit_signal("ui_dialogued", "Here, I\'ll give this to you. YOU WILL NEED IT. But you will fail anyways, so here you go.", NAME)
	set_physics_process(false)
	set_process(false)


func _story_w3_fernand_anim_finished() -> void:
	active = true
	state_switching()


func upgrade() -> void:
	$EnemyComponentManager/HurtArea.monitoring = true
	$AnimationPlayer.play("upgrade")
	$Sprite.material = load("res://mobs/fernand/rainbow.tres")

