extends Area2D

enum {
	COLLECT,
	USE
}

export var equipable_name: String = "water gun"

var mode: int = COLLECT
var firerate: int = 1
var may_fire: bool = true


onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var position_2d: Position2D = $Position2D
onready var pickup_sound: AudioStreamPlayer = $Sound
onready var collision_shape: CollisionShape2D = $CollisionShape2D
onready var no_amo_sound: AudioStreamPlayer = $NoAmo
onready var timer: Timer = $Timer


func _ready() -> void:
	connect("body_entered", self, "_body_entered")
	if get_parent() is Node2D:
		get_parent().get_parent().connect("direction_changed", self, "_direction_changed")
	
	if mode == USE:
		$Sprite.rotation_degrees = 0
	elif mode == COLLECT:
		rotation_degrees = 23.2


func _physics_process(delta: float) -> void:
	if mode == USE:
		if Input.is_action_just_pressed("fire") and not can_fire():
			no_amo_sound.play()
			return
		if Input.is_action_pressed("fire"):
			if can_fire():
				reduce_ammo()
				may_fire = false
				timer.start(get_firerate())
				var inst = load(get_bullet()).instance()
				inst.global_position = position_2d.global_position
				get_node(Globals.level_path).add_child(inst)
				inst.global_rotation = get_parent().global_rotation
				if get_parent().get_parent().scale.x > 0:
					inst.get_node("BulletBase").apply_impulse(Vector2(), Vector2(inst.get_node("BulletBase").speed, 0).rotated(get_parent().global_rotation))
				else:
					inst.get_node("BulletBase").apply_impulse(Vector2(), Vector2(-inst.get_node("BulletBase").speed, 0).rotated(-get_parent().global_rotation))
				get_node(Globals.player_camera_path).set_trauma(0.25)


func _direction_changed(facing_right: bool) -> void:
	if not facing_right:
		scale.y = -1
		scale.x = 1
	else:
		scale.y = 1
		scale.x = 1


func get_bullet() -> String:
	return FileLocations.get_bullet(equipable_name)


func get_firerate() -> float:
	match PlayerStats.get_stat("equipped_item"):
		"nail gun":
			return 0.05
		"laser gun":
			return 0.3
		"water gun":
			return 0.2
	return 0.0


func reduce_ammo() -> void:
	var worker: String = PlayerStats.get_ammo()
	var inv: Array = PlayerStats.get_stat("collectables")
	if PlayerStats.has(inv, worker):
		for array in inv:
			if array[0] == worker:
				array[1] -= 1
				if array[1] == 0:
					var find = inv.find(array)
					inv.remove(find)
	PlayerStats.emit_signal("stat_updated")


func can_fire() -> bool:
	return may_fire and PlayerStats.has(PlayerStats.get_stat("collectables"), PlayerStats.get_ammo())


func _body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		if mode == COLLECT:
			pickup_sound.play()
			collision_shape.set_deferred("disabled", true)
			animation_player.play("collected")
			Signals.emit_signal("equipable_collected", equipable_name)


func _timeout() -> void:
	may_fire = true
