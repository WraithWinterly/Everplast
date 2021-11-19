extends Control


var powerup_explanations: Dictionary = {
	"carrot": "Increases your health by 2",
	"cherry": "Increases your adrenaline by 10",
	"coconut": "Coconut description",
	"bunny egg": "Gives you a speed boost for 5 seconds",
	"glitch orb": "player.code(hack_damage, 5) true"
}
var rank_explanations: Dictionary = {
	"none": "You do not have a rank yet.",
	"silver": "- See enemy health on hit\n- Double Jump\n- Wall Jump",
	"gold": "- Adrenaline Rush\n",
	"diamond": "Diamond description",
	"emerald": "Emerald description",
	"glitch": "Glitch description",
	"volcano": "Volcano description",
}

var valid_powerups: Array = ["carrot", "cherry", "coconut", "bunny egg", "glitch orb"]
var valid_equipables: Array = ["water gun", "nail gun", "laser gun"]
var valid_collectables: Array = ["energy", "water", "nail"]

var open_allowed: bool = false
var in_upgrade_prompt: bool = false

var tab_1_focus: Button
var tab_1_focus_bottom: Button
var tab_2_focus: Button
var tab_2_focus_bottom: Button
var tab_3_focus: Button = null
var tab_4_focus: Button


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
onready var powerups_buttons: VBoxContainer = $Panel/Powerups/HBoxContainer/Buttons
onready var powerups_explanation_label: Label = $Panel/Powerups/Explanation/Label
onready var not_in_level_warning: Label = $Panel/Powerups/NotInLevelWarning

onready var collectables_panel: Panel = $Panel/Collectables
onready var collectables_panel_anim_player: AnimationPlayer = $Panel/Collectables/AnimationPlayer
onready var collectables_buttons: VBoxContainer = $Panel/Collectables/Collectables/Buttons
onready var equipables_buttons: VBoxContainer = $Panel/Collectables/Equipables/Buttons

onready var ranks_panel: Panel = $Panel/Ranks
onready var ranks_anim_player: AnimationPlayer = $Panel/Ranks/AnimationPlayer
onready var ranks_container: VBoxContainer = $Panel/Ranks/CurrentRank/VBoxContainer
onready var rank_explanation_label: Label = $Panel/Ranks/CurrentRank/Stats
onready var rank_title_label: Label = $Panel/Ranks/CurrentRank/Title

onready var stats_panel: Panel = $Panel/Stats
onready var stats_anim_player: AnimationPlayer = $Panel/Stats/AnimationPlayer
onready var stats_upgrade_button: Button = $Panel/Stats/StatsUpgrade/UpgradeButton
onready var stats_label: Label = $Panel/Stats/PlayerStats/Info
onready var stats_label_orbs: Label = $Panel/Stats/PlayerStats/TotalOrbs
onready var stats_label_gems: Label = $Panel/Stats/PlayerStats/TotalGems
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
	__ = UI.connect("changed", self, "_ui_changed")
	__ = Signals.connect("level_changed", self, "_level_changed")
	__ = Signals.connect("powerup_collected", self, "_powerup_collected")
	__ = Signals.connect("powerup_used", self, "_powerup_used")
	__ = Signals.connect("equipable_collected", self, "_equipable_collected")
	__ = Signals.connect("collectable_collected", self, "_collectable_collected")
	__ = button_close.connect("pressed", self, "_close_pressed")
	__ = top_powerup_button.connect("pressed", self, "_powerups_pressed")
	__ = top_collectables_button.connect("pressed", self, "_collectables_pressed")
	__ = top_rank_button.connect("pressed", self, "_ranks_pressed")
	__ = top_stats_button.connect("pressed", self, "_stats_pressed")
	__ = stats_upgrade_button.connect("pressed", self, "_upgrade_stats_pressed")
	__ = upgrade_stats_cancel_button.connect("pressed", self, "_upgrade_stats_cancel_pressed")
	__ = upgrade_stats_health_button.connect("pressed", self, "_upgrade_stats_health_pressed")
	__ = upgrade_stats_adrenaline_button.connect("pressed", self, "_upgrade_stats_adrenaline_pressed")

	hide()
	collectables_panel.hide()
	ranks_panel.hide()
	stats_panel.hide()

	for button in powerups_buttons.get_children():
		button.hide()
	for button in equipables_buttons.get_children():
		button.hide()
	for button in collectables_buttons.get_children():
		button.hide()


func _unhandled_input(event: InputEvent) -> void:
	if Globals.game_state == Globals.GameStates.MENU: return
	if Globals.death_in_progress: return
	if not open_allowed: return
	if animation_player.is_playing(): return
	if event.is_action_pressed("inventory") \
			and UI.current_menu == UI.NONE and not Globals.dialog_active and not UI.menu_transitioning and not in_upgrade_prompt:
			if Globals.inventory_active:
				hide_menu()
				Signals.emit_signal("inventory_changed", false)
			else:
				Signals.emit_signal("inventory_changed", true)
				UI.emit_signal("button_pressed")
				current_panel = powerups_panel
				current_panel.get_node("AnimationPlayer").play("slide")
				powerups_anim_player.play_backwards("slide")
				powerups_panel.show()
				collectables_panel.hide()
				ranks_panel.hide()
				stats_panel.hide()
				enable_buttons()
				Globals.inventory_active = true
				show()
				update_inventory()
				update_button_focus(tab_1_focus)
				get_tree().paused = true
				animation_player.play("show")
				top_powerup_button.grab_focus()
	elif event.is_action_pressed("ui_cancel") and UI.current_menu == UI.NONE:
		if in_upgrade_prompt:
			_upgrade_stats_cancel_pressed()
		elif Globals.inventory_active:
			hide_menu()
			Signals.emit_signal("inventory_changed", false)


func hide_menu() -> void:
	UI.emit_signal("button_pressed", true)
	Signals.emit_signal("inventory_changed", false)
	if Globals.inventory_active:
			get_tree().paused = false
			Globals.inventory_active = false
	animation_player.play_backwards("show")
	yield(animation_player, "animation_finished")
	if not animation_player.is_playing():
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

	powerups_explanation_label.text = "There is not much to see here."
	order_buttons(powerups_buttons, "powerups")
	order_buttons(collectables_buttons, "collectables")
	order_buttons(equipables_buttons, "equipables")
	var stats: Array = PlayerStats.get_stat("powerups")
	var index: int = stats.size()

	tab_1_focus = null
	tab_1_focus_bottom = null

	for stat in stats:
		if powerups_buttons.get_node(stat[0].capitalize()).visible:
			if stats.size() > 0:
				if index == 1:
					tab_1_focus = powerups_buttons.get_node(stat[0].capitalize())
				elif index == stats.size():
					tab_1_focus_bottom = powerups_buttons.get_node(stat[0].capitalize())
		index -= 1

	stats = PlayerStats.get_stat("equipables")
	index = stats.size()
	tab_2_focus = null
	tab_2_focus_bottom = null
	for stat in stats:
		if equipables_buttons.get_node(stat[0].capitalize()).visible:
			if stats.size() > 0:
				if index == 1:
					tab_2_focus = equipables_buttons.get_node(stat[0].capitalize())
				elif index == stats.size():
					tab_2_focus_bottom = equipables_buttons.get_node(stat[0].capitalize())
		index -= 1


	# Ranks and stats
	rank_explanation_label.text = rank_explanations[PlayerStats.ranks[PlayerStats.Ranks.NONE]]
	rank_explanation_label.modulate = Color8(255, 255, 255, 255)
	rank_title_label.text = ""
	for texture in ranks_container.get_children():
		if texture.name.to_lower() == PlayerStats.ranks[PlayerStats.get_stat("rank")]:
			rank_explanation_label.modulate = Color8(40, 255, 60, 255)
			texture.show()
			rank_explanation_label.text = rank_explanations[PlayerStats.ranks[PlayerStats.get_stat("rank")]]
			rank_title_label.text = "My Rank: %s" % PlayerStats.ranks[PlayerStats.get_stat("rank")].capitalize()
		else:
			texture.hide()
	upgrade_stats_info_label.text = "Upgrade Requirements:\n%s Orbs" % PlayerStats.get_level_up_cost()
	stats_upgrade_button.disabled = not (PlayerStats.get_stat("orbs") >= PlayerStats.get_level_up_cost())

	var world_string: String = "\"%s\" - %s" % [Globals.get_main().world_names[PlayerStats.get_stat("world_max")], PlayerStats.get_stat("level_max")]
	stats_label.text = "Profile: %s\nPlayer Level: %s\nLatest World:\n       %s" % \
			[(PlayerStats.current_save_profile + 1), PlayerStats.get_stat("level"), world_string]
	stats_label_orbs.text = "x%s" % PlayerStats.get_stat("orbs")
	stats_label_gems.text = "x%s" % PlayerStats.get_gem_count()
	for w_icon in world_icons.get_children():
		if int(w_icon.name) == PlayerStats.get_stat("world_max"):
			world_icons.show()
			w_icon.show()
		else:
			w_icon.hide()


func update_button_focus(top_button: Button) -> void:
	if top_button == tab_4_focus:
		for button in upper_buttons.get_children():
			if not stats_upgrade_button.disabled:
				button.focus_neighbour_bottom = stats_upgrade_button.get_path()
			else:
				button.focus_neighbour_bottom = button.get_path()
		return
	if top_button == null:
		for button in upper_buttons.get_children():
				button.focus_neighbour_bottom = button.get_path()


	var button_container: VBoxContainer
	if top_button == tab_1_focus:
		button_container = powerups_buttons
	elif top_button == tab_2_focus:
		button_container = equipables_buttons

	var index: int = button_container.get_children().size()

	for button in button_container.get_children():
		button.focus_neighbour_left = button.get_path()
		button.focus_neighbour_right = button.get_path()
		if index - 1 == 1: continue

		button.focus_neighbour_top = button_container.get_child(index - 2).get_path()
		button.focus_previous = button_container.get_child(index - 2).get_path()
		index -= 1
	top_powerup_button.focus_neighbour_bottom = \
			top_button.get_path()
	top_collectables_button.focus_neighbour_bottom = \
			top_button.get_path()
	top_rank_button.focus_neighbour_bottom = \
			top_button.get_path()
	if top_button == tab_1_focus:
		top_button.focus_neighbour_top = top_powerup_button.get_path()
	else:
		top_button.focus_neighbour_top = top_collectables_button.get_path()


func order_buttons(buttons: VBoxContainer, player_stat: String) -> void:
	var button_names: Array = []
	for button in buttons.get_children():
		var string = button.name.to_lower()
		string.replace(" ", "_")
		button_names.push_back(string)
	var stats: Array = PlayerStats.get_stat(player_stat)
	var index: int = stats.size()

	var button_positions: Array = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
#
	for button in button_names:
		if not button in stats:
			if not buttons.get_node_or_null(button.capitalize()) == null:
				buttons.get_node(button.capitalize()).hide()

	for stat in stats:
		if stat[0] in button_names:
			var string: String = stat[0].capitalize()
			if not buttons.get_node_or_null(stat[0].capitalize()) == null:
				if not player_stat == "equipables":
					string += " x%s" % stat[1]
				elif stat[0] == PlayerStats.get_stat("equipped_item"):
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
				index -= 1

	index = stats.size()


func _ui_changed(menu: int) -> void:
	if menu == UI.NONE:
		if UI.last_menu == UI.PROFILE_SELECTOR or UI.last_menu == UI.PAUSE_MENU_RETURN_PROMPT:
			open_allowed = true
	if menu == UI.NONE and UI.last_menu == UI.PAUSE_MENU_RETURN_PROMPT:
		hide_menu()
		if Globals.game_state == Globals.GameStates.MENU:
			open_allowed = false
	if menu == UI.MAIN_MENU and visible:
		hide_menu()
		open_allowed = false


func _level_changed(_world: int, _level: int) -> void:
	yield(UI, "faded")
	open_allowed = true


func _close_pressed() -> void:
	hide_menu()
	Signals.emit_signal("inventory_changed", false)


func _equipable_pressed() -> void:
	if Globals.game_state == Globals.GameStates.LEVEL:
		UI.emit_signal("button_pressed")
		for n in equipables_buttons.get_children():
			if n.has_focus():
				if not PlayerStats.get_stat("equipped_item") == n.name.to_lower():
					powerup_sound.play()
					Signals.emit_signal("equipped", n.name.to_lower())
					hide_menu()
				else:
					Signals.emit_signal("equipped", "none")
					hide_menu()


func _powerup_pressed() -> void:
	if Globals.game_state == Globals.GameStates.LEVEL:
		UI.emit_signal("button_pressed")
		for n in powerups_buttons.get_children():
			if n.has_focus():
				if not Globals.timed_powerup_active:
					powerup_sound.play()
					Signals.emit_signal("powerup_used", n.name.to_lower())
					hide_menu()
					return
				else:
					UI.emit_signal("show_notification", "You can not use this item yet, one is already active!")


func _powerups_pressed() -> void:
	UI.emit_signal("button_pressed")
	if not current_panel == powerups_panel:
		update_button_focus(tab_1_focus)
		powerups_panel.show()
		powerups_anim_player.play_backwards("slide")
		current_panel.get_node("AnimationPlayer").play("slide")
		current_panel = powerups_panel


func _collectables_pressed() -> void:
	UI.emit_signal("button_pressed")
	if not current_panel == collectables_panel:
		update_button_focus(tab_2_focus)
		collectables_panel.show()
		collectables_panel_anim_player.play_backwards("slide")
		current_panel.get_node("AnimationPlayer").play("slide")
		current_panel = collectables_panel


func _ranks_pressed() -> void:
	UI.emit_signal("button_pressed")
	if not current_panel == ranks_panel:
		update_button_focus(tab_3_focus)
		ranks_panel.show()
		ranks_anim_player.play_backwards("slide")
		current_panel.get_node("AnimationPlayer").play("slide")
		current_panel = ranks_panel


func _stats_pressed() -> void:
	UI.emit_signal("button_pressed")
	if not current_panel == stats_panel:
		update_button_focus(tab_4_focus)
		stats_panel.show()
		stats_anim_player.play_backwards("slide")
		current_panel.get_node("AnimationPlayer").play("slide")
		current_panel = stats_panel


func _upgrade_stats_pressed() -> void:
	var has_adrenaline: bool = PlayerStats.get_stat("rank") >= PlayerStats.Ranks.GOLD
	upgrade_stats_adrenaline_button.visible = has_adrenaline
	upgrade_stats_cancel_button.grab_focus()
	UI.emit_signal("button_pressed")
	in_upgrade_prompt = true
	disable_buttons()
	upgrade_stats_anim_player.play("show")
	if has_adrenaline:
		upgrade_stats_health_button.text = "+ Health"
		upgrade_stats_prompt_text.text = \
				"Level: %s -> %s\nChoose what to upgrade.\nHealth %s -> %s\nor\nAdrenaline %s -> %s\nCost: %s Orbs" \
				% [
						PlayerStats.get_stat("level"),
						PlayerStats.get_stat("level") + 1,
						PlayerStats.get_stat("health_max"),
						PlayerStats.get_stat("health_max") + 5,
						PlayerStats.get_stat("adrenaline_max"),
						PlayerStats.get_stat("adrenaline_max") + 5,
						PlayerStats.get_level_up_cost()]
	else:
		upgrade_stats_health_button.text = "Upgrade Level!"
		upgrade_stats_prompt_text.text = \
				"Level: %s -> %s\nHealth %s -> %s\nCost: %s Orbs" \
				% [
						PlayerStats.get_stat("level"),
						PlayerStats.get_stat("level") + 1,
						PlayerStats.get_stat("health_max"),
						PlayerStats.get_stat("health_max") + 5,
						PlayerStats.get_level_up_cost()]


func _upgrade_stats_cancel_pressed() -> void:
	stats_upgrade_button.grab_focus()
	UI.emit_signal("button_pressed", true)
	in_upgrade_prompt = false
	enable_buttons()
	upgrade_stats_anim_player.play_backwards("show")


func _upgrade_stats_health_pressed() -> void:
	upgrade_sound.play()
	PlayerStats.emit_signal("level_up", "health")
	_upgrade_stats_cancel_pressed()
	_close_pressed()
	Signals.emit_signal("save")


func _upgrade_stats_adrenaline_pressed() -> void:
	upgrade_sound.play()
	PlayerStats.emit_signal("level_up", "adrenaline")
	_upgrade_stats_cancel_pressed()
	_close_pressed()
	Signals.emit_signal("save")


func _powerup_collected(item_name: String) -> void:
	var inv: Array = PlayerStats.get_stat("powerups")
	if item_name in valid_powerups:
		if not PlayerStats.has(inv, item_name):
			inv.push_back([item_name, 1])
			return
		for array in inv:
			if array[0] == item_name:
				if PlayerStats.has(inv, item_name):
					array[1] += 1
	PlayerStats.set_stat("powerups", inv)


func _equipable_collected(item_name: String) -> void:
	var inv: Array = PlayerStats.get_stat("equipables")
	if item_name in valid_equipables:
		if not PlayerStats.has(inv, item_name):
			inv.push_back([item_name, 1])
			return
		for array in inv:
			if array[0] == item_name:
				if PlayerStats.has(inv, item_name):
					array[1] += 1
	PlayerStats.set_stat("equipables", inv)


func _collectable_collected(item_name: String) -> void:
	var inv: Array = PlayerStats.get_stat("collectables")
	if item_name in valid_collectables:
		if not PlayerStats.has(inv, item_name):
			inv.push_back([item_name, 1])
			return
		for array in inv:
			if array[0] == item_name:
				if PlayerStats.has(inv, item_name):
					array[1] += 1
	PlayerStats.set_stat("collectables", inv)


func _powerup_used(item_name: String) -> void:
	if item_name in valid_powerups:
		var inv: Array = PlayerStats.get_stat("powerups")
		if PlayerStats.has(inv, item_name):
			for array in inv:
				if array[0] == item_name:
					array[1] -= 1
					if array[1] == 0:
						var find = inv.find(array)
						inv.remove(find)
#				else:
#					inv.erase(item_name)
		PlayerStats.set_stat("powerups", inv)


func _on_Carrot_mouse_entered() -> void:
	powerups_explanation_label.text = powerup_explanations["carrot"]


func _on_Carrot_focus_entered() -> void:
	powerups_explanation_label.text = powerup_explanations["carrot"]


func _on_Cherry_mouse_entered() -> void:
	powerups_explanation_label.text = powerup_explanations["cherry"]


func _on_Cherry_focus_entered() -> void:
	powerups_explanation_label.text = powerup_explanations["cherry"]


func _on_Coconut_mouse_entered() -> void:
	powerups_explanation_label.text = powerup_explanations["coconut"]


func _on_Coconut_focus_entered() -> void:
	powerups_explanation_label.text = powerup_explanations["coconut"]


func _on_Bunny_Egg_focus_entered() -> void:
	powerups_explanation_label.text = powerup_explanations["bunny egg"]


func _on_Bunny_Egg_mouse_entered() -> void:
	powerups_explanation_label.text = powerup_explanations["bunny egg"]


func _on_Glitch_Orb_focus_entered() -> void:
	powerups_explanation_label.text = powerup_explanations["glitch orb"]


func _on_Glitch_Orb_mouse_entered() -> void:
	powerups_explanation_label.text = powerup_explanations["glitch orb"]
