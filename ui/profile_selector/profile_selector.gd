extends Control

signal animation_finished()

onready var return_button: Button = $Panel/Buttons/ReturnToMenu
onready var manage_button: Button = $Panel/Buttons/ManageProfiles
onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var label: Label = $Panel/VBoxContainer/Label
onready var profile_buttons = get_node("Panel/VBoxContainer/ProfileButtons").get_children()


func _ready() -> void:
	animation_player.connect("animation_finished", self, "_animation_finished")
	return_button.connect("pressed", self, "_return_pressed")
	manage_button.connect("pressed", self, "_manage_pressed")
	UI.connect("changed", self, "_ui_changed")
	UI.connect("profile_focus_index_changed", self, "_ui_profile_focus_index_changed")
	Signals.connect("profile_deleted", self, "_profile_deleted")
	update_manage_button()
	hide()


func _animation_finished(_anim_name: String) -> void:
	emit_signal("animation_finished")


func _ui_changed(menu: int) -> void:
	match menu:
		UI.PROFILE_SELECTOR:
			if UI.last_menu == UI.MAIN_MENU:
				return_button.focus_neighbour_top = profile_buttons[1].get_path()
				yield(UI, "faded")
				UI.menu_transitioning = true
				profile_buttons[0].grab_focus()
				yield(UI, "faded")
				show()
				enable_buttons()
				update_manage_button()
				animation_player.play("show")
				UI.menu_transitioning = false
			elif UI.last_menu == UI.PROFILE_SELECTOR_DELETE:
				disable_buttons()
				UI.menu_transitioning = true
				animation_player.play_backwards("show")
				yield(animation_player, "animation_finished")
				update_manage_button()
				label.text = "Select a Profile..."
				animation_player.play("show")
				return_button.text = "Return to Main Menu"
				UI.menu_transitioning = false
				enable_buttons()
				if update_manage_button():
					manage_button.grab_focus()
				else:
					return_button.grab_focus()
			elif UI.last_menu == UI.PROFILE_SELECTOR_UPDATE_PROMPT:
				enable_buttons()
		UI.MAIN_MENU, UI.NONE:
			if UI.last_menu == UI.PROFILE_SELECTOR:
				disable_buttons()
				animation_player.play_backwards("show")
				yield(UI, "faded")
				hide()
		UI.PROFILE_SELECTOR_DELETE:
			if UI.last_menu == UI.PROFILE_SELECTOR:
				disable_buttons()
				UI.menu_transitioning = true
				animation_player.play_backwards("show")
				update_manage_button()
				yield(animation_player, "animation_finished")
				label.text = "Manage Profiles..."
				animation_player.play("show")
				enable_buttons()
				return_button.text = "Return to Profile Selector"
				manage_button.hide()
				return_button.grab_focus()
				yield(animation_player, "animation_finished")
				UI.menu_transitioning = false
			elif UI.last_menu == UI.PROFILE_SELECTOR_DELETE_PROMPT:
				if UI.prompt_no:
					enable_buttons()
					get_node(
				"Panel/VBoxContainer/ProfileButtons/ProfileButton%s" % (
						UI.profile_index_focus + 1)).grab_focus()
				else:
					yield(UI, "faded")

					enable_buttons()
					return_button.grab_focus()

		UI.PROFILE_SELECTOR_DELETE_PROMPT, UI.PROFILE_SELECTOR_UPDATE_PROMPT:
			disable_buttons()


func disable_buttons() -> void:
	return_button.disabled = true
	manage_button.disabled = true
	for button in profile_buttons:
		button.disabled = true


func enable_buttons() -> void:
	return_button.disabled = false
	manage_button.disabled = false
	for button in profile_buttons:
		button.disabled = false


func update_manage_button() -> bool:
	if PlayerStats.data.hash() == PlayerStats.no_data_hash:
		manage_button.hide()
		return false
	else:
		manage_button.show()
		return true


func _ui_profile_focus_index_changed() -> void:
	if UI.current_menu == UI.PROFILE_SELECTOR:
		return_button.focus_neighbour_top = get_node(
				"Panel/VBoxContainer/ProfileButtons/ProfileButton%s" % (
						UI.profile_index_focus + 1)).get_path()
	if UI.current_menu == UI.PROFILE_SELECTOR:
		manage_button.focus_neighbour_top = get_node(
				"Panel/VBoxContainer/ProfileButtons/ProfileButton%s" % (
						UI.profile_index_focus + 1)).get_path()


func _profile_deleted() -> void:
	if UI.current_menu == UI.PROFILE_SELECTOR_DELETE_PROMPT or UI.current_menu == UI.PROFILE_SELECTOR_DELETE:
		return_button.focus_neighbour_top = get_node(
				"Panel/VBoxContainer/ProfileButtons/ProfileButton%s" % (
						UI.profile_index + 1)).get_path()
		manage_button.focus_neighbour_top = get_node(
				"Panel/VBoxContainer/ProfileButtons/ProfileButton%s" % (
						UI.profile_index + 1)).get_path()


func _return_pressed() -> void:
	if UI.menu_transitioning: return
	UI.emit_signal("button_pressed", true)
	if UI.current_menu == UI.PROFILE_SELECTOR:
		UI.emit_signal("changed", UI.MAIN_MENU)
	elif UI.current_menu == UI.PROFILE_SELECTOR_DELETE:
		UI.emit_signal("changed", UI.PROFILE_SELECTOR)


func _manage_pressed() -> void:
	UI.emit_signal("button_pressed")
	UI.emit_signal("changed", UI.PROFILE_SELECTOR_DELETE)
