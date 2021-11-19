extends Node2D

export var canvas_normal: PackedScene
export var canvas_subsection: PackedScene

enum {
	NORMAL
	SUB
}

var state: int = NORMAL
var swap_canvas: bool = true

onready var player_body: KinematicBody2D = get_node("Player/KinematicBody2D")
onready var level_components: Node2D = $LevelComponents

func _ready() -> void:
	var __: int
	__ = Signals.connect("sublevel_changed", self, "_sublevel_changed")
	var start_pos: Position2D = get_node_or_null("LevelComponents/PlayerStart")
	if LevelController.checkpoint_active:
		var checkpoint = get_node_or_null("LevelComponents/Checkpoint")
		if not checkpoint == null:
			$Player.global_position = Vector2(checkpoint.global_position.x, checkpoint.global_position.y - 10)
	elif not start_pos == null:
		$Player.global_position = start_pos.global_position


	if canvas_normal == null or canvas_subsection == null:
		swap_canvas = false
	if swap_canvas:
		for canvas in get_tree().get_nodes_in_group("CanvasBackground"):
			canvas.call_deferred("free")
		level_components.add_child(canvas_normal.instance())

		
	if LevelController.has_canvas():
		for canvas in get_tree().get_nodes_in_group("CanvasModulate"):
			canvas.show()
	else:
		for canvas in get_tree().get_nodes_in_group("CanvasModulate"):
			canvas.hide()


func _sublevel_changed(_pos: Vector2) -> void:
	if swap_canvas:
		yield(UI, "faded")
		for canvas in get_tree().get_nodes_in_group("CanvasBackground"):
			canvas.call_deferred("free")
		if Globals.in_subsection:
			level_components.add_child(canvas_subsection.instance())
		else:
			level_components.add_child(canvas_normal.instance())


		if LevelController.has_canvas():
			for canvas in get_tree().get_nodes_in_group("CanvasModulate"):
				canvas.show()
		else:
			for canvas in get_tree().get_nodes_in_group("CanvasModulate"):
				canvas.hide()