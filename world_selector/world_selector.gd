extends Node2D

var teleporter: Area2D


func _ready() -> void:
	var teleporters: Node2D = $Teleporters
	teleporter = null
	for n in teleporters.get_children():
		if n.world == PlayerStats.get_stat("world_last") \
				and n.level == PlayerStats.get_stat("level_last"):
			teleporter = n
	if not teleporter == null:
		get_node("Player").get_node("KinematicBody2D").global_position = \
				Vector2(teleporter.global_position.x, teleporter.global_position.y - 10)


