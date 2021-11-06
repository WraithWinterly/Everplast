extends Node2D

enum {
	NORMAL
	SUB
}

var state: int = NORMAL

onready var player_body: KinematicBody2D = get_node("Player/KinematicBody2D")


func _ready() -> void:
	var start_pos: Position2D = get_node_or_null("PlayerStart")
	if LevelController.checkpoint_active:
		var checkpoint = get_node_or_null("Checkpoint")
		if not checkpoint == null:
			$Player.global_position = Vector2(checkpoint.global_position.x, checkpoint.global_position.y - 10)
	elif not start_pos == null:
		$Player.global_position = start_pos.global_position



