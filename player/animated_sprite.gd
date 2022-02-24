extends AnimatedSprite

signal direction_changed(facing_right)

export(Color) var normal_color_1
export(Color) var normal_color_2
export(Color) var normal_color_3
export(Color) var gold_color_1
export(Color) var gold_color_2
export(Color) var gold_color_3
export(Color) var diamond_color_1
export(Color) var diamond_color_2
export(Color) var diamond_color_3
export(Color) var glitch_color_1
export(Color) var glitch_color_2
export(Color) var glitch_color_3

var jump_dust_played := false
var bypass := false

onready var player: Node2D = $"../../KinematicBody2D"
onready var fsm: Node = $"../../KinematicBody2D/FSM"
onready var flash_animation_player: AnimationPlayer = $FlashAnimationPlayer
onready var death_animation_player: AnimationPlayer = $DeathAnimationPlayer
onready var particles: Particles2D = $Particles2D
onready var particles_reverse: Particles2D = $Particles2DReverse
onready var wall_checks := [get_parent().get_parent().get_node("KinematicBody2D/Checks/LowerWallLeft"), get_parent().get_parent().get_node("KinematicBody2D/Checks/LowerWallRight")]
onready var dust: PackedScene = load(GlobalPaths.DUST)
onready var level_up_light: Sprite = $LevelUpLight
onready var equippable: Position2D = $Equippable
onready var equippable_holder: Position2D = $EquippableHolder


func _ready() -> void:
	var __: int
	__ = GlobalEvents.connect("level_complete_started", self, "_level_complete_started")
	__ = GlobalEvents.connect("level_subsection_changed", self, "_level_subsection_changed")
	__ = GlobalEvents.connect("player_invincibility_started", self, "_player_invincibility_started")
	__ = GlobalEvents.connect("player_invincibility_stopped", self, "_player_invincibility_stopped")
	__ = GlobalEvents.connect("player_death_started", self, "_player_death_started")
	__ = GlobalEvents.connect("player_level_increased", self, "_player_level_increased")
	__ = GlobalEvents.connect("ui_inventory_opened", self, "_ui_inventory_opened")
	__ = GlobalEvents.connect("ui_shop_opened", self, "_ui_shop_opened")
	__ = GlobalEvents.connect("ui_level_enter_menu_pressed", self, "_level_enter_menu_pressed")
	__ = GlobalEvents.connect("ui_dialogued", self, "_ui_dialogued")
	__ = fsm.connect("state_changed", self, "_state_changed")

	particles.emitting = false
	particles_reverse.emitting = false
	modulate = Color8(255, 255, 255, 255)
	position = Vector2(0, 0)
	visible = true
	rotation_degrees = 0

	if Globals.game_state == Globals.GameStates.WORLD_SELECTOR:
		fsm.enabled = false
		fsm.current_state = fsm.idle
		hide()
		yield(GlobalEvents, "ui_faded")
		yield(get_tree(), "physics_frame")
		$AnimationPlayer.play("spawn")
		show()
		$SpawnSound.play()
		fsm.enabled = true

	set_color_shader()
	level_up_light.set_as_toplevel(true)


func _process(_delta: float) -> void:
	if bypass: return

	playing = not get_tree().paused

	if get_tree().paused:
		return


	match fsm.current_state:
		fsm.idle:
			animation = "idle"

		fsm.walk:
			update_anim_speed()
			control_flip_h()
			if not wall_checks[0].is_colliding() and not wall_checks[1].is_colliding():
				animation = "walk"
			else:
				animation = "idle"

		fsm.sprint:
			update_anim_speed()
			control_flip_h()
			if not wall_checks[0].is_colliding() and not wall_checks[1].is_colliding():
				animation = "sprint"
			else:
				animation = "idle"

		fsm.jump, fsm.fall:
			control_flip_h()

			if abs(GlobalInput.get_action_strength()) > 0:
				animation = "air_walk"
			else:
				animation = "air_idle"

			if not jump_dust_played:
				jump_dust_played = true
				var dust_effect: Node2D = dust.instance()

				get_node(GlobalPaths.LEVEL).add_child(dust_effect)
				dust_effect.global_position = \
						get_node(GlobalPaths.PLAYER).global_position

		fsm.water_idle:
			animation = "idle"

		fsm.water_move:
			update_anim_speed()
			control_flip_h()
			if not abs(GlobalInput.get_action_strength()) == 0:
				animation = "walk"
			else:
				animation = "idle"

		fsm.dash:
			animation = "dash"

		fsm.wall_jump:
			if player.facing_right:
				flip_h = false
				emit_signal("direction_changed", false)
				GlobalEvents.emit_signal("player_anim_sprite_direction_changed", true)
			else:
				flip_h = true
				emit_signal("direction_changed", true)
				GlobalEvents.emit_signal("player_anim_sprite_direction_changed", false)

		fsm.wall_slide:
			animation = "air_walk"
			if fsm.wall_slide.sliding_right:
				flip_h = false
				player.facing_right = true
			else:
				flip_h = true
				player.facing_right = false

	level_up_light.global_position.x = global_position.x + 5.5
	level_up_light.global_position.y = global_position.y + 13


func _physics_process(_delta: float) -> void:
	playing = not (animation == "idle" and not player.is_on_floor())


func set_color_shader() -> void:
	match int(GlobalSave.get_stat("rank")):
		GlobalStats.Ranks.NONE, GlobalStats.Ranks.SILVER:
			material.set_shader_param("new_color_1", normal_color_1)
			material.set_shader_param("new_color_2", normal_color_2)
			material.set_shader_param("new_color_3", normal_color_3)
		GlobalStats.Ranks.GOLD:
			material.set_shader_param("new_color_1", gold_color_1)
			material.set_shader_param("new_color_2", gold_color_2)
			material.set_shader_param("new_color_3", gold_color_3)
		GlobalStats.Ranks.DIAMOND:
			material.set_shader_param("new_color_1", diamond_color_1)
			material.set_shader_param("new_color_2", diamond_color_2)
			material.set_shader_param("new_color_3", diamond_color_3)
		GlobalStats.Ranks.GLITCH:
			material.set_shader_param("new_color_1", glitch_color_1)
			material.set_shader_param("new_color_2", glitch_color_2)
			material.set_shader_param("new_color_3", glitch_color_3)


func update_anim_speed() -> void:
	speed_scale = abs(GlobalInput.get_action_strength()) * 2
	speed_scale = clamp(speed_scale, 0, 1)


func control_flip_h() -> void:
	if get_tree().paused: return
	if player.can_wall_slide(): return

	if GlobalInput.get_action_strength() > 0:
		player.facing_right = true
		flip_h = false
		emit_signal("direction_changed", false)
		#GlobalEvents.emit_signal("player_anim_sprite_direction_changed", true)
	elif GlobalInput.get_action_strength() < 0:
		player.facing_right = false
		flip_h = true
		emit_signal("direction_changed", true)
		#GlobalEvents.emit_signal("player_anim_sprite_direction_changed", false)


func _level_complete_started() -> void:
	bypass = true
	animation = "idle"


func _level_subsection_changed(_pos: Vector2) -> void:
	bypass = true
	animation = "idle"
	yield(GlobalEvents, "ui_faded")
	bypass = false


func _player_invincibility_started() -> void:
	flash_animation_player.play("flash")


func _player_invincibility_stopped() -> void:
	modulate = Color(1, 1, 1, 1)
	flash_animation_player.stop()


func _player_death_started() -> void:
	if not Globals.death_in_progress:
		Globals.death_in_progress = true
		death_animation_player.play("death")
		yield(death_animation_player, "animation_finished")
		hide()
		GlobalEvents.emit_signal("player_died")


func _player_level_increased(_type: String) -> void:
	$AnimationPlayer.play("level_up")
	yield($AnimationPlayer, "animation_finished")
	GlobalEvents.emit_signal("player_level_increase_animation_finished")


func _level_enter_menu_pressed() -> void:
	bypass = true
	animation = "idle"
	yield(get_tree(), "physics_frame")
	bypass = false


func _ui_inventory_opened() -> void:
	bypass = true
	animation = "idle"
	yield(get_tree(), "physics_frame")
	bypass = false


func _ui_shop_opened(_item: Dictionary) -> void:
	bypass = true
	animation = "idle"
	yield(get_tree(), "physics_frame")
	bypass = false


func _ui_dialogued(_content: String, _person: String = "", _func_call: String = ""):
	bypass = true
	animation = "idle"
	yield(get_tree(), "physics_frame")
	bypass = false


func _state_changed() -> void:
	if fsm.current_state == fsm.dash:
		particles.restart()
		particles_reverse.restart()
		if flip_h:
			particles_reverse.emitting = true
		else:
			particles.emitting = true
	else:
		particles.emitting = false
		particles_reverse.emitting = false

	if fsm.current_state == fsm.jump:
		jump_dust_played = false
