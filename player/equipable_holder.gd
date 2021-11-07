extends Position2D

var facing_right: bool = true

signal direction_changed(dir)

func _ready() -> void:
	Signals.connect("equipped", self, "_equipped")
	#get_parent().connect("direction_changed", self, "_direction_changed")
	if not PlayerStats.get_stat("equipped_item") == "none" and Globals.game_state == Globals.GameStates.LEVEL:
		_equipped(PlayerStats.get_stat("equipped_item"))

func _process(delta: float) -> void:

	if not Main.get_controller_right_axis() < Vector2(0.1, 0.1) or Main.get_controller_right_axis() < Vector2(-0.1, -0.1):
		rotation_degrees = rad2deg(atan2(-Main.get_controller_right_axis().y, Main.get_controller_right_axis().x))
		#print(rad2deg(atan2(-Main.get_controller_right_axis().y, Main.get_controller_right_axis().x)))
				
		update_direction()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
#			var speed = event.relative.y
#			speed /= 3000
#			rotation_degrees += speed * OS.window_size.y
#			rotation_degrees = clamp(rotation_degrees, -87, 87)
		look_at(get_global_mouse_position())
			#print(rotation_degrees)
		update_direction()


func update_direction() -> void:
	if rotation_degrees >= 180:
		rotation_degrees = -180
	elif rotation_degrees <= -180:
		rotation_degrees = 180

	if rotation_degrees > 90 or rotation_degrees < -90:
		emit_signal("direction_changed", false)
	else:
		emit_signal("direction_changed", true)
		

func _equipped(equipable: String) -> void:
	var scn: PackedScene = load(FileLocations.get_equipable(equipable))
	var inst: Node2D = scn.instance()
	var existing: Array = get_children()
	for n in existing:
		n.call_deferred("free")
	inst.get_node("EquipableBase").mode = inst.get_node("EquipableBase").USE
	add_child(inst)

