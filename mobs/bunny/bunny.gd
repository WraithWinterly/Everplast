extends KinematicBody2D


onready var enemy_component: Node2D = $MobComponentManager


func _ready() -> void:
	var __: int
	__ = enemy_component.connect("died", self, "_died")


func _died() -> void:
	var egg_loader: PackedScene = load(GlobalPaths.get_powerup("bunny egg"))
	var egg_instance: Node2D = egg_loader.instance()
	var level: Node2D = get_node(GlobalPaths.LEVEL)

	egg_instance.global_position = Vector2(global_position.x + 2, global_position.y- 10)
	level.call_deferred("add_child", egg_instance)
