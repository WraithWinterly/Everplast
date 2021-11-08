extends KinematicBody2D


onready var enemy_component: Node2D = $EnemyComponentManager


func _ready() -> void:
	enemy_component.connect("died", self, "_died")


func _died() -> void:
	var egg_loader: PackedScene = load(FileLocations.get_powerup("bunny egg"))
	var egg_instance: Node2D = egg_loader.instance()
	var level: Node2D = get_node(Globals.level_path)

	egg_instance.global_position = Vector2(global_position.x + 2, global_position.y- 10)
	level.call_deferred("add_child", egg_instance)
