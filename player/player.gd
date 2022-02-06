extends KinematicBody2D

const WATER_JUMP_SPEED: int = 65
const WATER_SPEED: int = 64
const WATER_GRAVITY: int = 150
const WATER_SUCTION: int = 50
const WATER_JUMP_BOOST: int = 350
const INVINCIBILITY_TIME: float = 0.65
const LERP_SPEED: float = 0.08
const LERP_SPEED_ICE: float = 0.025
const TERMINAL_VELOCITY: int = 475
var linear_velocity := Vector2.ZERO

var last_tile := ""

var sprint_speed: float = 80
var walk_speed: float = 65
var air_time: float = 0
var current_speed: float = 0
var speed_modifier: float = 1
var speed_modifier_land: float = 1
var lerp_speed: float = LERP_SPEED

var jump_speed: int = 200
var current_gravity: int = 0

var cayote_used := false
var may_dash := true
var second_jump_used := true
var sprinting_pressed := false
var in_water := false
var sprinting := false
var falling := false
var facing_right := true
var dashing := false
var was_falling := false
var waiting_frame := false

onready var fsm: Node = $FSM
onready var down_check_cast: RayCast2D = $Checks/Down
onready var wall_checks = [$Checks/WallLeft, $Checks/WallRight]
onready var collision_shape: CollisionShape2D = $CollisionShape2D
onready var floor_checks := [$Checks/FloorLeft, $Checks/FloorRight]
onready var area_2d: Area2D = $Area2D
onready var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")

onready var invincible_timer: Timer = $InvincibleTimer
onready var hurt_sound: AudioStreamPlayer = $HurtSound
onready var die_sound: AudioStreamPlayer = $DieSound
onready var dash_failed_sound: AudioStreamPlayer = $DashFailedSound


func _ready() -> void:
	var __: int
	__ = GlobalEvents.connect("level_subsection_changed", self, "_level_subsection_changed")
	__ = GlobalEvents.connect("player_death_started", self, "_player_death_started")
	__ = GlobalEvents.connect("player_died", self, "_player_died")
	__ = GlobalEvents.connect("player_hurt_enemy", self, "_player_hurt_enemy")
	__ = GlobalEvents.connect("player_hurt_from_enemy", self, "_player_hurt_from_enemy")
	__ = GlobalEvents.connect("player_killed_enemy", self, "_player_killed_enemy")
	__ = GlobalEvents.connect("player_used_powerup", self, "_player_used_powerup")
	__ = GlobalEvents.connect("player_powerup_ended", self, "_player_powerup_ended")
	__ = GlobalEvents.connect("player_used_springboard", self, "_player_used_springboard")
	__ = area_2d.connect("body_entered", self, "_body_entered")
	__ = area_2d.connect("area_entered", self, "_area_entered")
	__ = area_2d.connect("area_exited", self, "_area_exited")
	__ = get_tree().connect("physics_frame", self, "_physics_frame")
	current_gravity = gravity

	Globals.death_in_progress = false
	Globals.player_invincible = false
	GlobalLevel.error_detection()


# Spikes
func _physics_process(_delta):

	if Globals.death_in_progress:
		linear_velocity = Vector2(0, 0)

	#print(linear_velocity.y)
	if get_tree().paused: return
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		var collider = collision.collider

		if collider is TileMap:
			if collider.is_in_group("Spikes"):
				var tile_pos = collider.world_to_map(collision.position - collision.normal)
				var tile_id = collider.get_cellv(tile_pos)

				GlobalEvents.emit_signal("player_hurt_from_enemy", Globals.HurtTypes.TOUCH, collider.knockback, GlobalStats.get_spike_damage(tile_id))
				return

	if Input.is_action_pressed("move_sprint"):
		sprinting_pressed = true

	if is_on_floor():
		second_jump_used = false

	if is_on_ice():
		lerp_speed = LERP_SPEED_ICE
		speed_modifier_land = 1.8
	else:
		lerp_speed = LERP_SPEED
		speed_modifier_land = 1

	if was_falling and is_on_floor():
		waiting_frame = true

		#yield(get_tree(), "physics_frame")


	GlobalInput.dash_activated = may_dash and GlobalSave.get_stat("rank") >= GlobalStats.Ranks.GOLD


func _physics_frame() -> void:
	if waiting_frame:
		yield(get_tree(), "physics_frame")
		was_falling = false
		waiting_frame = false


func basic_movement():
	if GlobalUI.menu == GlobalUI.Menus.CUTSCENE: return

	var delta = get_physics_process_delta_time()

	if sprinting:
		current_speed = sprint_speed
	else:
		current_speed = walk_speed

	current_speed *= GlobalInput.get_action_strength()

	linear_velocity.x = lerp(linear_velocity.x, current_speed * speed_modifier * speed_modifier_land, lerp_speed)
	linear_velocity.y += delta * current_gravity

	if linear_velocity.y > TERMINAL_VELOCITY:
		linear_velocity.y = TERMINAL_VELOCITY

	if not fsm.current_state == fsm.idle:
		linear_velocity.x -= (get_floor_velocity().x * 0.07)

#	linear_velocity = Vector2(stepify(linear_velocity.x, 1), stepify(linear_velocity.y, 1))
#
#	if fsm.current_state == fsm.idle:
#		if facing_right:
#			if linear_velocity.x < 8 and linear_velocity.x > 0:
#				linear_velocity.x -= 1
#		else:
#			if linear_velocity.x > -8 and linear_velocity.x < 0:
#				linear_velocity.x += 1

#	linear_velocity.x = round_to_dec(linear_velocity.x, 1)
#	linear_velocity.y = round_to_dec(linear_velocity.y, 1)
	linear_velocity = move_and_slide(linear_velocity, Vector2.UP)

	falling = linear_velocity.y > 0
	#print(linear_velocity)
	#print(falling)

	if falling:
		was_falling = true

	#falling = linear_velocity.y > 0
	down_check()


func is_on_ice() -> bool:
	if fsm.current_state == fsm.wall_slide or fsm.current_state == fsm.wall_jump:
		return false

	for i in get_slide_count():
		var collision = get_slide_collision(i)
		var collider = collision.collider

		if collider is TileMap:
			last_tile = collider.name

	match last_tile:
			"TileMapIce":
				return true
			"TileMapIceBlock":
				return true

	return false


func round_to_dec(num, decimal):
	num = float(num)
	decimal = int(decimal)
	var sgn = 1
	if num < 0:
			sgn = -1
			num = abs(num)
			pass
	var num_fraction = num - int(num)
	var num_dec = round(num_fraction * pow(10.0, decimal)) / pow(10.0, decimal)
	var round_num = sgn*(int(num) + num_dec)
	return round_num
	pass

func start_invincibility(time: float) -> void:
	yield(get_tree(), "physics_frame")

	GlobalEvents.emit_signal("player_invincibility_started")
	Globals.player_invincible = true
	invincible_timer.start(time)


func stop_invincibility() -> void:
	GlobalEvents.emit_signal("player_invincibility_stopped")
	Globals.player_invincible = false

func spawn_water_particles() -> void:
	var w_part: PackedScene = load(GlobalPaths.WATER_PARTICLES)
	var part_inst = w_part.instance()

	get_node(GlobalPaths.LEVEL).call_deferred("add_child", part_inst)
	var new_pos: Vector2 = global_position
	new_pos.y += 12
	part_inst.set_deferred("global_position", new_pos)


func dash_failed() -> void:
	if GlobalSave.get_stat("rank") > 1 and GlobalSave.get_stat("adrenaline") <= 0:
		dash_failed_sound.play()


func on_wall() -> bool:
	return (((wall_checks[0].is_colliding() and not facing_right) and ((GlobalInput.get_action_strength() < 0) or (Input.is_action_pressed("move_left") and Input.is_action_pressed("move_right")))) or \
			((wall_checks[1].is_colliding() and facing_right) and ((GlobalInput.get_action_strength() > 0) or (Input.is_action_pressed("move_left") and Input.is_action_pressed("move_right"))))) \


func on_floor() -> bool:
	return is_on_floor() or floor_checks[0].is_colliding() or floor_checks[1].is_colliding()


func down_check() -> void:
	if is_on_floor() and Input.is_action_pressed("move_down"):
		if not down_check_cast.is_colliding():
			position.y += 2


func can_dash() -> bool:
	return not GlobalSave.get_stat("adrenaline") <= 0 \
			and GlobalSave.get_stat("rank") >= GlobalStats.Ranks.GOLD \
			and may_dash \
			and not is_on_floor() and not is_on_wall()


func can_second_jump() -> bool:
	return GlobalSave.get_stat("rank") >= GlobalStats.Ranks.SILVER \
			and not second_jump_used


func can_wall_slide() -> bool:
	return on_wall() and GlobalSave.get_stat("rank") >= GlobalStats.Ranks.SILVER


# Start of GlobalEvents
func _level_subsection_changed(pos: Vector2) -> void:
	yield(GlobalEvents, "ui_faded")

	global_position.x = pos.x - 2
	global_position.y = pos.y - 7


func _player_death_started() -> void:
	GlobalUI.menu_locked = true
	linear_velocity = Vector2(0, 0)
	fsm.change_state(fsm.idle, true)

	set_collision_layer_bit(0, false)
	set_collision_mask_bit(3, false)

	Globals.player_invincible = false
	hurt_sound.pitch_scale = 0.65
	hurt_sound.play()
	if not die_sound.playing:
		die_sound.play()


func _player_died() -> void:
	set_collision_layer_bit(0, true)
	set_collision_mask_bit(3, true)

	in_water = false
	sprinting = false
	falling = false
	collision_shape.set_deferred("disabled", true)


func _player_hurt_enemy(hurt_type: int) -> void:
	GlobalInput.start_normal_vibration()
	if not fsm.current_state == fsm.dash:
		may_dash = true

	if GlobalStats.timed_powerup_active and GlobalStats.active_timed_powerup == "glitch orb":
		return

	if hurt_type == Globals.HurtTypes.JUMP:
		var new_jump_speed = jump_speed

		if in_water:
			new_jump_speed /= 3

		air_time = 0
		linear_velocity.y = -new_jump_speed

		if not in_water:
			fsm.change_state(fsm.jump)


func _player_hurt_from_enemy(hurt_type: int, knockback: int, damage: int) -> void:
	if fsm.current_state == fsm.dash: return
	if Globals.player_invincible: return
	if Globals.death_in_progress: return

	GlobalInput.start_high_vibration()

	GlobalSave.set_health(GlobalSave.get_stat("health") - damage)


	if not GlobalSave.get_stat("health") <= 0:
		if hurt_type == Globals.HurtTypes.TOUCH:
			linear_velocity.y = -knockback

			if facing_right:
				linear_velocity.x -= knockback
			else:
				linear_velocity.x += knockback
		elif hurt_type == Globals.HurtTypes.TOUCH_AIR:
			if facing_right:
				linear_velocity.y = (-knockback / 2.0)
				linear_velocity.x -= knockback
			else:
				linear_velocity.x += knockback
		elif hurt_type == Globals.HurtTypes.BULLET:
			linear_velocity.x = knockback

		start_invincibility(INVINCIBILITY_TIME)
		hurt_sound.pitch_scale = 0.9
		hurt_sound.play()

	else:
		if Globals.death_in_progress: return
		GlobalEvents.emit_signal("player_death_started")


func _player_killed_enemy(hurt_type: int):
	_player_hurt_enemy(hurt_type)


func _player_used_powerup(item_name: String) -> void:
	match item_name:
		"bunny egg":
			speed_modifier = GlobalStats.BUNNY_EGG_BOOST
		"glitch orb":
			start_invincibility(GlobalStats.GLITCH_ORB_TIME)


func _player_powerup_ended(item_name: String) -> void:
	match item_name:
		"bunny egg", "pear":
			speed_modifier = 1
		"glitch orb":
			pass


func _player_used_springboard(amount: int) -> void:
	fsm.change_state(fsm.jump)
	linear_velocity.y -= amount
	second_jump_used = true
# End of GlobalEvents


func _body_entered(body: Node) -> void:
	if body.is_in_group("Bullet"):
		if body.player_bullet: return

		var kb = 100

		#var vel_x = body.get_parent().linear_velocity.x

		# moving left
		#if vel_x < 0:
		if not facing_right:
			kb = -kb
		GlobalEvents.emit_signal("player_hurt_from_enemy", Globals.HurtTypes.BULLET, kb, body.damage)


func _area_entered(area: Area2D) -> void:
	if area.is_in_group("Water"):
		if not $WaterSplashIn.playing:
			$WaterSplashIn.play()

		spawn_water_particles()

		in_water = true

		linear_velocity.y = WATER_SUCTION

		fsm.change_state(fsm.water_idle)


func _area_exited(area: Area2D) -> void:
	if area.is_in_group("Water"):
		if not $WaterSplashOut.playing:
			$WaterSplashOut.play()

		spawn_water_particles()

		may_dash = true
		in_water = false

		linear_velocity.y = -WATER_JUMP_BOOST
		basic_movement()

		if not in_water:
			fsm.change_state(fsm.jump)


func _on_InvincibleTimer_timeout() -> void:
	stop_invincibility()
