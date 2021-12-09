extends Node2D

var teleporter: Area2D

onready var tilemap_block: TileMap = $TileMapBlock
onready var right_position: Position2D = $LevelComponents/CameraPositions/BottomRight


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

	match int(GlobalSave.get_stat("world_max")):
		1:
			tilemap_block.position = Vector2(0, 0)
			right_position.position = Vector2(1896, 384)
		2:
			tilemap_block.position = Vector2(500, 0)
			right_position.position = Vector2(2560, 384)
