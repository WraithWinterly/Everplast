extends Position2D

onready var player: KinematicBody2D = get_node(GlobalPaths.PLAYER)

var STEP: float = 0.19921875


func _process(_delta: float) -> void:
	smoothing()

	if GlobalUI.fade_player_playing:
		global_position = player.global_position


func smoothing() -> void:
	global_position = lerp(global_position, Vector2(stepify(player.global_position.x, STEP), stepify(player.global_position.y, STEP)), 0.2)
