extends Control

#                                                              #
# !!! UPDATE _powerup_pressed WHEN ADDING NEW FILLER ITEMS !!! #
#                                                              #

#                                                                     #
# !!! WHEN ADDING BUTTONS CONNECT mouse_entered AND focus_entered !!! #
#                                                                     #

var powerups_buttons_top_focus: Button
var powerups_buttons_bottom_focus: Button
var equippables_buttons_top_focus: Button
var equippables_buttons_bottom_focus: Button


var last_equippable: String

onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var upper_buttons: HBoxContainer = $Panel/HBoxContainer
onready var button_close: Button = $Panel/HBoxContainer/CloseButton
onready var top_collectables_button: Button = $Panel/HBoxContainer/CollectablesButton
onready var top_powerup_button: Button = $Panel/HBoxContainer/PowerupsButton
onready var top_rank_button: Button = $Panel/HBoxContainer/RanksButton
onready var top_stats_button: Button = $Panel/HBoxContainer/StatsButton

onready var powerup_sound: AudioStreamPlayer = $PowerupSound
onready var powerups_panel: Panel = $Panel/Powerups
onready var powerups_anim_player: AnimationPlayer = $Panel/Powerups/AnimationPlayer
onready var powerups_buttons: VBoxContainer = $Panel/Powerups/BG/HBoxContainer/Buttons
onready var powerups_explanation_label: Label = $Panel/Powerups/Explanation/Label
onready var not_in_level_warning: Label = $Panel/Powerups/NotInLevelWarning
onready var fill_button: CheckBox = $Panel/Powerups/Fill

onready var collectables_panel: Panel = $Panel/Collectables
onready var collectables_panel_anim_player: AnimationPlayer = $Panel/Collectables/AnimationPlayer
onready var collectables_buttons: VBoxContainer = $Panel/Collectables/Collectables/Buttons
onready var equippables_buttons: VBoxContainer = $Panel/Collectables/Equippables/Buttons

onready var ranks_panel: Panel = $Panel/Ranks
onready var ranks_anim_player: AnimationPlayer = $Panel/Ranks/AnimationPlayer
onready var ranks_container: VBoxContainer = $Panel/Ranks/CurrentRank/VBoxContainer
onready var rank_explanation_label: Label = $Panel/Ranks/CurrentRank/Stats
onready var rank_title_label: Label = $Panel/Ranks/CurrentRank/Title

onready var stats_panel: Panel = $Panel/Stats
onready var stats_anim_player: AnimationPlayer = $Panel/Stats/AnimationPlayer
onready var stats_upgrade_button: Button = $Panel/Stats/StatsUpgrade/UpgradeButton
onready var stats_label: Label = $Panel/Stats/PlayerStats/Info
onready var stats_label_level: Label = $Panel/Stats/PlayerStats/Level
onready var stats_label_orbs: Label = $Panel/Stats/PlayerStats/TotalOrbs
onready var stats_label_gems: Label = $Panel/Stats/PlayerStats/TotalGems
onready var stats_label_time: Label = $Panel/Stats/PlayerStats/TotalTime
onready var world_icons: VBoxContainer = $Panel/Stats/PlayerStats/WorldIcons
onready var upgrade_stats_health_button: Button = $Panel/Stats/UpgradeStatsPrompt/Panel/VBoxContainer/HBoxContainer/Health
onready var upgrade_stats_adrenaline_button: Button = $Panel/Stats/UpgradeStatsPrompt/Panel/VBoxContainer/HBoxContainer/Adrenaline
onready var upgrade_stats_cancel_button: Button = $Panel/Stats/UpgradeStatsPrompt/Panel/VBoxContainer/HBoxContainer/Cancel
onready var upgrade_stats_anim_player: AnimationPlayer = $Panel/Stats/UpgradeStatsPrompt/AnimationPlayer
onready var upgrade_stats_prompt_text: Label = $Panel/Stats/UpgradeStatsPrompt/Panel/VBoxContainer/PromptText
onready var upgrade_stats_info_label: Label = $Panel/Stats/StatsUpgrade/Info
onready var upgrade_sound: AudioStreamPlayer = $Panel/Stats/UpgradeStatsPrompt/UpgradeSound

onready var current_panel: Panel = powerups_panel


func _ready() -> void:
	var __: int
	__ = GlobalEvents.connect("level_changed", self, "_level_changed")
	__ = GlobalEvents.connect("level_completed", self, "_level_completed")
	__ = GlobalEvents.connect("player_collected_powerup", self, "_player_collected_powerup")
	__ = GlobalEvents.connect("player_collected_equippable", self, "_player_collected_equippable")
	__ = GlobalEvents.connect("player_collected_collectable", self, "_player_collected_collectable")
	__ = GlobalEvents.connect("player_used_powerup", self, "_player_used_powerup")
	__ = GlobalEvents.connect("ui_settings_updated", self, "_ui_settings_updated")
	__ = button_close.connect("pressed", self, "_close_pressed")
	__ = top_powerup_button.connect("pressed", self, "_powerups_pressed")
	__ = top_collectables_button.connect("pressed", self, "_collectables_pressed")
	__ = top_rank_button.connect("pressed", self, "_ranks_pressed")
	__ = top_stats_button.connect("pressed", self, "_stats_pressed")
	__ = stats_upgrade_button.connect("pressed", self, "_upgrade_stats_pressed")
	__ = upgrade_stats_cancel_button.connect("pressed", self, "_upgrade_stats_cancel_pressed")
	__ = upgrade_stats_health_button.connect("pressed", self, "_upgrade_stats_health_pressed")
	__ = upgrade_stats_adrenaline_button.connect("pressed", self, "_upgrade_stats_adrenaline_pressed")

	for button in $Panel/HBoxContainer.get_children():
		__ = button.connect("focus_entered", self, "_button_hovered")
		__ = button.connect("mouse_entered", self, "_button_hovered")

	for button in $Panel/Powerups/BG/HBoxContainer/Buttons.get_children():
		__ = button.connect("focus_entered", self, "_button_hovered")
		__ = button.connect("mouse_entered", self, "_button_hovered")

	for button in $Panel/Collectables/Equippables/Buttons.get_children():
		__ = button.connect("focus_entered", self, "_button_hovered")
		__ = button.connect("mouse_entered", self, "_button_hovered")

	for button in $Panel/Stats/UpgradeStatsPrompt/Panel/VBoxContainer/HBoxContainer.get_children():
		__ = button.connect("focus_entered", self, "_button_hovered")
		__ = button.connect("mouse_entered", self, "_button_hovered")

	__ = stats_upgrade_button.connect("focus_entered", self, "_button_hovered")
	__ = stats_upgrade_button.connect("mouse_entered", self, "_button_hovered")
	__ = fill_button.connect("focus_entered", self, "_button_hovered")
	__ = fill_button.connect("mouse_entered", self, "_button_hovered")

	hide()
	collectables_panel.hide()
	ranks_panel.hide()
	stats_panel.hide()

	for button in powerups_buttons.get_children():
		button.hide()
	for button in equippables_buttons.get_children():
		button.hide()
	for button in collectables_buttons.get_children():
		button.hide()


func _physics_process(_delta: float) -> void:
	if GlobalUI.menu == GlobalUI.Menus.INVENTORY:
		stats_label_time.text = GlobalSave.get_timeplay_string()


func _input(event: InputEvent) -> void:
	if Globals.game_state == Globals.GameStates.MENU: return
	if GlobalUI.menu == GlobalUI.Menus.DIALOGUE: return
	if GlobalUI.menu == GlobalUI.Menus.CUTSCENE: return
	if get_tree().paused and not GlobalUI.menu == GlobalUI.Menus.INVENTORY: return
	if Globals.death_in_progress: return

	#yield(get_tree(), "idle_frame")
	print("TRY FYUCKING INVENRT")
	if event.is_action_pressed("equip"):
		if not Globals.game_state == Globals.GameStates.LEVEL:
			return

		if GlobalUI.menu_locked or GlobalUI.fade_player_playing: return

		if GlobalSave.get_stat("equipped_item") == "none":
			if last_equippable == "none": return

			GlobalEvents.emit_signal("player_equipped", last_equippable)
			play_powerup_sound()
		else:
			last_equippable = GlobalSave.get_stat("equipped_item")
			GlobalEvents.emit_signal("player_equipped", "none")
			play_powerup_sound(true)

	elif event.is_action_pressed("powerup"):
		try_use_powerup(GlobalStats.last_powerup)

	elif not GlobalUI.menu_locked and not GlobalUI.fade_player_playing:
		if event.is_action_pressed("inventory"):
			if GlobalUI.menu == GlobalUI.Menus.INVENTORY:
				hide_menu()
				GlobalEvents.emit_signal("ui_button_pressed", true)
				GlobalEvents.emit_signal("ui_inventory_closed")
				GlobalUI.menu = GlobalUI.Menus.NONE
				get_tree().set_input_as_handled()
			elif GlobalUI.menu == GlobalUI.Menus.NONE:

				if not GlobalUI.menu == GlobalUI.Menus.PAUSE_MENU:
					GlobalUI.menu = GlobalUI.Menus.INVENTORY
					GlobalUI.menu_locked = true
					GlobalEvents.emit_signal("ui_inventory_opened")
					GlobalEvents.emit_signal("ui_button_pressed")
					if not GlobalUI.menu == GlobalUI.Menus.INVENTORY: return
					show_menu()
					get_tree().set_input_as_handled()
		elif event.is_action_pressed("ui_cancel"):
			if GlobalUI.menu == GlobalUI.Menus.INVENTORY:
				hide_menu()
				GlobalEvents.emit_signal("ui_button_pressed")
				GlobalEvents.emit_signal("ui_inventory_closed")
				GlobalUI.menu = GlobalUI.Menus.NONE
				get_tree().set_input_as_handled()
			elif GlobalUI.menu == GlobalUI.Menus.INVENTORY_UPGRADE_PROMPT:
				_upgrade_stats_cancel_pressed()
				GlobalUI.menu = GlobalUI.Menus.INVENTORY
				get_tree().set_input_as_handled()


func show_menu() -> void:
	if not GlobalUI.menu == GlobalUI.Menus.INVENTORY: return
	enable_buttons()
	current_panel = powerups_panel
	current_panel.get_node("AnimationPlayer").play("slide")
	powerups_anim_player.play_backwards("slide")
	powerups_panel.show()
	collectables_panel.hide()
	ranks_panel.hide()
	stats_panel.hide()
	enable_buttons()
	show()
	update_inventory()
	update_button_focus(powerups_buttons_top_focus)
	get_tree().paused = true
	animation_player.play("show")

	top_powerup_button.grab_focus()
	GlobalUI.menu_locked = false


func hide_menu() -> void:
	GlobalUI.menu = GlobalUI.Menus.NONE
	get_tree().paused = false
	animation_player.play_backwards("show")
	disable_buttons()
	yield(animation_player, "animation_finished")
	if not animation_player.is_playing() and not get_tree().paused and not GlobalUI.menu == GlobalUI.Menus.INVENTORY:
		hide()


func disable_buttons() -> void:
	for n in upper_buttons.get_children():
		n.disabled = true
		stats_upgrade_button.disabled = true


func enable_buttons() -> void:
	for n in upper_buttons.get_children():
		n.disabled = false
		stats_upgrade_button.disabled = false


func update_inventory() -> void:
	# Quick Items
	not_in_level_warning.visible = \
			Globals.game_state == Globals.GameStates.WORLD_SELECTOR

	powerups_explanation_label.text = tr("inventory.no_items")

	order_buttons(powerups_buttons, "powerups")
	order_buttons(collectables_buttons, "collectables")
	order_buttons(equippables_buttons, "equippables")

	var stats: Array = GlobalSave.get_stat("powerups")
	var index: int = stats.size()

	powerups_buttons_top_focus = null
	powerups_buttons_bottom_focus = null

	for stat in stats:
		if powerups_buttons.get_node(stat[0].capitalize()).visible:
			if stats.size() > 0:
				if index == 1:
					powerups_buttons_top_focus = powerups_buttons.get_node(stat[0].capitalize())
				elif index == stats.size():
					powerups_buttons_bottom_focus = powerups_buttons.get_node(stat[0].capitalize())
		index -= 1

	# Equippables
	stats = GlobalSave.get_stat("equippables")
	index = stats.size()
	equippables_buttons_top_focus = null
	equippables_buttons_bottom_focus = null

	for stat in stats:
		if equippables_buttons.get_node(stat[0].capitalize()).visible:
			if stats.size() > 0:
				if index == 1:
					equippables_buttons_top_focus = equippables_buttons.get_node(stat[0].capitalize())
				elif index == stats.size():
					equippables_buttons_bottom_focus = equippables_buttons.get_node(stat[0].capitalize())
		index -= 1


	# Ranks and Stats
	rank_explanation_label.text = tr(GlobalStats.RANK_EXPLANATIONS[GlobalStats.Ranks.keys()[GlobalStats.Ranks.NONE].to_lower()])
	rank_explanation_label.modulate = Color8(255, 255, 255, 255)
	rank_title_label.text = ""
	for texture in ranks_container.get_children():
		if texture.name.to_lower() == GlobalStats.Ranks.keys()[GlobalSave.get_stat("rank")].to_lower():
			rank_explanation_label.modulate = Color8(40, 255, 60, 255)
			texture.show()
			rank_explanation_label.text = tr(GlobalStats.RANK_EXPLANATIONS[GlobalStats.Ranks.keys()[GlobalSave.get_stat("rank")].to_lower()])
			rank_title_label.text = "%s: %s" % [tr("inventory.ranks.my_rank"), tr(GlobalStats.RANK_NAMES[GlobalStats.Ranks.keys()[GlobalSave.get_stat("rank")].capitalize()])]
		else:
			texture.hide()

	upgrade_stats_info_label.text = "%s\n%s %s" % [tr("inventory.upgrade_requirements_label"), GlobalSave.get_level_up_cost(), tr("inventory.upgrade_stats.orbs")]
	stats_upgrade_button.disabled = not (GlobalSave.get_stat("orbs") >= GlobalSave.get_level_up_cost())

	var world_string: String = "\"%s\" - %s" % [GlobalLevel.WORLD_NAMES[GlobalSave.get_stat("world_max")], GlobalSave.get_stat("level_max")]
	stats_label.text = "%s: %s\n\n%s:\n       %s" % \
			[tr("inventory.stats_profile_label"), (GlobalSave.profile + 1), tr("inventory.lastest_world"),world_string]
	stats_label_level.text = "%s: %s" % [tr("inventory.stats.player_level"), GlobalSave.get_stat("level")]
	stats_label_orbs.text = "%s: x%s" % [tr("inventory.stats.total_orbs"), GlobalSave.get_stat("orbs")]
	stats_label_gems.text = "%s: x%s" % [tr("inventory.stats.total_gems"), GlobalSave.get_gem_count()]

	for w_icon in world_icons.get_children():
		if int(w_icon.name) == GlobalSave.get_stat("world_max"):
			world_icons.show()
			w_icon.show()
		else:
			w_icon.hide()


func update_button_focus(top_button: Button) -> void:
	if top_button == null:
		for button in upper_buttons.get_children():
				button.focus_neighbour_bottom = button.get_path()
		return

	if top_button == stats_upgrade_button:
		for button in upper_buttons.get_children():
			if not stats_upgrade_button.disabled:
				button.focus_neighbour_bottom = stats_upgrade_button.get_path()
			else:
				button.focus_neighbour_bottom = button.get_path()
		return

	var button_container: VBoxContainer

	if top_button == powerups_buttons_top_focus:
		button_container = powerups_buttons
	elif top_button == equippables_buttons_top_focus:
		button_container = equippables_buttons

	var index: int = button_container.get_children().size()


	for button in button_container.get_children():
		button.focus_neighbour_left = button.get_path()
		button.focus_neighbour_right = button.get_path()
		if index == button_container.get_children().size():
			continue

		button.focus_neighbour_top = button_container.get_child(index + 1).get_path()
		button.focus_previous = button_container.get_child(index + 1).get_path()
		if button_container.get_child(index - 2) == button:
			button.focus_neighbour_top = button_container.get_child(index - 2).get_path()
			button.focus_previous = button_container.get_child(index - 2).get_path()

		index -= 1

	button_close.focus_neighbour_bottom = top_button.get_path()
	top_powerup_button.focus_neighbour_bottom = \
			top_button.get_path()
	top_collectables_button.focus_neighbour_bottom = \
			top_button.get_path()
	top_rank_button.focus_neighbour_bottom = \
			top_button.get_path()
	top_stats_button.focus_neighbour_bottom = top_button.get_path()

	if top_button == powerups_buttons_top_focus:
		top_button.focus_neighbour_top = top_powerup_button.get_path()
	else:
		top_button.focus_neighbour_top = top_collectables_button.get_path()


func order_buttons(buttons: VBoxContainer, player_stat: String) -> void:
	var button_names: Array = []
	for button in buttons.get_children():
		var string = button.name.to_lower()
		string.replace(" ", "_")
		button_names.push_back(string)
	var stats: Array = GlobalSave.get_stat(player_stat)
	var index: int = stats.size()

	# got lazy
	var button_positions: Array = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

	for button in button_names:
		if not button in stats:
			if not buttons.get_node_or_null(button.capitalize()) == null:
				buttons.get_node(button.capitalize()).hide()

	for stat in stats:
		if stat[0] in button_names:
			var string: String = tr(GlobalStats.COMMON_NAMES[stat[0].capitalize()])
			if not buttons.get_node_or_null(stat[0].capitalize()) == null:
				if not player_stat == "equippables":
					string += " x%s" % stat[1]
				elif stat[0] == GlobalSave.get_stat("equipped_item"):
					buttons.get_node_or_null(stat[0].capitalize()).set("custom_colors/font_color", Color8(40, 255, 60, 255))
				else:
					buttons.get_node_or_null(stat[0].capitalize()).set("custom_colors/font_color", Color8(255, 255, 255, 255))

				buttons.get_node(stat[0].capitalize()).show()
				buttons.get_node(stat[0].capitalize()).text = string
				button_positions[index] = index

				if index == stats.size():

					buttons.get_node(stat[0].capitalize()).grab_focus()
				index -= 1

	button_positions.invert()
	index = stats.size()

	for stat in stats:
		if not buttons.get_node(stat[0].capitalize()) == null:

			if buttons.get_node(stat[0].capitalize()).visible:
				buttons.move_child(
						buttons.get_node(stat[0].capitalize()),
						button_positions[stats.size()])

				if index == stats.size():
					if not player_stat == "powerups":
						buttons.get_node(stat[0].capitalize()).focus_neighbour_bottom = buttons.get_node(stat[0].capitalize()).get_path()
				index -= 1

	index = stats.size()


func play_powerup_sound(alt_sound: bool = false) -> void:
	if alt_sound:
			powerup_sound.pitch_scale = 1.1
	else:
		powerup_sound.pitch_scale = 1.0

	powerup_sound.play()


#                                                  #
# !!! UPDATE THIS WHEN ADDING NEW FILLER ITEMS !!! #
#                                                  #
func fill_items(stat: String, amount: int) -> void:
	# 0 : Health
	# 1 : Adrenaine
	var type: int = 0
	var stat_boost: int
	match stat:
		"carrot":
			stat_boost = GlobalStats.CARROT_BOOST
			type = 0
		"coconut":
			stat_boost = GlobalStats.COCONUT_BOOST
			type = 0
		"cherry":
			stat_boost = GlobalStats.CHERRY_BOOST
			type = 1
		"pear":
			stat_boost = GlobalStats.PEAR_HEALTH_BOOST
			type = 0

	var iterations: int = 0
	var amount_test: int = 0

	if type == 0:
		if int(GlobalSave.get_stat("health_max")) == int(GlobalSave.get_stat("health")):
			GlobalEvents.emit_signal("player_used_powerup", stat)
			play_powerup_sound()
			return
		while amount_test < (int(GlobalSave.get_stat("health_max")) - int(GlobalSave.get_stat("health"))):
			amount_test += stat_boost
			iterations += 1
	elif type == 1:
		if int(GlobalSave.get_stat("adrenaline_max")) == int(GlobalSave.get_stat("adrenaline")):
			GlobalEvents.emit_signal("player_used_powerup", stat)
			play_powerup_sound()
			return
		while amount_test < (int(GlobalSave.get_stat("adrenaline_max")) - int(GlobalSave.get_stat("adrenaline"))):
			amount_test += stat_boost
			iterations += 1

	# If the amount needed is less than the amount had, use the amount had
	if amount < iterations:
		for _n in range(amount):
			GlobalEvents.emit_signal("player_used_powerup", stat)
			play_powerup_sound(true)
			hide_menu()
	else:
		for _n in range(iterations):
			GlobalEvents.emit_signal("player_used_powerup", stat)
			play_powerup_sound(true)
			hide_menu()


func try_use_powerup(item: String, from_inventory := true) -> void:
	if not Globals.game_state == Globals.GameStates.LEVEL: return

	var has_item := false

	for stat in GlobalSave.get_stat("powerups"):
		if stat[0] == item:
			if stat[1] > 0:
				has_item = true

	if not has_item or item == "none":
		if GlobalUI.menu_locked or GlobalUI.fade_player_playing or not GlobalUI.menu == GlobalUI.Menus.NONE:
			return
		# Item Failed
		GlobalEvents.emit_signal("ui_inventory_opened")
		GlobalEvents.emit_signal("ui_button_pressed")

		GlobalUI.menu = GlobalUI.Menus.INVENTORY
		show_menu()
		get_tree().set_input_as_handled()
		return

	GlobalStats.last_powerup = item
	GlobalStats.last_powerup_before_death = item


#	if item in GlobalStats.TIMED_POWERUPS and GlobalStats.timed_powerup_active:
#		GlobalEvents.emit_signal("ui_notification_shown", tr("notification.item_active"))
#		return
#
#	else:
	if not item in GlobalStats.TIMED_POWERUPS and fill_button.pressed:
		var stats = GlobalSave.get_stat("powerups")

		for stat in stats:
			var string = item

			string = string.replace(" ", "_")

			if string == stat[0]:
				if not stat[0] in GlobalStats.TIMED_POWERUPS:
					fill_items(stat[0], stat[1])
				continue
	else:
		GlobalEvents.emit_signal("player_used_powerup", item)
		play_powerup_sound()

	if from_inventory:
		#GlobalEvents.emit_signal("ui_button_pressed")
		hide_menu()


# Start of GlobalEvents
func _level_changed(_world: int, _level: int) -> void:
	#last_powerup = "none"
	last_equippable = GlobalSave.get_stat("equipped_item")

	# Determine last used gun
	var stats = GlobalSave.get_stat("equippables")
	var index = stats.size()

	equippables_buttons_top_focus = null
	equippables_buttons_bottom_focus = null

	for stat in stats:
		if equippables_buttons.get_node(stat[0].capitalize()).visible:
			if stats.size() > 0:
				if index == 1:
					equippables_buttons_top_focus = equippables_buttons.get_node(stat[0].capitalize())
					last_equippable = equippables_buttons.get_node(stat[0].capitalize()).name.to_lower()


func _level_completed() -> void:
	#last_powerup = "none"
	last_equippable = GlobalSave.get_stat("equipped_item")


func _player_collected_powerup(item_name: String) -> void:
	var inv: Array = GlobalSave.get_stat("powerups")
	if item_name in GlobalStats.VALID_POWERUPS:
		if not GlobalSave.has_item(inv, item_name):
			inv.push_back([item_name, 1])
			return
		for array in inv:
			if array[0] == item_name:
				if GlobalSave.has_item(inv, item_name):
					array[1] += 1
	GlobalSave.set_stat("powerups", inv)


func _player_collected_equippable(item_name: String) -> void:
	var inv: Array = GlobalSave.get_stat("equippables")

	if item_name in GlobalStats.VALID_EQUIPPABLES:
		if not GlobalSave.has_item(inv, item_name):
			inv.push_back([item_name, 1])
			return
		for array in inv:
			if array[0] == item_name:
				if GlobalSave.has_item(inv, item_name):
					array[1] += 1
	else:
		printerr("%s NOT FOUND IN VALID LIST" % item_name)
	GlobalSave.set_stat("equippables", inv)


func _player_collected_collectable(item_name: String) -> void:
	var inv: Array = GlobalSave.get_stat("collectables")
	if item_name in GlobalStats.VALID_COLLECTABLES:
		if not GlobalSave.has_item(inv, item_name):
			inv.push_back([item_name, 1])
			return
		for array in inv:
			if array[0] == item_name:
				if GlobalSave.has_item(inv, item_name):
					array[1] += 1
	GlobalSave.set_stat("collectables", inv)


func _player_used_powerup(item_name: String) -> void:
	if item_name in GlobalStats.VALID_POWERUPS:
		var inv: Array = GlobalSave.get_stat("powerups")
		if GlobalSave.has_item(inv, item_name):
			for array in inv:
				if array[0] == item_name:
					array[1] -= 1
					if array[1] == 0:
						var find = inv.find(array)
						inv.remove(find)
#				else:
#					inv.erase(item_name)
		GlobalSave.set_stat("powerups", inv)


func _ui_settings_updated() -> void:
	upgrade_stats_adrenaline_button.text = "+ %s" % tr("inventory.upgrade_stats.adrenaline")
# End of GlobalEvents


func _close_pressed() -> void:
	hide_menu()
	GlobalEvents.emit_signal("ui_button_pressed", true)
	GlobalEvents.emit_signal("ui_inventory_closed")
	button_close.release_focus()


func _equippable_pressed() -> void:
	if Globals.game_state == Globals.GameStates.LEVEL:
		GlobalEvents.emit_signal("ui_button_pressed")
		for n in equippables_buttons.get_children():
			if n.has_focus():
				if not GlobalSave.get_stat("equipped_item") == n.name.to_lower():
					powerup_sound.play()
					GlobalEvents.emit_signal("player_equipped", n.name.to_lower())
					hide_menu()
				else:
					GlobalEvents.emit_signal("player_equipped", "none")
					hide_menu()


# A powerup button pressed
func _powerup_pressed() -> void:
	for n in powerups_buttons.get_children():
		if n.has_focus():
			try_use_powerup(n.name.to_lower(), true)


# Inventory Tab
func _powerups_pressed() -> void:
	GlobalEvents.emit_signal("ui_button_pressed")
	if not current_panel == powerups_panel:
		update_button_focus(powerups_buttons_top_focus)
		powerups_panel.show()
		powerups_anim_player.play_backwards("slide")
		current_panel.get_node("AnimationPlayer").play("slide")
		current_panel = powerups_panel


func _collectables_pressed() -> void:
	GlobalEvents.emit_signal("ui_button_pressed")
	if not current_panel == collectables_panel:
		update_button_focus(equippables_buttons_top_focus)
		collectables_panel.show()
		collectables_panel_anim_player.play_backwards("slide")
		current_panel.get_node("AnimationPlayer").play("slide")
		current_panel = collectables_panel


func _ranks_pressed() -> void:
	GlobalEvents.emit_signal("ui_button_pressed")
	if not current_panel == ranks_panel:
		update_button_focus(null)
		ranks_panel.show()
		ranks_anim_player.play_backwards("slide")
		current_panel.get_node("AnimationPlayer").play("slide")
		current_panel = ranks_panel


func _stats_pressed() -> void:
	GlobalEvents.emit_signal("ui_button_pressed")
	if not current_panel == stats_panel:
		update_button_focus(stats_upgrade_button)
		stats_panel.show()
		stats_anim_player.play_backwards("slide")
		current_panel.get_node("AnimationPlayer").play("slide")
		current_panel = stats_panel


func _upgrade_stats_pressed() -> void:
	$"Panel/Stats/UpgradeStatsPrompt".show()
	var has_adrenaline: bool = GlobalSave.get_stat("rank") >= GlobalStats.Ranks.GOLD
	upgrade_stats_adrenaline_button.visible = has_adrenaline

	upgrade_stats_cancel_button.grab_focus()
	GlobalEvents.emit_signal("ui_button_pressed")
	GlobalUI.menu = GlobalUI.Menus.INVENTORY_UPGRADE_PROMPT
	disable_buttons()
	upgrade_stats_cancel_button.disabled = false
	upgrade_stats_health_button.disabled = false
	upgrade_stats_adrenaline_button.disabled = false
	upgrade_stats_anim_player.play("show")
	if has_adrenaline:
		upgrade_stats_health_button.text = "+ %s" % tr("inventory.upgrade_stats.health")
		upgrade_stats_prompt_text.text = \
				"%s: %s -> %s\n%s\n%s %s -> %s   |   %s %s -> %s\n%s: %s %s" \
				% [
						tr("inventory.upgrade_stats.level"),
						GlobalSave.get_stat("level"),
						GlobalSave.get_stat("level") + 1,
						tr("inventory.upgrade_stats.choose"),
						tr("inventory.upgrade_stats.health"),
						GlobalSave.get_stat("health_max"),
						GlobalSave.get_stat("health_max") + 5,
						tr("inventory.upgrade_stats.adrenaline"),
						GlobalSave.get_stat("adrenaline_max"),
						GlobalSave.get_stat("adrenaline_max") + 5,
						tr("inventory.upgrade_stats.cost"),
						GlobalSave.get_level_up_cost(),
						tr("inventory.upgrade_stats.orbs")]
	else:
		upgrade_stats_health_button.text = tr("inventory.upgrade_stats.upgrade_level")
		upgrade_stats_prompt_text.text = \
				"%s: %s -> %s\n%s %s -> %s\n%s: %s %s" \
				% [
						tr("inventory.upgrade_stats.level"),
						GlobalSave.get_stat("level"),
						GlobalSave.get_stat("level") + 1,
						tr("inventory.upgrade_stats.health"),
						GlobalSave.get_stat("health_max"),
						GlobalSave.get_stat("health_max") + 5,
						tr("inventory.upgrade_stats.cost"),
						GlobalSave.get_level_up_cost(),
						tr("inventory.upgrade_stats.orbs")]


func _upgrade_stats_cancel_pressed() -> void:
	GlobalUI.menu = GlobalUI.Menus.INVENTORY

	stats_upgrade_button.grab_focus()
	GlobalEvents.emit_signal("ui_button_pressed", true)
	upgrade_stats_cancel_button.disabled = true
	upgrade_stats_health_button.disabled = true
	upgrade_stats_adrenaline_button.disabled = true
	enable_buttons()
	upgrade_stats_anim_player.play_backwards("show")
	yield(upgrade_stats_anim_player, "animation_finished")
	if not upgrade_stats_anim_player.is_playing():
		$"Panel/Stats/UpgradeStatsPrompt".hide()


func _upgrade_stats_health_pressed() -> void:
	GlobalEvents.emit_signal("player_level_increased", "health")
	GlobalEvents.emit_signal("save_file_saved", false)
	_upgrade_stats_cancel_pressed()
	_close_pressed()
	upgrade_sound.play()
	GlobalUI.menu = GlobalUI.Menus.NONE


func _upgrade_stats_adrenaline_pressed() -> void:
	GlobalEvents.emit_signal("player_level_increased", "adrenaline")
	GlobalEvents.emit_signal("save_file_saved", false)
	_upgrade_stats_cancel_pressed()
	_close_pressed()
	upgrade_sound.play()
	GlobalUI.menu = GlobalUI.Menus.NONE


func _button_hovered() -> void:
	GlobalEvents.emit_signal("ui_button_hovered")


func _on_Fill_pressed() -> void:
	GlobalEvents.emit_signal("ui_button_pressed")


func _on_Fill_focus_entered() -> void:
	powerups_explanation_label.text = tr("inventory.quick_items.fill")


func _on_Fill_mouse_entered() -> void:
	powerups_explanation_label.text = tr("inventory.quick_items.fill")


func _on_Carrot_mouse_entered() -> void:
	powerups_explanation_label.text = GlobalStats.get_powerup_explanation("carrot")


func _on_Carrot_focus_entered() -> void:
	powerups_explanation_label.text = GlobalStats.get_powerup_explanation("carrot")


func _on_Cherry_mouse_entered() -> void:
	powerups_explanation_label.text = GlobalStats.get_powerup_explanation("cherry")


func _on_Cherry_focus_entered() -> void:
	powerups_explanation_label.text = GlobalStats.get_powerup_explanation("cherry")


func _on_Coconut_mouse_entered() -> void:
	powerups_explanation_label.text = GlobalStats.get_powerup_explanation("coconut")


func _on_Coconut_focus_entered() -> void:
	powerups_explanation_label.text = GlobalStats.get_powerup_explanation("coconut")


func _on_Bunny_Egg_focus_entered() -> void:
	powerups_explanation_label.text = GlobalStats.get_powerup_explanation("bunny egg")


func _on_Bunny_Egg_mouse_entered() -> void:
	powerups_explanation_label.text = GlobalStats.get_powerup_explanation("bunny egg")


func _on_Glitch_Orb_focus_entered() -> void:
	powerups_explanation_label.text = GlobalStats.get_powerup_explanation("glitch orb")


func _on_Glitch_Orb_mouse_entered() -> void:
	powerups_explanation_label.text = GlobalStats.get_powerup_explanation("glitch orb")


func _on_Pear_focus_entered() -> void:
	powerups_explanation_label.text = GlobalStats.get_powerup_explanation("pear")


func _on_Pear_mouse_entered() -> void:
	powerups_explanation_label.text = GlobalStats.get_powerup_explanation("pear")


func _on_Glitch_Soul_focus_entered() -> void:
	powerups_explanation_label.text = GlobalStats.get_powerup_explanation("glitch soul")


func _on_Glitch_Soul_mouse_entered() -> void:
	powerups_explanation_label.text = GlobalStats.get_powerup_explanation("glitch soul")


func _on_Ice_Spike_focus_entered() -> void:
	powerups_explanation_label.text = GlobalStats.get_powerup_explanation("ice spike")


func _on_Ice_Spike_mouse_entered() -> void:
	powerups_explanation_label.text = GlobalStats.get_powerup_explanation("ice spike")
