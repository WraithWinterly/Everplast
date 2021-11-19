extends AnimatedSprite

signal direction_changed(facing_right)

var jump_dust_played: bool = false

onready var dust: PackedScene = load(FileLocations.dust)
onready var player_body: KinematicBody2D = get_parent().get_parent().get_node("KinematicBody2D")
onready var player: Player = get_parent().get_parent()
onready var fsm: Node = get_parent().get_parent().get_node("FSM")
onready var flash_animation_player: AnimationPlayer = $FlashAnimationPlayer
onready var death_animation_player: AnimationPlayer = $DeathAnimationPlayer
onready var camera: Camera2D = get_parent().get_node("Camera2D")
onready var particles: Particles2D = $Particles2D
onready var particles_reverse: Particles2D = $Particles2DReverse


func _ready() -> void:
	var __: int
	__ = Signals.connect("start_player_death", self, "_start_player_death")
	__ = fsm.connect("state_changed", self, "_state_changed")
	particles.emitting = false
	particles_reverse.emitting = false
	modulate = Color8(255, 255, 255, 255)
	position = Vector2(0, 0)
	visible = true
	rotation_degrees = 0
	if Globals.game_state == Globals.GameStates.WORLD_SELECTOR:
		hide()
		fsm.current_state = fsm.idle
		fsm.enabled = false
		#yield(UI, "faded")
		$AnimationPlayer.play("spawn")
		yield(get_tree(), "physics_frame")
		show()
		$SpawnSound.play()
		fsm.enabled = true


func _process(_delta: float) -> void:
	match fsm.current_state:
		fsm.idle:
			animation = "idle"
		fsm.walk:
			control_flip_h()
			if not player_body.wall_checks[0].is_colliding() and not player_body.wall_checks[1].is_colliding():
				animation = "walk"
			else:
				animation = "idle"
		fsm.sprint:
			control_flip_h()
			if not player_body.wall_checks[0].is_colliding() and not player_body.wall_checks[1].is_colliding():
				animation = "sprint"
			else:
				animation = "idle"
		fsm.jump, fsm.fall:
			control_flip_h()
			if abs(Main.get_action_strength()) > 0:
				animation = "air_walk"
			else:
				animation = "air_idle"
			if not jump_dust_played:
				jump_dust_played = true
				var dust_effect: Node2D = dust.instance()

				get_node(Globals.level_path).add_child(dust_effect)
				dust_effect.global_position = \
						get_node(Globals.player_body_path).global_position

		fsm.water_idle:
			animation = "idle"

		fsm.water_move:
			control_flip_h()
			if not abs(Globals.get_main().get_action_strength()) == 0:
				animation = "walk"
			else:
				animation = "idle"

		fsm.dash:
			animation = "dash"

		fsm.wall_jump:
			flip_h = not player.facing_right
			emit_signal("direction_changed", true)


func control_flip_h() -> void:
	if Main.get_action_strength() > 0:
		flip_h = false
		emit_signal("direction_changed", false)
		player.facing_right = true
	elif Main.get_action_strength() < 0:
		flip_h = true
		emit_signal("direction_changed", true)
		player.facing_right = false


func _start_player_death() -> void:
	if not Globals.death_in_progress:
		Globals.death_in_progress = true
		death_animation_player.play("death")
		yield(death_animation_player, "animation_finished")
		Signals.emit_signal("player_death")


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
