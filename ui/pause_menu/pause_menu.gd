extends Control

onready var main: Main = get_tree().root.get_node("Main")
onready var continue_button: Button = $PauseButtons/Continue
onready var return_button: Button = $PauseButtons/Return
onready var settings_button: Button = $PauseButtons/Settings
onready var world_selector_button: Button = $PauseButtons/SelectWorld
onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var level_label: Label = $LevelLabelCenter/LevelLabel
onready var world_icons: VBoxContainer = $LevelLabelCenter/Control/WorldIcons

func _ready():
	pause_mode = PAUSE_MODE_PROCESS
	continue_button.connect("pressed", self, "_continue_pressed")
	settings_button.connect("pressed", self, "_settings_pressed")
	return_button.connect("pressed", self, "_return_pressed")
	UI.connect("changed", self, "_ui_changed")
	Signals.connect("level_changed", self, "_level_changed")
	disable_buttons()
	hide()
	level_label.hide()


func _ui_changed(menu: int) -> void:
	match menu:
		UI.NONE:
			if UI.last_menu == UI.PAUSE_MENU:
				hide_menu()
			elif UI.last_menu == UI.PAUSE_MENU_RETURN_PROMPT:
				yield(UI, "faded")
				hide_menu(false, true)
		UI.PAUSE_MENU:
			if UI.last_menu == UI.NONE:
				show_menu()
			else:
				enable_buttons()
				match UI.last_menu:
					UI.PAUSE_MENU_SETTINGS:
						settings_button.grab_focus()
					UI.PAUSE_MENU_RETURN_PROMPT:
						return_button.grab_focus()
					_:
						continue_button.grab_focus()
		UI.PAUSE_MENU_RETURN_PROMPT:
			disable_buttons()
		UI.MAIN_MENU:
			if UI.last_menu == UI.PAUSE_MENU_RETURN_PROMPT:
				hide_menu(false, true)


func show_menu() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	for w_icon in world_icons.get_children():
		if int(w_icon.name) == LevelController.current_world:
			world_icons.show()
			w_icon.show()
		else:
			w_icon.hide()
	UI.menu_transitioning = true
	enable_buttons()
	show()
	if Globals.game_state == Globals.GameStates.LEVEL:
		level_label.show()
		return_button.text = "Exit Level"
	else:
		level_label.hide()
		return_button.text = "Return to Menu"
	animation_player.play("pause")
	get_tree().paused = true
	continue_button.grab_focus()
	yield(animation_player, "animation_finished")
	UI.menu_transitioning = false


func hide_menu(unpause_game: bool = true, wait_for_fade: bool = false) -> void:
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	UI.menu_transitioning = true
	animation_player.play_backwards("pause")
	disable_buttons()
	if not animation_player.is_playing():
		yield(animation_player, "animation_finished")
	if not Globals.dialog_active:
		if wait_for_fade:
			yield(UI, "faded")
		get_tree().paused = false
	UI.menu_transitioning = false
	if not animation_player.is_playing():
		hide()


func enable_buttons() -> void:
	continue_button.disabled = false
	settings_button.disabled = false
	world_selector_button.disabled = false
	return_button.disabled = false


func disable_buttons() -> void:
	continue_button.disabled = true
	settings_button.disabled = true
	world_selector_button.disabled = true
	return_button.disabled = true


func _continue_pressed() -> void:
	UI.emit_signal("button_pressed")
	UI.emit_signal("changed", UI.NONE)


func _settings_pressed() -> void:
	UI.emit_signal("button_pressed")
	UI.emit_signal("changed", UI.PAUSE_MENU_SETTINGS)


func _return_pressed() -> void:
	UI.emit_signal("button_pressed")
	UI.emit_signal("changed", UI.PAUSE_MENU_RETURN_PROMPT)


func _level_changed(world: int, level: int) -> void:
	yield(UI, "faded")
	yield(get_tree(), "idle_frame")
	level_label.show()
	level_label.text = "%s - %s" % [main.world_names[world], level]
