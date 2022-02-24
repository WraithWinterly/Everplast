extends Position2D


var facing_right: bool = true
var using_mouse: bool = true

onready var equip_holder: Position2D = get_parent().get_node("EquippableHolder")


func _ready() -> void:
	var __: int
	__ = GlobalEvents.connect("player_equipped", self, "_player_equipped")
	if not GlobalSave.get_stat("equipped_item") == "none" and not Globals.game_state == Globals.GameStates.MENU:
		_player_equipped(GlobalSave.get_stat("equipped_item"))


func _process(_delta: float) -> void:
	if GlobalUI.menu == GlobalUI.Menus.CUTSCENE: return
	if not GlobalUI.menu == GlobalUI.Menus.NONE: return
	if Input.is_action_pressed("ctr_look_up") or Input.is_action_pressed("ctr_look_down") or Input.is_action_pressed("ctr_look_left") or Input.is_action_pressed("ctr_look_right"):
		rotation_degrees = rad2deg(atan2(-GlobalInput.get_controller_right_axis().y, GlobalInput.get_controller_right_axis().x))
		rotation_degrees = rad2deg(atan2(-GlobalInput.get_controller_right_axis().y, GlobalInput.get_controller_right_axis().x))
		update_direction()

	equip_holder.global_rotation = lerp_angle(equip_holder.global_rotation, global_rotation, 30 * get_physics_process_delta_time())


func _input(event: InputEvent) -> void:
	if GlobalUI.menu == GlobalUI.Menus.CUTSCENE: return
	if event is InputEventMouseMotion:
		look_at(get_global_mouse_position())
		update_direction()


func update_direction() -> void:
	if rotation_degrees >= 180:
		rotation_degrees = -180
	elif rotation_degrees <= -180:
		rotation_degrees = 180

	if rotation_degrees > 90 or rotation_degrees < -90:
		equip_holder.emit_signal("direction_changed", false)
	else:
		equip_holder.emit_signal("direction_changed", true)


func _player_equipped(equippable: String) -> void:
	var existing: Array = equip_holder.get_children()

	for n in existing:
		n.call_deferred("free")
	if not equippable == "none":
		if GlobalSave.get_stat("equipped_item") == "":
			return
		var scn: PackedScene = load(GlobalPaths.get_equippable(equippable))
		var inst: Node2D = scn.instance()
		inst.get_node("EquippableBase").mode = inst.get_node("EquippableBase").USE

		equip_holder.call_deferred("add_child", inst)
		yield(get_tree(), "idle_frame")
		yield(get_tree(), "idle_frame")
		look_at(get_global_mouse_position())
		update_direction()
