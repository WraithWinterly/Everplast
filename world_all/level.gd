extends Node2D

export var canvas_normal: PackedScene
export var canvas_subsection: PackedScene

export var windy_level: bool = false

enum {
	NORMAL
	SUB
}

var state: int = NORMAL

var swap_canvas := true

onready var player_body: KinematicBody2D = get_node("Player/KinematicBody2D")
onready var level_components: Node2D = $LevelComponents


func _ready() -> void:
	var __: int
	__ = GlobalEvents.connect("level_subsection_changed", self, "_level_subsection_changed")
	__ = GlobalEvents.connect("story_w3_attempt_beat", self, "_story_w3_attempt_beat")

	if canvas_normal == null or canvas_subsection == null:
		swap_canvas = false

	if swap_canvas:
		for canvas in get_tree().get_nodes_in_group("CanvasBackground"):
			canvas.call_deferred("free")
		level_components.add_child(canvas_normal.instance())


	var start_pos: Position2D = get_node_or_null("LevelComponents/PlayerStart")

	if GlobalLevel.checkpoint_active:
		var checkpoint: Node
		if not GlobalLevel.checkpoint_index > 0:
			checkpoint = get_node_or_null("LevelComponents/Checkpoint")
		else:
			checkpoint = get_node_or_null("LevelComponents/Checkpoint%s" % GlobalLevel.checkpoint_index)
		if not checkpoint == null:
			if GlobalLevel.checkpoint_in_sub:
				#yield(GlobalEvents, "ui_faded")
				GlobalLevel.in_subsection = true
				$Player/KinematicBody2D.global_position = Vector2(checkpoint.global_position.x, checkpoint.global_position.y - 7)

				#GlobalEvents.emit_signal("level_subsection_changed", $SubsectionTeleporters/StartSubsection.global_position)
				#yield(GlobalEvents, "ui_faded")
				#yield(get_tree(), "physics_frame")
				#yield(get_tree(), "physics_frame")
			else:
				$Player/KinematicBody2D.global_position = Vector2(checkpoint.global_position.x, checkpoint.global_position.y - 7)
	elif not start_pos == null:
		$Player.global_position = start_pos.global_position

	if GlobalLevel.checkpoint_in_sub:
		swap_canvases()

	update_canvas()

func _level_subsection_changed(_pos: Vector2) -> void:
	if swap_canvas:
		yield(GlobalEvents, "ui_faded")
		swap_canvases()
		update_canvas()

func swap_canvases() -> void:
	var canvases = get_tree().get_nodes_in_group("CanvasBackground")

	for canvas in canvases:
		canvas.call_deferred("free")
	if GlobalLevel.in_subsection:
		level_components.add_child(canvas_subsection.instance())
	else:
		level_components.add_child(canvas_normal.instance())


func update_canvas() -> void:
	var canvases := get_tree().get_nodes_in_group("CanvasModulate")

	if GlobalLevel.has_canvas():
		for canvas in canvases:
			canvas.set_deferred("visible", true)
	else:
		for canvas in canvases:
			canvas.set_deferred("visible", false)


func _story_w3_attempt_beat() -> void:
	print("putting in cutscene - story w3 beat")
	GlobalUI.menu = GlobalUI.Menus.CUTSCENE
	yield(GlobalEvents, "ui_faded")
	#print("putting in cutscene - story w3 beat 2")
	var fernand = load("res://mobs/fernand/fernand.tscn").instance()
	fernand.is_end_version = true
	get_tree().call_group("Cannon", "enable")
	GlobalUI.menu = GlobalUI.Menus.CUTSCENE
	add_child(fernand, true)
	yield(GlobalEvents, "ui_faded")
	#print("putting in cutscene - story w3 beat 3")
	$BossComplete.current = true
	$BossComplete/AnimationPlayer.play("fernand")
	while $BossComplete/AnimationPlayer.is_playing():
		$Fernand.global_position.x = lerp($Fernand.global_position.x, $LevelComponents/Fernand.global_position.x, 0.3)
		$Fernand.global_position.y = lerp($Fernand.global_position.y, $LevelComponents/Fernand.global_position.y, 0.3)
		yield(get_tree(), "physics_frame")
	#yield($BossComplete/AnimationPlayer, "animation_finished")
	GlobalEvents.emit_signal("story_w3_fernand_anim_finished")
	GlobalUI.menu = GlobalUI.Menus.NONE
	GlobalLevel.in_boss = true
	$BossComplete.current = false


func upgrade_fernand() -> void:
	$Fernand.upgrade()
