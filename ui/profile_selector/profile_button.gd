extends Button

enum {
	LOAD
	CREATE
	UPDATE
}

export var profile_selector_path: NodePath

export var my_index: int = 0

var button_type: int = 0

var verify_failed := false

onready var stats: VBoxContainer = $Stats
onready var button_text: Label = $Text

onready var level_label: Label = $Stats/HBoxContainer/Text/Level/Label
onready var health_label: Label = $Stats/HBoxContainer/Text/Heart/Label
onready var coin_label: Label = $Stats/HBoxContainer/Text/Coin/Label
onready var orb_label: Label = $Stats/HBoxContainer/Text/Orb/Label
onready var gem_label: Label = $Stats/HBoxContainer/Text/Gem/Label
onready var adrenaline_label: Label = $Stats/HBoxContainer/Text/Adrenaline/Label
onready var adrenaline_icon: TextureRect = $Stats/HBoxContainer/Icons/Adrenaline/Texture
onready var profile_selector: Control = get_node(profile_selector_path)
onready var world_icons: VBoxContainer = $HBoxContainer/WorldIcons
onready var rank_icons: VBoxContainer = $HBoxContainer/RankIcons


func _ready() -> void:
	var __: int
	__ = GlobalEvents.connect("ui_play_pressed", self, "_ui_play_pressed")
	__ = GlobalEvents.connect("ui_profile_selector_profile_pressed", self, "_ui_profile_selector_profile_pressed")
	__ = GlobalEvents.connect("ui_profile_selector_manage_pressed", self, "_ui_profile_selector_manage_pressed")
	__ = GlobalEvents.connect("ui_profile_selector_return_pressed", self, "_ui_profile_selector_return_pressed")
	__ = GlobalEvents.connect("ui_profile_selector_delete_prompt_yes_pressed", self, "_ui_profile_selector_delete_prompt_yes_pressed")
	__ = GlobalEvents.connect("ui_profile_selector_update_prompt_yes_pressed", self, "_ui_profile_selector_update_prompt_yes_pressed")
	__ = connect("pressed", self, "button_pressed")
	__ = connect("focus_entered", self, "_focus_entered")
	__ = connect("focus_entered", self, "_button_hovered")
	__ = connect("mouse_entered", self, "_button_hovered")


	update_buttons()


func update_buttons() -> void:
	if not GlobalUI.menu_locked:
		disabled = false

	match GlobalUI.menu:
		GlobalUI.Menus.PROFILE_SELECTOR_DELETE:
			if my_index == 4:
				focus_neighbour_bottom = profile_selector.return_button.get_path()
		GlobalUI.Menus.PROFILE_SELECTOR:
			if my_index == 4:
				focus_neighbour_bottom = profile_selector.manage_button.get_path()

	if GlobalSave.data[my_index].size() == 0:
		button_type = CREATE

		match GlobalUI.menu:
			GlobalUI.Menus.PROFILE_SELECTOR:
				button_text.text = tr("profile_selector.button.new")
				button_text.show()
				button_text.modulate = Color8(255, 255, 85)
				show_blank_stats()
				world_icons.hide()
				rank_icons.hide()
			GlobalUI.Menus.PROFILE_SELECTOR_DELETE:
				stats.hide()
				button_text.hide()
				world_icons.hide()
				rank_icons.hide()

	elif not GlobalSave.verify(my_index):
		button_type = UPDATE

		match GlobalUI.menu:
			GlobalUI.Menus.PROFILE_SELECTOR:
				button_text.modulate = Color8(255, 255, 85)
				button_text.text = tr("profile_selector.button.update")
				show_blank_stats()
				world_icons.hide()
				rank_icons.hide()
			GlobalUI.Menus.PROFILE_SELECTOR_DELETE:
				button_text.text = "%s %s" % [tr("profile_selector.button.delete"), my_index + 1]
				button_text.modulate = Color8(255, 0, 0)
				show_blank_stats()
				world_icons.hide()
				rank_icons.hide()
		button_text.show()
	else:
		button_type = LOAD
		match GlobalUI.menu:
			GlobalUI.Menus.PROFILE_SELECTOR:
				button_text.text = "%s %s" % [tr("profile_selector.button.normal"),my_index + 1]
				level_label.text = str(GlobalSave.data[my_index].level)
				health_label.text = "%s | %s" % [GlobalSave.data[my_index].health, GlobalSave.data[my_index].health_max]
				coin_label.text = str(GlobalSave.data[my_index].coins)
				orb_label.text = str(GlobalSave.data[my_index].orbs)
				gem_label.text = str(GlobalSave.get_gem_count(my_index))


				# Rank Icon
				for texture in rank_icons.get_children():
					if texture.name.to_lower() == GlobalStats.Ranks.keys()[GlobalSave.data[my_index].rank].to_lower():
						rank_icons.show()
						texture.show()
					else:
						texture.hide()

				# Hide Adrenaline if not gold or above
				if GlobalSave.data[my_index].rank >= GlobalStats.Ranks.GOLD:
					adrenaline_label.text = "%s | %s" % [GlobalSave.data[my_index].adrenaline, GlobalSave.data[my_index].adrenaline_max]
					adrenaline_label.show()
					adrenaline_icon.show()
				else:
					adrenaline_label.hide()
					adrenaline_icon.hide()

				button_text.modulate = Color8(255, 255, 255)

				# World Icon
				for w_icon in world_icons.get_children():
					if int(w_icon.name) == GlobalSave.data[my_index].world_max:
						world_icons.show()
						w_icon.show()
					else:
						w_icon.hide()

			GlobalUI.Menus.PROFILE_SELECTOR_DELETE:
				button_text.text = "%s %s" % [tr("profile_selector.button.delete"), my_index + 1]
				button_text.modulate = Color8(255, 0, 0)

		stats.show()
		button_text.show()


func show_blank_stats() -> void:
	health_label.text = "-- | --"
	coin_label.text = "--"
	orb_label.text = "--"
	adrenaline_icon.hide()
	adrenaline_label.hide()
	stats.show()

func button_pressed() -> void:
	if GlobalUI.menu_locked: return

	if GlobalUI.menu == GlobalUI.Menus.PROFILE_SELECTOR_DELETE:
		if not button_type == CREATE:
			if not button_text.visible:
				return
			else:
				GlobalUI.profile_index = my_index
				GlobalEvents.emit_signal("ui_button_pressed_to_prompt")
				GlobalEvents.emit_signal("ui_profile_selector_delete_pressed")
				GlobalUI.menu = GlobalUI.Menus.PROFILE_SELECTOR_DELETE_PROMPT
		else:
			return
	else:
		GlobalUI.profile_index = my_index

		match button_type:
			CREATE:
				GlobalEvents.emit_signal("ui_button_pressed")
				GlobalEvents.emit_signal("save_file_created", my_index)
				button_type = LOAD
				button_pressed()
			LOAD:
				GlobalUI.menu = GlobalUI.Menus.NONE
				release_focus()
				GlobalEvents.emit_signal("ui_profile_selector_profile_pressed")
			UPDATE:
				GlobalEvents.emit_signal("ui_button_pressed_to_prompt")
				GlobalEvents.emit_signal("ui_profile_selector_update_pressed")
				GlobalUI.menu = GlobalUI.Menus.PROFILE_SELECTOR_UPDATE_PROMPT


func _ui_play_pressed() -> void:
	yield(get_tree(), "physics_frame")
	update_buttons()
	if my_index == 0:
		grab_focus()


func _ui_profile_selector_profile_pressed() -> void:
	disabled = true


func _ui_profile_selector_manage_pressed() -> void:
	yield(profile_selector, "animation_finished")
	update_buttons()

	if my_index == 0:

		grab_focus()


func _ui_profile_selector_return_pressed() -> void:
	yield(profile_selector, "animation_finished")
	update_buttons()


func _ui_profile_selector_delete_prompt_yes_pressed() -> void:
	yield(GlobalEvents, "ui_faded")
	update_buttons()


func _ui_profile_selector_update_prompt_yes_pressed() -> void:
	update_buttons()
	if my_index == GlobalUI.profile_index:

		grab_focus()


func _focus_entered() -> void:
	GlobalUI.profile_index_focus = my_index
	GlobalEvents.emit_signal("ui_profile_focus_index_changed")


func _button_hovered() -> void:
	GlobalEvents.emit_signal("ui_button_hovered")
