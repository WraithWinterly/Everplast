extends Position2D


func _ready() -> void:
	Signals.connect("equipped", self, "_equipped")
	#get_parent().connect("direction_changed", self, "_direction_changed")
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
	inst.get_node("EquipableBase").connect("direction_changed", self, "_direction_changed")


func _direction_changed(facing_right: bool) -> void:
	print("sdj fa kfljj kld")
	if not facing_right:
		scale.x = -0.8
		position.x = 5
	else:
		scale.x = 0.8
		position.x = 6
