extends Label


func _ready() -> void:
	hide()


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("debug"):
		if visible:
			hide()
		else:
			show()
			update_text()


func update_text() -> void:
	text = "FPS: %s\n" % Engine.get_frames_per_second()
	text += "%s\n" % Globals.version_string

	text += "\n"
	text += "Current Menu: %s\n" % GlobalUI.Menus.keys()[GlobalUI.menu]
	text += "Menu Locked: %s\n" % GlobalUI.menu_locked
	text += "Game State: %s\n" % Globals.GameStates.keys()[Globals.game_state]
	text += "Profile Selector Index Focus: %s\n" % GlobalUI.profile_index_focus
	text += "Profile Selector Index: %s\n" % GlobalUI.profile_index
	text += "Current Profile: %s\n" % GlobalSave.profile
	text += "Current World: %s\n" % GlobalLevel.current_world
	text += "Current Level: %s\n" % GlobalLevel.current_level
	text += "Checkpoint Active: %s\n" % GlobalLevel.checkpoint_active
	text += "Checkpoint World: %s\n" % GlobalLevel.checkpoint_world
	text += "Checkpoint Level: %s\n" % GlobalLevel.checkpoint_level
	text += "Quick Play Profile: %s\n" % GlobalQuickPlay.data["last_profile"]
	text += "\n"

	if not Globals.game_state == Globals.GameStates.MENU:
		text += "Max World: %s\n" % GlobalSave.get_stat("world_max")
		text += "Max Level: %s\n" % GlobalSave.get_stat("level_max")
		text += "Last World: %s\n" % GlobalSave.get_stat("world_last")
		text += "Last Level: %s\n" % GlobalSave.get_stat("level_last")
		text += "In Subsection: %s\n" % GlobalLevel.in_subsection
		text += "Current Rank: %s\n" % GlobalSave.get_stat("rank")

		text += "Last Powerup: %s\n" % GlobalStats.last_powerup
		text += "Last Equippable: %s\n" % get_node("/root/Main/GUI/Control/Inventory").last_equippable

	text += "\n"

	var player: Node2D = get_node_or_null(GlobalPaths.PLAYER)
	if not player == null:
		text += "Player: %s\n" % str(player.fsm.current_state.name)
		text += "Player Falling: %s\n" % str(player.falling)
		text += "Player Position: %s\n" % str(player.global_position)
		text += "Player Sprinting: %s\n" % str(player.sprinting)
		text += "Player Second Jump Used: %s\n" % player.second_jump_used
		text += "Player Facing Right: %s\n" % player.facing_right
		text += "Player Velocity: %s\n" % player.linear_velocity
		text += "\n"

	yield(get_tree(), "idle_frame")
	if visible:
		update_text()
