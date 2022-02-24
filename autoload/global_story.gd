extends Node

func _ready() -> void:
	var __: int
	__ = GlobalEvents.connect("story_boss_killed", self, "_story_boss_killed")
	__ = GlobalEvents.connect("story_boss_level_end_completed", self, "_story_boss_level_end_completed")
	__ = GlobalEvents.connect("story_w3_attempt_beat", self, "_story_w3_attempt_beat")


func _story_boss_killed(idx: int) -> void:
	GlobalUI.menu = GlobalUI.Menus.CUTSCENE
	#print("putting in cutscene - story boss killed")
	yield(GlobalEvents, "ui_dialogue_hidden")

	GlobalUI.menu_locked = true

	get_tree().paused = true
#
	if int(GlobalSave.get_stat("world_max")) < 3:
		var rank_pickup = load(GlobalPaths.RANK_PICKUP).instance()

		if idx == GlobalStats.Bosses.FERNAND:
			rank_pickup.rank = GlobalStats.Ranks.GOLD
		elif idx == GlobalStats.Bosses.OSTRICH:
			rank_pickup.rank = GlobalStats.Ranks.DIAMOND

		get_node(GlobalPaths.LEVEL).add_child(rank_pickup)
		rank_pickup.global_position = get_node(GlobalPaths.LEVEL + "/LevelComponents/RankPickup").global_position


func _story_boss_level_end_completed(_idx: int) -> void:
	yield(GlobalEvents, "ui_faded")
	GlobalUI.menu = GlobalUI.Menus.NONE
	GlobalLevel.in_boss = false
	get_tree().paused = false
	get_node(GlobalPaths.PLAYER_CAMERA).current = true
	GlobalUI.menu_locked = false


func _story_w3_attempt_beat() -> void:
	GlobalEvents.emit_signal("ui_dialogued", tr("fernand.reentry_1"), "Fernand")
	GlobalEvents.emit_signal("ui_dialogued", tr("fernand_reentry_2"), "Fernand")
