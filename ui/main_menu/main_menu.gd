extends Control


onready var menu_buttons: VBoxContainer = $MenuButtons
onready var play_button: Button = $MenuButtons/Play
onready var quick_play_button: Button = $MenuButtons/QuickPlay
onready var settings_button: Button = $MenuButtons/Settings
onready var quit_button: Button = $MenuButtons/Quit
onready var camera: Camera2D = $Camera2D
onready var previous_button_focus: Button = play_button

onready var bg_color: Panel = $CanvasLayerBack/BGColor
onready var parallax_layers := [$ParallaxBackground/ParallaxLayer,
$ParallaxBackground/ParallaxLayer2, $ParallaxBackground/ParallaxLayer3]


func _ready() -> void:
	var __: int
	__ = UI.connect("changed", self, "_ui_changed")
	__ = UI.connect("faded", self, "_ui_faded")
	__ = play_button.connect("pressed", self, "_play_pressed")
	__ = quick_play_button.connect("pressed", self, "_quick_play_pressed")
	__ = settings_button.connect("pressed", self, "_on_settings_pressed")
	__ = quit_button.connect("pressed", self, "_quit_pressed")

	# Set camera perspective to be zoomed in
	camera.current = true
	yield(get_tree(), "idle_frame")
	camera.current = false

	play_button.grab_focus()
	update_menu()


func _ui_changed(menu: int) -> void:
	match menu:
		UI.MAIN_MENU:
			enable_buttons()
			update_menu()
			match UI.last_menu:
				UI.PROFILE_SELECTOR, UI.PAUSE_MENU_RETURN_PROMPT:
					if Globals.game_state == Globals.GameStates.MENU:
						yield(UI, "faded")
						show()
						enable_buttons()
						Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
					play_button.grab_focus()
				UI.MAIN_MENU_QUICK_PLAY:
					quick_play_button.grab_focus()
				UI.MAIN_MENU_SETTINGS:
					settings_button.grab_focus()
				UI.MAIN_MENU_QUIT_PROMPT:
					previous_button_focus.grab_focus()


		UI.MAIN_MENU_QUICK_PLAY,\
		UI.MAIN_MENU_SETTINGS,\
		UI.MAIN_MENU_QUIT_PROMPT:
			for button in menu_buttons.get_children():
				if button.has_focus():
					previous_button_focus = button
					continue
			disable_buttons()
#		UI.PROFILE_SELECTOR, UI.NONE:
#			hide_menu()
		UI.PROFILE_SELECTOR, UI.NONE:
			if UI.last_menu == UI.MAIN_MENU_QUICK_PLAY or \
					UI.last_menu == UI.PROFILE_SELECTOR or \
					UI.last_menu == UI.MAIN_MENU:
				hide_menu()

#
#func _process(delta: float) -> void:
#	if Input.is_key_pressed(KEY_K):
#		update_menu()


func _ui_faded() -> void:
	update_menu()
	if not Globals.game_state == Globals.GameStates.MENU:
		bg_color.hide()
		for bg in parallax_layers:
			bg.hide()
	else:
		bg_color.show()
		for bg in parallax_layers:
			bg.show()


func hide_menu() -> void:
	disable_buttons()
	yield(UI, "faded")
	hide()


func disable_buttons() -> void:
	play_button.disabled = true
	quick_play_button.disabled = true
	settings_button.disabled = true
	quit_button.disabled = true
	Signals.emit_signal("social_disabled")


func enable_buttons() -> void:
	play_button.disabled = false
	quick_play_button.disabled = false
	settings_button.disabled = false
	quit_button.disabled = false
	Signals.emit_signal("social_enabled")


func update_menu() -> void:
	QuickPlay.update_stats()
	if QuickPlay.available:
		quick_play_button.show()
	else:
		quick_play_button.hide()


func _play_pressed() -> void:
	if UI.menu_transitioning: return
	UI.emit_signal("button_pressed")
	UI.emit_signal("changed", UI.PROFILE_SELECTOR)


func _quick_play_pressed() -> void:
	if UI.menu_transitioning: return
	UI.emit_signal("button_pressed")
	UI.emit_signal("changed", UI.MAIN_MENU_QUICK_PLAY)


func _on_settings_pressed() -> void:
	if UI.menu_transitioning: return
	UI.emit_signal("button_pressed")
	UI.emit_signal("changed", UI.MAIN_MENU_SETTINGS)


func _quit_pressed() -> void:
	if UI.menu_transitioning: return
	UI.emit_signal("button_pressed")
	UI.emit_signal("changed", UI.MAIN_MENU_QUIT_PROMPT)
