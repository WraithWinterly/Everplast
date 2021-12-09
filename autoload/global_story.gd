extends Node


func _ready() -> void:
	var __: int
	__ = GlobalEvents.connect("story_w1_boss_killed", self, "_story_w1_boss_killed")
	__ = GlobalEvents.connect("story_w1_boss_level_end_completed", self, "_story_w1_boss_level_end_completed")


func _story_w1_boss_killed() -> void:
	GlobalUI.menu = GlobalUI.Menus.CUTSCENE
	yield(GlobalEvents, "ui_dialogue_hidden")

	GlobalUI.menu_locked = true

	get_tree().paused = true
#
	var rank_pickup = load(GlobalPaths.RANK_PICKUP).instance()

	rank_pickup.rank = GlobalStats.Ranks.GOLD

	get_node(GlobalPaths.LEVEL).add_child(rank_pickup)

	rank_pickup.global_position = get_node(GlobalPaths.LEVEL + "/LevelComponents/CameraPositions/RankPickup").global_position

#func _story_w1_boss_camera_animated() -> void:
#	GlobalLevel.in_boss = false
#	get_tree().paused = false

func _story_w1_boss_level_end_completed() -> void:
	print("LEVEL END COMPELTE ANIM")

	yield(GlobalEvents, "ui_faded")
	GlobalUI.menu = GlobalUI.Menus.NONE
	GlobalLevel.in_boss = false
	get_tree().paused = false
	get_node(GlobalPaths.PLAYER_CAMERA).current = true
	GlobalUI.menu_locked = false
