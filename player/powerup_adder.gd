extends Position2D


func _ready() -> void:
	Signals.connect("quick_item_used", self, "_quick_item_used")


func _quick_item_used(item_name) -> void:
	var scn: PackedScene = load(FileLocations.get_powerup(item_name))
	var inst: Node2D = scn.instance()
	inst.position = position
	inst.get_node("LevelPowerupBase").mode = inst.get_node("LevelPowerupBase").USE
	add_child(inst)
