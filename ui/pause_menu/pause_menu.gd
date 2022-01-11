extends Control


onready var continue_button: Button = $PauseButtons/Continue
onready var return_button: Button = $PauseButtons/Return
onready var settings_button: Button = $PauseButtons/Settings
onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var level_label: Label = $LevelLabelCenter/LevelLabel
onready var world_icons: VBoxContainer = $LevelLabelCenter/Control/WorldIcons


func _ready() -> void:
	var __: int
	__ = GlobalEvents.connect("level_changed", self, "_level_changed")
	__ = GlobalEvents.connect("ui_settings_back_pressed", self, "_ui_settings_back_pressed")
	__ = GlobalEvents.connect("ui_pause_menu_return_prompt_no_pressed", self, "_ui_pause_menu_return_prompt_no_pressed")
	__ = GlobalEvents.connect("ui_pause_menu_return_prompt_yes_pressed", self, "_ui_pause_menu_return_prompt_yes_pressed")
	__ = continue_button.connect("pressed", self, "_continue_pressed")
	__ = settings_button.connect("pressed", self, "_settings_pressed")
	__ = return_button.connect("pressed", self, "_return_pressed")

	for button in $PauseButtons.get_children():
		__ = button.connect("focus_entered", self, "_button_hovered")
		__ = button.connect("mouse_entered", self, "_button_hovered")

	pause_mode = PAUSE_MODE_PROCESS
	disable_buttons()
	hide()


func _input(event: InputEvent) -> void:
	if (event.is_action_pressed("pause") or (event.is_action_pressed("ui_cancel") and GlobalUI.menu == GlobalUI.Menus.PAUSE_MENU)) and not GlobalUI.menu_locked:
		if GlobalUI.menu == GlobalUI.Menus.NONE and not GlobalUI.fade_player_playing:
			show_menu()
			GlobalEvents.emit_signal("ui_button_pressed")
			GlobalEvents.emit_signal("ui_pause_menu_pressed")
			get_tree().set_input_as_handled()
		elif GlobalUI.menu == GlobalUI.Menus.PAUSE_MENU and not GlobalUI.fade_player_playing:
			hide_menu()
			GlobalEvents.emit_signal("ui_button_pressed", true)
			GlobalEvents.emit_signal("ui_pause_menu_continue_pressed")
			get_tree().set_input_as_handled()


func show_menu() -> void:
	return_button.set_focus_mode(true)
	continue_button.set_focus_mode(true)
	settings_button.set_focus_mode(true)
	continue_button.focus_neighbour_bottom = settings_button.get_path()
	settings_button.focus_neighbour_bottom = return_button.get_path()
	return_button.focus_neighbour_bottom = continue_button.get_path()

	continue_button.focus_neighbour_top = return_button.get_path()
	settings_button.focus_neighbour_top = continue_button.get_path()
	return_button.focus_neighbour_top = settings_button.get_path()

	yield(get_tree(), "physics_frame")
	continue_button.grab_focus()
	GlobalUI.menu = GlobalUI.Menus.PAUSE_MENU
	get_tree().paused = true

	if Globals.game_state == Globals.GameStates.LEVEL:
		for w_icon in world_icons.get_children():
			if int(w_icon.name) == GlobalLevel.current_world:
				world_icons.show()
				w_icon.show()
			else:
				w_icon.hide()
	else:
		for w_icon in world_icons.get_children():
			if int(w_icon.name) == int(GlobalSave.get_stat("world_max")):
				world_icons.show()
				w_icon.show()
			else:
				w_icon.hide()

	enable_buttons()
	show()

	if Globals.game_state == Globals.GameStates.LEVEL:
		return_button.text = tr("pause_menu.return_level")
	else:
		level_label.text = "%s %s" % [tr("pause_menu.profile"), GlobalSave.profile + 1]
		return_button.text = tr("pause_menu.return")

	animation_player.play("pause")

	continue_button.grab_focus()


func hide_menu(wait_for_fade: bool = false) -> void:
	return_button.enabled_focus_mode = false
	continue_button.enabled_focus_mode = false
	settings_button.enabled_focus_mode = false

	GlobalUI.menu = GlobalUI.Menus.NONE
	disable_buttons()
	animation_player.play_backwards("pause")

	if wait_for_fade:
		GlobalUI.menu_locked = true
		yield(GlobalEvents, "ui_faded")

	get_tree().paused = false
	GlobalUI.menu_locked = false

	if not animation_player.is_playing():
		hide()
		$ColorRect/BGBlur.hide()


func enable_buttons() -> void:
	continue_button.disabled = false
	settings_button.disabled = false
	return_button.disabled = false


func disable_buttons() -> void:
	continue_button.disabled = true
	settings_button.disabled = true
	return_button.disabled = true


func _level_changed(world: int, level: int) -> void:
	if GlobalUI.menu == GlobalUI.Menus.PAUSE_MENU:
		hide_menu()
	yield(GlobalEvents, "ui_faded")
	yield(get_tree(), "idle_frame")
	level_label.show()
	level_label.text = "%s %s\n %s - %s" % [tr("pause_menu.profile"), GlobalSave.profile + 1, GlobalLevel.WORLD_NAMES[world], level]


func _ui_settings_back_pressed() -> void:
	if GlobalUI.menu_locked: return
	if not Globals.game_state == Globals.GameStates.MENU:

		enable_buttons()
		settings_button.grab_focus()


func _ui_pause_menu_return_prompt_no_pressed() -> void:
	if GlobalUI.menu_locked: return
	enable_buttons()

	return_button.grab_focus()


func _ui_pause_menu_return_prompt_yes_pressed() -> void:
	hide()
	$ColorRect/BGBlur.hide()


func _continue_pressed() -> void:
	if GlobalUI.menu_locked: return
	continue_button.release_focus()
	GlobalEvents.emit_signal("ui_button_pressed", true)
	GlobalEvents.emit_signal("ui_pause_menu_continue_pressed")
	hide_menu()


func _settings_pressed() -> void:
	if GlobalUI.menu_locked: return
	settings_button.release_focus()
	GlobalUI.menu = GlobalUI.Menus.SETTINGS
	GlobalEvents.emit_signal("ui_button_pressed")
	GlobalEvents.emit_signal("ui_settings_pressed")
	disable_buttons()


func _return_pressed() -> void:
	if GlobalUI.menu_locked: return
	return_button.release_focus()
	GlobalUI.menu = GlobalUI.Menus.RETURN_PROMPT
	GlobalEvents.emit_signal("ui_button_pressed_to_prompt")
	GlobalEvents.emit_signal("ui_pause_menu_return_pressed")
	disable_buttons()
	return_button.release_focus()


func _button_hovered() -> void:
	if GlobalUI.menu == GlobalUI.Menus.PAUSE_MENU:
		GlobalEvents.emit_signal("ui_button_hovered")
