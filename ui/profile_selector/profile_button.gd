extends Button

enum {
	LOAD
	CREATE
	UPDATE
}

export var my_index: = 0
export var profile_selector_path: NodePath

var button_type: int = 0
var verify_failed: bool = false

onready var stats: VBoxContainer = $Stats
onready var button_text: Label = $Text

onready var health_label: Label = $Stats/HBoxContainer/Text/Heart/Label
onready var coin_label: Label = $Stats/HBoxContainer/Text/Coin/Label
onready var orb_label: Label = $Stats/HBoxContainer/Text/Orb/Label
onready var adrenaline_label: Label = $Stats/HBoxContainer/Text/Adrenaline/Label
onready var profile_selector: Control = get_node(profile_selector_path)
onready var world_icons: VBoxContainer = $HBoxContainer/WorldIcons
onready var rank_icons: VBoxContainer = $HBoxContainer/RankIcons


func _ready() -> void:
	var __: int
	__ = UI.connect("changed", self, "_ui_changed")
	__ = Signals.connect("profile_updated", self, "_profile_updated")
	__ = connect("pressed", self, "button_pressed")
	__ = connect("focus_entered", self, "_focus_entered")
	update_buttons()


func _ui_changed(menu: int) -> void:
	match menu:
		UI.PROFILE_SELECTOR:
			if UI.last_menu == UI.MAIN_MENU:
				update_buttons()
				yield(UI, "faded")
				yield(UI, "faded")
				if my_index == 0:
					grab_focus()
			elif UI.last_menu == UI.PROFILE_SELECTOR_DELETE:
				if my_index == 4:
					focus_neighbour_bottom = profile_selector.manage_button.get_path()
				yield(profile_selector, "animation_finished")
				update_buttons()
		UI.PROFILE_SELECTOR_DELETE:
			if UI.last_menu == UI.PROFILE_SELECTOR:
				yield(profile_selector, "animation_finished")
				update_buttons()
			elif UI.last_menu == UI.PROFILE_SELECTOR_DELETE_PROMPT:
				yield(UI, "faded")
				update_buttons()



func update_buttons() -> void:
	match UI.current_menu:
		UI.PROFILE_SELECTOR_DELETE:
			if my_index == 4:
				focus_neighbour_bottom = profile_selector.return_button.get_path()
		UI.PROFILE_SELECTOR:
			if my_index == 4:
				focus_neighbour_bottom = profile_selector.manage_button.get_path()

	if PlayerStats.data[my_index].size() == 0:
		button_type = CREATE
		match UI.current_menu:
			UI.PROFILE_SELECTOR:
				button_text.text = "New Game"
				button_text.show()
				button_text.modulate = Color8(255, 255, 85)
				stats.hide()
				world_icons.hide()
				rank_icons.hide()
			UI.PROFILE_SELECTOR_DELETE:
				stats.hide()
				button_text.hide()
				world_icons.hide()
				rank_icons.hide()
	elif not PlayerStats.verify(my_index):
		button_type = UPDATE
		match UI.current_menu:
			UI.PROFILE_SELECTOR:
				button_text.modulate = Color8(255, 255, 85)
				button_text.text = "Update\nRequired!"
				stats.hide()
				world_icons.hide()
				rank_icons.hide()
			UI.PROFILE_SELECTOR_DELETE:
				button_text.text = "Delete\nOutdated\nProfile %s" % (my_index + 1)
				button_text.modulate = Color8(255, 0, 0)
				stats.hide()
				world_icons.hide()
				rank_icons.hide()
		button_text.show()
	else:
		button_type = LOAD
		match UI.current_menu:
			UI.PROFILE_SELECTOR:
				button_text.text = "Profile %s" % (my_index + 1)
				health_label.text = "%s | %s" % [PlayerStats.data[my_index].health, PlayerStats.data[my_index].health_max]
				coin_label.text = str(PlayerStats.data[my_index].coins)
				orb_label.text = str(PlayerStats.data[my_index].orbs)
				adrenaline_label.text = "%s | %s" % [PlayerStats.data[my_index].adrenaline, PlayerStats.data[my_index].adrenaline_max]
				button_text.modulate = Color8(255, 255, 255)
				for texture in rank_icons.get_children():
					if texture.name.to_lower() == PlayerStats.ranks[PlayerStats.data[my_index].rank]:
						rank_icons.show()
						texture.show()
					else:
						texture.hide()
				for w_icon in world_icons.get_children():
					if int(w_icon.name) == PlayerStats.data[my_index].world_max:
						world_icons.show()
						w_icon.show()
					else:
						w_icon.hide()
			UI.PROFILE_SELECTOR_DELETE:
				button_text.text = "Delete\nProfile %s" % (my_index + 1)
				button_text.modulate = Color8(255, 0, 0)
		stats.show()
		button_text.show()
	#disabled = false


func button_pressed() -> void:
	if UI.menu_transitioning: return
	UI.emit_signal("button_pressed")
	if UI.current_menu == UI.PROFILE_SELECTOR_DELETE:
		if not button_type == CREATE:
			if not button_text.visible:
				return
			else:
				UI.profile_index = my_index
			UI.emit_signal("changed", UI.PROFILE_SELECTOR_DELETE_PROMPT)
		else:
			return
	else:
			match button_type:
				CREATE:
					Signals.emit_signal("new_save_file", my_index)
					button_type = LOAD
					button_pressed()
				LOAD:
					PlayerStats.current_save_profile = my_index
					UI.emit_signal("changed", UI.NONE)
				UPDATE:
					UI.profile_index = my_index
					verify_failed = false
					UI.emit_signal("changed", UI.PROFILE_SELECTOR_UPDATE_PROMPT)


func _focus_entered() -> void:
	UI.profile_index_focus = my_index
	UI.emit_signal("profile_focus_index_changed")


func _profile_updated() -> void:
	update_buttons()
	if my_index == UI.profile_index:
		grab_focus()
#	if UI.profile_index == my_index:
#		button_pressed()

