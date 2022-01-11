extends Node2D

var teleporter: Area2D

onready var tilemap_block: TileMap = $TileMapBlock
onready var right_position: Position2D = $LevelComponents/CameraPositions/BottomRight

onready var max_positions := [$World1Max, $World2Max, $World3Max, $World4Max]


func _ready() -> void:
	var teleporters: Node2D = $Teleporters

	teleporter = null

	for n in teleporters.get_children():
		if n.world == GlobalSave.get_stat("world_last") \
				and n.level == GlobalSave.get_stat("level_last"):
			teleporter = n

	if not teleporter == null:
		get_node("Player").get_node("KinematicBody2D").global_position = \
				Vector2(teleporter.global_position.x, teleporter.global_position.y - 8)

	tilemap_block.position.x = max_positions[GlobalSave.get_stat("world_max") - 1].position.x
	tilemap_block.position.y = max_positions[GlobalSave.get_stat("world_max") - 1].position.y + 48
	right_position.position.x = max_positions[GlobalSave.get_stat("world_max") - 1].position.x
	right_position.position.y = 384


	var canvases := get_tree().get_nodes_in_group("CanvasModulate")

	for canvas in canvases:
		canvas.set_deferred("visible", true)
