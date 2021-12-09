extends Position2D


func _ready() -> void:
	var __: int = GlobalEvents.connect("player_used_powerup", self, "_player_used_powerup")


func _player_used_powerup(item_name) -> void:
	var scn: PackedScene = load(GlobalPaths.get_powerup(item_name))
	var inst: Node2D = scn.instance()
	inst.position = position
	inst.get_node("LevelPowerupBase").mode = inst.get_node("LevelPowerupBase").USE
	add_child(inst)
