extends Position2D


func _ready() -> void:
	Signals.connect("equipped", self, "_equipped")
	get_parent().connect("direction_changed", self, "_direction_changed")
	if not PlayerStats.get_stat("equipped_item") == "none" and Globals.game_state == Globals.GameStates.LEVEL:
		_equipped(PlayerStats.get_stat("equipped_item"))


func _equipped(equipable: String) -> void:
	var scn: PackedScene = load(FileLocations.get_equipable(equipable))
	var inst: Node2D = scn.instance()
	var existing: Array = get_children()
	for n in existing:
		n.call_deferred("free")
	inst.get_node("EquipableBase").mode = inst.get_node("EquipableBase").USE
	add_child(inst)


func _direction_changed(facing_right: bool) -> void:
	if facing_right:
		scale.x = -1
		position.x = 0
	else:
		scale.x = 1
		position.x = 11
