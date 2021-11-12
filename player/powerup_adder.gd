extends Position2D


func _ready() -> void:
	var __: int = Signals.connect("powerup_used", self, "_powerup_used")


func _powerup_used(item_name) -> void:
	var scn: PackedScene = load(FileLocations.get_powerup(item_name))
	var inst: Node2D = scn.instance()
	inst.position = position
	inst.get_node("LevelPowerupBase").mode = inst.get_node("LevelPowerupBase").USE
	add_child(inst)
