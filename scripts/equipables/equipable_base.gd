extends Area2D

export var equipable_name: String = "water gun"

onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var position_2d: Position2D = $Position2D

enum {
	COLLECT,
	USE
}

var mode: int = COLLECT
var firerate: int = 1
var may_fire: bool = true

var node2d: = Node2D.new()


func _ready() -> void:
	connect("body_entered", self, "_body_entered")
	if mode == USE:
		$Sprite.rotation_degrees = 0
		add_child(node2d)
	elif mode == COLLECT:
		rotation_degrees = 23.2


func get_bullet() -> String:
	return FileLocations.get_bullet(equipable_name)


func _input(event: InputEvent) -> void:
	if mode == USE:
		if event is InputEventMouseMotion:
			var speed = event.relative.y
			speed /= 3000
			rotation_degrees += speed * OS.window_size.y
			rotation_degrees = clamp(rotation_degrees, -85, 85)


func get_firerate() -> float:
	match PlayerStats.get_stat("equiped_item"):
		"nail gun":
			return 0.05
		"laser gun":
			return 0.3
		"water gun":
			return 0.2
	return 0.0


func get_ammo() -> String:
	match PlayerStats.get_stat("equiped_item"):
		"nail gun":
			return "nail"
		"laser gun":
			return "energy"
		"water gun":
			return "water"
	return ""


func reduce_ammo() -> void:
	var worker: String = get_ammo()
	var inv: Array = PlayerStats.get_stat("collectables")
	if has(inv, worker):
		for array in inv:
			if array[0] == worker:
				array[1] -= 1
				if array[1] == 0:
					var find = inv.find(array)
					inv.remove(find)


func _physics_process(delta: float) -> void:
	if mode == USE:
		if Input.is_action_pressed("fire"):
			if can_fire():
				reduce_ammo()
				may_fire = false
				$Timer.start(get_firerate())
				var inst = load(get_bullet()).instance()
				inst.global_position = position_2d.global_position
				get_node(Globals.level_path).add_child(inst)
				inst.global_rotation = global_rotation
				if get_parent().get_parent().scale.x == 1:
					inst.get_node("BulletBase").apply_impulse(Vector2(), Vector2(inst.get_node("BulletBase").speed, 0).rotated(rotation))
				else:
					inst.get_node("BulletBase").apply_impulse(Vector2(), Vector2(-inst.get_node("BulletBase").speed, 0).rotated(-rotation))
				get_node(Globals.player_camera_path).set_trauma(0.25)
		if Input.is_action_just_pressed("fire") and not can_fire():
			$NoAmo.play()


func has(array: Array, value: String) -> bool:
	for n in array:
		if n[0] == value:
			return true
	return false


func can_fire() -> bool:
	return may_fire and has(PlayerStats.get_stat("collectables"), get_ammo())


func _process(delta: float) -> void:
	if mode == USE:
		if Input.is_action_pressed("ctr_look_up"):
			var speed = 500
			speed *= Input.get_action_strength("ctr_look_up")
			rotation_degrees -= speed * delta
			rotation_degrees = clamp(rotation_degrees, -85, 85)
		if Input.is_action_pressed("ctr_look_down"):
			var speed = 500
			speed *= Input.get_action_strength("ctr_look_down")
			rotation_degrees += speed * delta
			rotation_degrees = clamp(rotation_degrees, -85, 85)


func _body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		if mode == COLLECT:
			$Sound.play()
			$CollisionShape2D.set_deferred("disabled", true)
			animation_player.play("collected")
			Signals.emit_signal("equipable_collected", equipable_name)



func _timeout() -> void:
	may_fire = true
