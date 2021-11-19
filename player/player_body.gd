extends KinematicBody2D

# All code required for movement
const water_jump_speed: int = 65

const water_speed: int = 64
const water_gravity: int = 150
const water_suction: int = 50
const ladder_gravity: int = 1
const out_water_boost: int = 225

var linear_velocity: Vector2 = Vector2.ZERO

var jump_speed: int = 190
var current_gravity: int = 0
var cayote_used: bool = false
var sprint_speed: float = 80
var walk_speed: float = 65
var air_time: float = 0
var current_speed: float = 0

var bunny_speed: float = 80
var speed_modifier: float = 1
var may_dash: bool = true
var second_jump_used: bool = true

onready var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")
onready var player: Player = get_parent()
onready var fsm: Node = get_parent().get_node("FSM")
onready var down_check_cast: RayCast2D = $Checks/Down
onready var wall_checks = [$Checks/WallLeft, $Checks/WallRight]
onready var collision_shape: CollisionShape2D = $CollisionShape2D
onready var jump_checks := [$Checks/WallLeft, $Checks/WallRight]


func _ready() -> void:
	var __: int
	__ = Signals.connect("start_player_death", self, "_start_player_death")
	__ = Signals.connect("player_death", self, "_player_death")
	__ = Signals.connect("player_hurt_from_enemy", self, "_player_hurt_from_enemy")
	__ = Signals.connect("player_hurt_enemy", self, "_player_hurt_enemy")
	__ = Signals.connect("player_killed_enemy", self, "_player_killed_enemy")
	__ = Signals.connect("sublevel_changed", self, "_sublevel_changed")
	__ = Signals.connect("powerup_used", self, "_powerup_used")
	__ = Signals.connect("powerup_ended", self, "_powerup_ended")
	__ = Signals.connect("springboard_used", self, "_springboard_used")
	current_gravity = gravity


# Spikes
func _physics_process(_delta):
	for i in get_slide_count():
		var collider = get_slide_collision(i).collider
		if collider is TileMap:
			if collider.is_in_group("Spikes"):
				Signals.emit_signal("player_hurt_from_enemy",
						Globals.EnemyHurtTypes.NORMAL, collider.knockback, collider.damage)
				return


func basic_movement():
	var delta = get_physics_process_delta_time()
	player.falling = linear_velocity.y > 0
	if player.sprinting:
		current_speed = sprint_speed
	else:
		current_speed = walk_speed
	current_speed *= Main.get_action_strength()
	linear_velocity.x = lerp(linear_velocity.x, current_speed * speed_modifier, 0.1)
	linear_velocity.y += delta * current_gravity
	if not fsm.current_state == fsm.idle:
		linear_velocity.x -= (get_floor_velocity().x * 0.07)
	linear_velocity = move_and_slide(linear_velocity, Vector2.UP, true)

	down_check()


func on_wall() -> bool:
	return ((jump_checks[0].is_colliding() and Main.get_action_strength() < 0) or \
			(jump_checks[1].is_colliding() and Main.get_action_strength() > 0)) \
			and Globals.game_state == Globals.GameStates.LEVEL


func down_check() -> void:
	if is_on_floor() and Input.is_action_pressed("move_down"):
		if not down_check_cast.is_colliding():
			position.y += 2


func can_dash() -> bool:
	return not PlayerStats.get_stat("adrenaline") <= 0 \
			and PlayerStats.get_stat("rank") >= PlayerStats.Ranks.GOLD \
			and may_dash and Globals.game_state == Globals.GameStates.LEVEL \
			and not is_on_floor() and not is_on_wall()


func can_second_jump() -> bool:
	return PlayerStats.get_stat("rank") >= PlayerStats.Ranks.SILVER \
			and not second_jump_used and Globals.game_state == Globals.GameStates.LEVEL


func can_wall_slide() -> bool:
	return on_wall() and PlayerStats.get_stat("rank") >= PlayerStats.Ranks.SILVER


func _player_hurt_from_enemy(hurt_type: int, knockback: int, _damage: int) -> void:
	if fsm.current_state == fsm.dash: return
	if not Globals.player_invincible and not PlayerStats.get_stat("health") <= 0:
		if hurt_type == Globals.EnemyHurtTypes.NORMAL:
			linear_velocity.y = -knockback
			if player.facing_right:
				linear_velocity.x -= knockback
			else:
				linear_velocity.x += knockback
		if hurt_type == Globals.EnemyHurtTypes.NORMAL_AIR:
			if player.facing_right:
				linear_velocity.y = (-knockback / 2.0)
				linear_velocity.x -= knockback
			else:
				linear_velocity.x += knockback

func _player_hurt_enemy(hurt_type: int) -> void:
	player.kinematic_body.may_dash = true
	if hurt_type == Globals.HurtTypes.JUMP:
		if not fsm.current_state == fsm.dash:
			var new_jump_speed = jump_speed
			if player.in_water:
				new_jump_speed /= 2
			air_time = 0
			linear_velocity.y = -new_jump_speed
			if not player.in_water:
				fsm.change_state(fsm.jump)


func _sublevel_changed(pos: Vector2) -> void:
	yield(UI, "faded")
	global_position.x = pos.x - 2
	global_position.y = pos.y - 10


func _player_killed_enemy(hurt_type: int):
	_player_hurt_enemy(hurt_type)


func _on_Area2D_area_entered(area: Area2D) -> void:
	if area.is_in_group("Water"):
		linear_velocity.y = water_suction


func _on_Area2D_area_exited(area: Area2D) -> void:
	if area.is_in_group("Water"):
		linear_velocity.y = -out_water_boost


func _start_player_death() -> void:
	linear_velocity = Vector2(0, 0)
	fsm.change_state(fsm.idle, true)
	set_collision_layer_bit(0, false)
	set_collision_mask_bit(3, false)


func _player_death() -> void:
	set_collision_layer_bit(0, true)
	set_collision_mask_bit(3, true)


func _powerup_used(item_name: String) -> void:
	match item_name:
		"bunny egg":
			speed_modifier = 1.5
		"glitch orb":
			player.start_invincibility(5)


func _powerup_ended(item_name: String) -> void:
	match item_name:
		"bunny egg":
			speed_modifier = 1
		"glitch orb":
			pass

func _springboard_used(amount: int) -> void:
	fsm.change_state(fsm.jump)
	linear_velocity.y -= amount
	second_jump_used = true
