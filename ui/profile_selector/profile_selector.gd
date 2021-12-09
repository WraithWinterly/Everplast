extends Control

signal animation_finished()

const PROFILE_BUTTON_PATH := "Panel/VBoxContainer/ProfileButtons/ProfileButton"

onready var return_button: Button = $Panel/Buttons/ReturnToMenu
onready var manage_button: Button = $Panel/Buttons/ManageProfiles
onready var anim_player: AnimationPlayer = $AnimationPlayer
onready var label: Label = $Panel/Label
onready var profile_buttons = get_node("Panel/BG/VBoxContainer/ProfileButtons").get_children()

onready var bg_color: Panel = $Background/CanvasLayerBack/Top
onready var parallax_layers := [$Background/ParallaxLayer, $Background/ParallaxLayer2,
								$Background/ParallaxLayer3]


func _ready() -> void:
	var __: int
	__ = GlobalEvents.connect("level_changed", self, "_level_changed")
	__ = GlobalEvents.connect("ui_play_pressed", self, "_ui_play_pressed")
	__ = GlobalEvents.connect("ui_profile_selector_profile_pressed", self, "_ui_profile_selector_profile_pressed")
	__ = GlobalEvents.connect("ui_profile_selector_delete_pressed", self, "_ui_profile_selector_delete_pressed")
	__ = GlobalEvents.connect("ui_profile_selector_delete_prompt_no_pressed", self, "_ui_profile_selector_delete_prompt_no_pressed")
	__ = GlobalEvents.connect("ui_profile_selector_delete_prompt_yes_pressed", self, "_ui_profile_selector_delete_prompt_yes_pressed")
	__ = GlobalEvents.connect("ui_profile_selector_update_pressed", self, "_ui_profile_selector_update_pressed")
	__ = GlobalEvents.connect("ui_profile_selector_update_prompt_no_pressed", self, "_ui_profile_selector_update_prompt_no_pressed")
	__ = GlobalEvents.connect("ui_profile_selector_update_prompt_yes_pressed", self, "_ui_profile_selector_update_prompt_yes_pressed")
	__ = GlobalEvents.connect("ui_profile_focus_index_changed", self, "_ui_profile_focus_index_changed")
	__ = anim_player.connect("animation_finished", self, "_animation_finished")
	__ = return_button.connect("pressed", self, "_return_pressed")
	__ = manage_button.connect("pressed", self, "_manage_pressed")
	__ = update_manage_button()

	hide()
	hide_canvas_bg()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and not GlobalUI.menu_locked:
		if GlobalUI.menu == GlobalUI.Menus.PROFILE_SELECTOR or GlobalUI.menu == GlobalUI.Menus.PROFILE_SELECTOR_DELETE:
			_return_pressed()
			get_tree().set_input_as_handled()




func show_menu() -> void:
	bg_color.show()
	for bg in parallax_layers:
		bg.show()
	yield(GlobalEvents, "ui_faded")
	show()
	anim_player.play("show")
	enable_buttons()
	setup()
	GlobalUI.profile_index = 0
	GlobalUI.profile_index_focus = 0
	return_button.focus_neighbour_top = profile_buttons[0].get_path()
	profile_buttons[0].grab_focus()


func setup(normal := true):
	if normal:
		var __: int = update_manage_button()
		return_button.grab_focus()
		anim_player.play("show")
		return_button.text = tr("profile_selector.return")
		label.text = tr("profile_selector.title")
	else:
		disable_buttons()
		GlobalUI.menu_locked = true
		anim_player.play_backwards("show")

		var __: int = update_manage_button()
		label.text = tr("profile_selector.title_manage")
		anim_player.play("show")
		enable_buttons()
		return_button.text = tr("profile_selector.return_manage")
		manage_button.hide()
		yield(anim_player, "animation_finished")
		enable_buttons()
		GlobalUI.menu_locked = false


func hide_menu() -> void:
	disable_buttons()
	anim_player.play_backwards("show")
	yield(GlobalEvents, "ui_faded")
	hide_canvas_bg()
	hide()


func hide_canvas_bg() -> void:
	bg_color.hide()
	for bg in parallax_layers:
		bg.hide()


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
	if GlobalSave.data.hash() == GlobalSave.no_data_hash:
		manage_button.hide()
		return false
	else:
		manage_button.show()
		return true


func grab_index_focus() -> void:
	get_node("Panel/BG/VBoxContainer/ProfileButtons/ProfileButton%s" % (GlobalUI.profile_index_focus + 1)).grab_focus()


func _level_changed(_world: int, _level: int) -> void:
	if GlobalUI.menu == GlobalUI.Menus.PROFILE_SELECTOR or GlobalUI.menu == GlobalUI.Menus.PROFILE_SELECTOR_DELETE:
		hide_menu()


func _ui_play_pressed() -> void:
	yield(GlobalEvents, "ui_faded")
	show_menu()


func _ui_profile_selector_profile_pressed() -> void:
	hide_menu()


func _ui_profile_selector_delete_pressed() -> void:
	disable_buttons()


func _ui_profile_selector_delete_prompt_no_pressed() -> void:
	enable_buttons()
	grab_index_focus()


func _ui_profile_selector_delete_prompt_yes_pressed() -> void:
	enable_buttons()
	grab_index_focus()


func _ui_profile_selector_update_pressed() -> void:
	disable_buttons()


func _ui_profile_selector_update_prompt_no_pressed() -> void:
	enable_buttons()
	grab_index_focus()


func _ui_profile_selector_update_prompt_yes_pressed() -> void:
	enable_buttons()
	grab_index_focus()


func _ui_profile_focus_index_changed() -> void:
	if GlobalUI.menu_locked: return
	if GlobalUI.menu == GlobalUI.Menus.PROFILE_SELECTOR:
		return_button.focus_neighbour_top = get_node(
				"Panel/BG/VBoxContainer/ProfileButtons/ProfileButton%s" % (
						GlobalUI.profile_index_focus + 1)).get_path()
	elif GlobalUI.menu == GlobalUI.Menus.PROFILE_SELECTOR_DELETE:
		manage_button.focus_neighbour_top = get_node(
				"Panel/BG/VBoxContainer/ProfileButtons/ProfileButton%s" % (
						GlobalUI.profile_index_focus + 1)).get_path()


func _animation_finished(_anim_name: String) -> void:
	emit_signal("animation_finished")


func _return_pressed() -> void:
	if GlobalUI.menu_locked: return

	disable_buttons()

	GlobalEvents.emit_signal("ui_button_pressed", true)

	if GlobalUI.menu == GlobalUI.Menus.PROFILE_SELECTOR:
		GlobalEvents.emit_signal("ui_profile_selector_return_pressed")
		GlobalUI.menu = GlobalUI.Menus.MAIN_MENU
		hide_menu()
	elif GlobalUI.menu == GlobalUI.Menus.PROFILE_SELECTOR_DELETE:
		GlobalEvents.emit_signal("ui_button_pressed")
		GlobalEvents.emit_signal("ui_profile_selector_return_pressed")
		GlobalUI.menu = GlobalUI.Menus.PROFILE_SELECTOR
		anim_player.play_backwards("show")
		GlobalUI.menu_locked = true
		yield(anim_player, "animation_finished")
		setup()
		enable_buttons()
		anim_player.play("show")
		if update_manage_button():
			manage_button.grab_focus()
		else:
			return_button.grab_focus()
		GlobalUI.menu_locked = false


func _manage_pressed() -> void:
	disable_buttons()
	GlobalEvents.emit_signal("ui_button_pressed")
	GlobalUI.menu = GlobalUI.Menus.PROFILE_SELECTOR_DELETE
	GlobalEvents.emit_signal("ui_profile_selector_manage_pressed")
	anim_player.play_backwards("show")
	GlobalUI.menu_locked = true
	yield(anim_player, "animation_finished")
	setup(false)
	anim_player.play("show")
	GlobalUI.menu_locked = false
