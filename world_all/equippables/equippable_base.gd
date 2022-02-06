extends Area2D

export var override_behavior: bool = false

enum {
	COLLECT,
	USE,
	ENEMY_USE,
}

export var equippable_name: String = "water gun"

var mode: int = COLLECT
var firerate: int = 1

var may_fire := true

onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var position_2d: Position2D = $Position2D
onready var pickup_sound: AudioStreamPlayer = $Sound
onready var collision_shape: CollisionShape2D = $CollisionShape2D
onready var no_amo_sound: AudioStreamPlayer = $NoAmo
onready var timer: Timer = $Timer


func _ready() -> void:
	var __: int
	__ = GlobalEvents.connect("player_anim_sprite_direction_changed", self, "_player_anim_sprite_direction_changed")
	__ = connect("body_entered", self, "_body_entered")

	if mode == USE or mode == ENEMY_USE:
		$Sprite.rotation_degrees = 0
		__ = get_parent().get_parent().connect("direction_changed", self, "_direction_changed")
	elif mode == COLLECT:
		rotation_degrees = 23.2

	if override_behavior:
		mode = ENEMY_USE


func _process(_delta: float) -> void:
	if GlobalUI.menu == GlobalUI.Menus.CUTSCENE: return

	if mode == USE:
		if Globals.death_in_progress: return
		if GlobalInput.ignore_fire: return
		if not GlobalUI.menu == GlobalUI.Menus.NONE: return

		if Input.is_action_just_pressed("fire") and not can_fire() and not timer.time_left > 0:
			fail_fire()
			GlobalInput.start_low_vibration()

		if Input.is_action_pressed("fire"):
			if can_fire():
				fire()
				GlobalInput.start_normal_vibration()


func fire() -> void:
	if mode == USE:
		if equippable_name == "ice gun" and Globals.game_state == Globals.GameStates.LEVEL:
			reduce_adrenaline()
		elif Globals.game_state == Globals.GameStates.LEVEL:
			reduce_ammo()

	may_fire = false

	timer.start(GlobalStats.get_firerate(equippable_name))

	var inst = load(GlobalPaths.get_bullet(equippable_name)).instance()

	var bullet = inst.get_node("BulletBase")

	bullet.equippable_owner = equippable_name

	if mode == USE:
		bullet.player_bullet = true

	inst.global_position = position_2d.global_position

	get_node(GlobalPaths.LEVEL).add_child(inst)

	inst.global_rotation = get_parent().get_parent().global_rotation

	yield(get_tree(), "physics_frame")

	if get_parent().get_parent().scale.x > 0:
		bullet.apply_impulse(Vector2(), Vector2(bullet.speed, 0).rotated(get_parent().global_rotation))
	else:
		bullet.apply_impulse(Vector2(), Vector2(-bullet.speed, 0).rotated(-get_parent().global_rotation))

	get_node(GlobalPaths.PLAYER_CAMERA).set_trauma(0.25)


func fail_fire() -> void:
	var worker: String = GlobalStats.get_ammo()
	var inv: Array = GlobalSave.get_stat("collectables")

	if not GlobalSave.has_item(inv, worker):
		no_amo_sound.play()
		return


func _direction_changed(facing_right: bool) -> void:
	if not facing_right:
		scale.y = -1
#		if name == "Fernand":
#			position.x = -7
		scale.x = 1
	else:
		scale.y = 1
#		if name == "Fernand":
#			position.x = 7
		scale.x = 1


func reduce_ammo() -> void:
	var worker: String = GlobalStats.get_ammo()
	var inv: Array = GlobalSave.get_stat("collectables")
	if GlobalSave.has_item(inv, worker):
		for array in inv:
			if array[0] == worker:
				array[1] -= 1
				if array[1] == 0:
					var find = inv.find(array)
					inv.remove(find)
	GlobalEvents.emit_signal("save_stat_updated")


func reduce_adrenaline() -> void:
	GlobalSave.set_stat("adrenaline", GlobalSave.get_stat("adrenaline") - 1)


func can_fire() -> bool:
	if equippable_name == "ice gun":
		return may_fire and GlobalSave.get_stat("adrenaline") > 0
	else:
		return may_fire and GlobalSave.has_item(GlobalSave.get_stat("collectables"), GlobalStats.get_ammo())


func _body_entered(body: Node) -> void:
	if mode == COLLECT:
		if body.is_in_group("Player"):
			pickup_sound.play()
			collision_shape.set_deferred("disabled", true)
			animation_player.play("collected")
			GlobalEvents.emit_signal("player_collected_equippable", equippable_name)
			GlobalEvents.emit_signal("player_equipped", equippable_name)


func _timeout() -> void:
	may_fire = true


var right_used := true
var left_used := false


func _player_anim_sprite_direction_changed(_facing_right: bool) -> void:
	pass
#	if facing_right and not right_used:
#		get_parent().rotation_degrees = -get_parent().rotation_degrees + 180
#		right_used = true
#		left_used = false
#		printt("Facing right")
#		_direction_changed(facing_right)
#	elif not facing_right and not left_used:
#		left_used = true
#		right_used = false
#		get_parent().rotation_degrees = -get_parent().rotation_degrees + 180
#		printt("facing left")
#		_direction_changed(facing_right)

