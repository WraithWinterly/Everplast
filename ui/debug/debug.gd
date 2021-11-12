extends Label

func _ready() -> void:
	hide()


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("debug"):
		if visible:
			hide()
		else:
			show()
			update()


func update() -> void:
	text = "FPS: %s\n" % Engine.get_frames_per_second()
	text += "%s\n" % Globals.get_main().version
	text += "Current Menu: %s\n" % UI.current_menu
	text += "Last Menu: %s\n" % UI.last_menu
	text += "UI Index: %s\n" % UI.profile_index
	text += "UI Focus: %s\n" % UI.profile_index_focus
	text += "Current Profile: %s\n" % PlayerStats.current_save_profile
	text += "Game States: %s\n" % Globals.GameStates
	text += "Game State: %s\n" % Globals.game_state
	text += "Menu Transitioning: %s\n" % UI.menu_transitioning
	text += "Checkpoint Active: %s\n" % LevelController.checkpoint_active
	text += "Checkpoint World: %s\n" % LevelController.checkpoint_world
	text += "Checkpoint Level: %s\n" % LevelController.checkpoint_level
	text += "Current World: %s\n" % LevelController.current_world
	text += "Current Level: %s\n" % LevelController.current_level
	text += "Quick Play: %s\n" % QuickPlay.data
	if not Globals.game_state == Globals.GameStates.MENU:
		text += "Max World: %s\n" % PlayerStats.get_stat("world_max")
		text += "Max Level: %s\n" % PlayerStats.get_stat("level_max")
		text += "Last World: %s\n" % PlayerStats.get_stat("world_last")
		text += "Last Level: %s\n" % PlayerStats.get_stat("level_last")
		text += "Current Rank: %s\n" % PlayerStats.get_stat("rank")
		text += "Dialog Active: %s\n" % Globals.dialog_active
		text += "Inventory Active: %s\n" % Globals.inventory_active
	var player: Player = get_node_or_null(Globals.player_path)
	if not player == null:
		text += "Player: %s\n" % str(player.fsm.current_state.name)
		text += "Player Position: %s\n" % str(player.kinematic_body.position)
		text += "Player Sprinting: %s\n" % str(player.sprinting)
		var player_body: KinematicBody2D = get_node(Globals.player_body_path)
		text += "Player Second Jump Used: %s\n" % player_body.second_jump_used
		text += "Player Facing Right: %s\n" % player.facing_right
		text += "Player Velocity: %s\n" % player_body.linear_velocity
		text += "\n"
	yield(get_tree(), "idle_frame")
	if visible:
		update()
