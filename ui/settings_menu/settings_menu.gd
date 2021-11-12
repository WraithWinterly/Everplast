extends Control

const FILE: String = \
	"user://settings.json"

var default_data: Dictionary = {
	"show_social": true,
	"profile_pause": true,
	"aa_level": 1.0,
	"vsync": true,
	"tonemap": 3.0,
	"fullscreen": true,
	"audio_enabled": true,
	"audio_value": 100.0,
	"music_enabled": true,
	"music_value": 100.0,
	"cheats": false,
}

var data: Dictionary = {}

var in_category: bool = false
var side_panel_focus: Button = null
var button_focus: Button = null

onready var subcategory: Label = $Panel/BG/Subcategory
onready var subcategory_anim_player: AnimationPlayer = $Panel/BG/Subcategory/AnimationPlayer

#
# GENERAL MENU
#
onready var general_buttons: VBoxContainer = $Panel/BG/GeneralMenu/HBoxContainer
onready var social_button: Button = $Panel/BG/GeneralMenu/HBoxContainer/SocialMedia
onready var profile_pause_button: Button = $Panel/BG/GeneralMenu/HBoxContainer/ProfilePause
onready var credits_button: Button = $Panel/BG/GeneralMenu/HBoxContainer/Credits
onready var audio_volume_button: Button = $Panel/BG/GeneralMenu/HBoxContainer/AudioVolume
onready var audio_volume_slider: HSlider = $Panel/BG/GeneralMenu/HBoxContainer/AudioSlider/Slider
onready var audio_volume_label: Label = $Panel/BG/GeneralMenu/HBoxContainer/AudioSlider/Value
onready var music_volume_button: Button = $Panel/BG/GeneralMenu/HBoxContainer/MusicVolume
onready var music_volume_slider: HSlider = $Panel/BG/GeneralMenu/HBoxContainer/MusicSlider/Slider
onready var music_volume_label: Label = $Panel/BG/GeneralMenu/HBoxContainer/MusicSlider/Value
onready var audio_slider: HBoxContainer = $Panel/BG/GeneralMenu/HBoxContainer/AudioSlider
onready var music_slider: HBoxContainer = $Panel/BG/GeneralMenu/HBoxContainer/MusicSlider

#
# GRAPHICS MENU
#
onready var graphics_buttons: VBoxContainer = $Panel/BG/GraphicsMenu/HBoxContainer
onready var fullscreen_button: Button = $Panel/BG/GraphicsMenu/HBoxContainer/Fullscreen
onready var aa_button: Button = $Panel/BG/GraphicsMenu/HBoxContainer/AA
onready var vsync_button: Button = $Panel/BG/GraphicsMenu/HBoxContainer/VSync
onready var tonemap_button: Button = $Panel/BG/GraphicsMenu/HBoxContainer/Tonemap

#
# CONTROLS MENU
#
onready var controls_buttons: VBoxContainer = $Panel/BG/ControlsMenu/HBoxContainer
onready var controls_test_button: Button = $Panel/BG/ControlsMenu/HBoxContainer/Test
#
# OTHER MENU
#
onready var other_buttons: VBoxContainer = $Panel/BG/OtherMenu/HBoxContainer
onready var debug_button: Button = $Panel/BG/OtherMenu/HBoxContainer/DebugConsole
onready var erase_button: Button = $Panel/BG/OtherMenu/HBoxContainer/EraseGame

#
# SIDE PANEL
#
onready var side_panel: VBoxContainer = $Panel/SidePanel/HBoxContainer
onready var general_menu_button: Button = $Panel/SidePanel/HBoxContainer/General
onready var graphics_menu_button: Button = $Panel/SidePanel/HBoxContainer/Graphics
onready var controls_menu_button: Button = $Panel/SidePanel/HBoxContainer/Controls
onready var other_menu_button: Button = $Panel/SidePanel/HBoxContainer/Other
onready var general_anim_player: AnimationPlayer = $Panel/BG/GeneralMenu/AnimationPlayer
onready var graphics_anim_player: AnimationPlayer = $Panel/BG/GraphicsMenu/AnimationPlayer
onready var controls_anim_player: AnimationPlayer = $Panel/BG/ControlsMenu/AnimationPlayer
onready var other_anim_player: AnimationPlayer = $Panel/BG/OtherMenu/AnimationPlayer

onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var back_button: Button = $Panel/SidePanel/HBoxContainer/Back


func _ready() -> void:
	var __: int
	__ = UI.connect("changed", self, "_ui_changed")
	__ = Signals.connect("erase_all_started", self, "_erase_all_started")
	__ = Signals.connect("erase_all_confirmed", self, "_erase_all_confirmed")
	__ = Signals.connect("debug_enable_started", self, "_debug_enable_started")
	__ = Signals.connect("debug_enable_confirmed", self, "_debug_enable_confirmed")
	__ = general_menu_button.connect("pressed", self, "_general_pressed")
	__ = graphics_menu_button.connect("pressed", self, "_graphics_pressed")
	__ = controls_menu_button.connect("pressed", self, "_controls_pressed")
	__ = other_menu_button.connect("pressed", self, "_other_pressed")
	__ = social_button.connect("pressed", self, "_social_button_pressed")
	__ = profile_pause_button.connect("pressed", self, "_profile_pause_button_pressed")
	__ = credits_button.connect("pressed", self, "_credits_button_pressed")
	__ = audio_volume_button.connect("pressed", self, "_audio_volume_button_pressed")
	__ = audio_volume_slider.connect("value_changed", self, "_audio_volume_changed")
	__ = music_volume_button.connect("pressed", self, "_music_volume_button_pressed")
	__ = music_volume_slider.connect("value_changed", self, "_music_volume_changed")
	__ = fullscreen_button.connect("pressed", self, "_fullscreen_button_pressed")
	__ = aa_button.connect("pressed", self, "_aa_button_pressed")
	__ = vsync_button.connect("pressed", self, "_vsync_button_pressed")
	__ = tonemap_button.connect("pressed", self, "_tonemap_button_pressed")
	__ = debug_button.connect("pressed", self, "_debug_button_pressed")
	__ = erase_button.connect("pressed", self, "_erase_button_pressed")
	__ = back_button.connect("pressed", self, "_back_pressed")

	load_stats()
	update_button_toggles()
	update_audio_toggle()
	update_music_toggle()
	update_toggle_buttons()
	update_aa_button_text()
	update_tonemap_button_text()
	update_audio_labels()

	apply_settings()
	hide()


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("fullscreen"):
		if OS.window_fullscreen:
			data.fullscreen = false
			OS.window_fullscreen = false
			fullscreen_changed()
		elif not OS.window_fullscreen:
			data.fullscreen = true
			OS.window_fullscreen = true
			fullscreen_changed()
		if not UI.current_menu == UI.MAIN_MENU_SETTINGS:
			save_settings()

		var file: File = File.new()
		var __: int = file.open(FILE, File.WRITE)
		file.store_string(to_json(data))
		file.close()


func update_audio_labels() -> void:
	music_volume_label.text = "Music Volume: %s" % data.music_value
	audio_volume_label.text = "Audio Volume: %s" % data.audio_value


func disable_side_panel_right_focus() -> void:
	for button in side_panel.get_children():
		button.focus_neighbour_right = button.get_path()


func update_button_toggles() -> void:
	social_button.pressed = data.show_social
	profile_pause_button.pressed = data.profile_pause
	fullscreen_button.pressed = data.fullscreen
	vsync_button.pressed = data.vsync
	audio_volume_button.pressed = data.audio_enabled
	audio_volume_slider.value = data.audio_value
	music_volume_button.pressed = data.music_enabled
	music_volume_slider.value = data.music_value


func show_menu() -> void:
	disable_side_panel_right_focus()
	subcategory_anim_player.play("slide")
	back_button.grab_focus()
	show()
	animation_player.play("show")

	enable_buttons()
	update_button_toggles()
	update_audio_toggle()
	update_music_toggle()
	update_toggle_buttons()
	update_audio_labels()
	update_aa_button_text()
	update_tonemap_button_text()

	if Globals.is_mobile:
		graphics_menu_button.hide()
		general_anim_player.focus_neighbour_bottom = controls_menu_button.get_path()
		controls_menu_button.focus_neighbour_top = general_menu_button.get_path()


func hide_menu() -> void:
	animation_player.play_backwards("show")
	disable_buttons()


func enable_buttons() -> void:
	general_menu_button.disabled = false
	graphics_menu_button.disabled = false
	controls_menu_button.disabled = false
	other_menu_button.disabled = false

	social_button.disabled = false
	credits_button.disabled = false
	audio_volume_button.disabled = false
	audio_volume_slider.show()
	music_volume_button.disabled = false
	music_volume_slider.show()

	fullscreen_button.disabled = false
	aa_button.disabled = false
	vsync_button.disabled = false
	tonemap_button.disabled = false


	erase_button.disabled = false

	back_button.disabled = false
	debug_button.disabled =  data.cheats
	other_menu_button.disabled = not (Globals.game_state == Globals.GameStates.MENU)


func disable_buttons() -> void:
	general_menu_button.disabled = true
	graphics_menu_button.disabled = true
	controls_menu_button.disabled = true
	other_menu_button.disabled = true

	social_button.disabled = true
	credits_button.disabled = true
	audio_volume_button.disabled = true
	audio_volume_slider.hide()
	music_volume_button.disabled = true
	music_volume_slider.hide()

	fullscreen_button.disabled = true
	aa_button.disabled = true
	vsync_button.disabled = true
	tonemap_button.disabled = true

	debug_button.disabled = true
	erase_button.disabled = true

	back_button.disabled = true


func load_stats() -> void:
	var file: File = File.new()
	if file.file_exists(FILE):
		var __: int = file.open(FILE, File.READ)
		var loaded_data = parse_json(file.get_as_text())
		file.close()
		var allow: bool = true
		if typeof(loaded_data) == TYPE_DICTIONARY:
			for i in default_data:
				if not loaded_data.has(i):
					allow = false
					continue
				elif not typeof(loaded_data[i]) == typeof(default_data[i]):
					allow = false
					continue
			if loaded_data.size() == default_data.size() and allow:
				data = loaded_data
			else:
				reset_file()
		else:
			reset_file()
	else:
		reset_file()


func reset_file() -> void:
	data = default_data
	var file: File = File.new()
	var __: int = file.open(FILE, File.WRITE)
	file.store_string(to_json(data))
	file.close()
	load_stats()


func save_settings() -> void:
	data.show_social = social_button.pressed
	data.profile_pause = profile_pause_button.pressed
	data.fullscreen = fullscreen_button.pressed
	data.vsync = vsync_button.pressed
	data.audio_enabled = audio_volume_button.pressed
	data.audio_value = float(audio_volume_slider.value)
	data.music_enabled = music_volume_button.pressed
	data.music_value = float(music_volume_slider.value)
	var file: File = File.new()
	var __: int = file.open(FILE, File.WRITE)
	file.store_string(to_json(data))
	file.close()


func apply_settings() -> void:
	update_toggle_buttons()
	yield(get_tree(), "physics_frame")
	save_settings()
	get_viewport().msaa = data.aa_level
	OS.window_fullscreen = data.fullscreen
	OS.vsync_enabled = data.vsync
	Globals.get_env().environment.tonemap_mode = data.tonemap
	if data.audio_enabled:
		AudioServer.set_bus_volume_db(2, get_db_value(data.audio_value))
	else:
		AudioServer.set_bus_volume_db(2, get_db_value(0))

	if data.music_enabled:
		AudioServer.set_bus_volume_db(1, get_db_value(data.music_value))
	else:
		AudioServer.set_bus_volume_db(1, get_db_value(0))
	Signals.emit_signal("settings_updated")


func get_db_value(db_level: float) -> float:
	db_level *= 0.01
	return linear2db(db_level)


func update_audio_toggle() -> void:
	if audio_volume_button.pressed:
		audio_volume_button.text = "Audio Volume: On"
		audio_slider.show()
		audio_volume_button.focus_neighbour_bottom = audio_volume_slider.get_path()
		audio_volume_button.focus_next = audio_volume_slider.get_path()
		music_volume_button.focus_neighbour_top = audio_volume_slider.get_path()
		music_volume_button.focus_previous = audio_volume_slider.get_path()
	else:
		audio_volume_button.text = "Audio Volume: Off"
		audio_slider.hide()
		audio_volume_button.focus_neighbour_bottom = music_volume_button.get_path()
		audio_volume_button.focus_next = music_volume_button.get_path()
		music_volume_button.focus_neighbour_top = audio_volume_button.get_path()
		music_volume_button.focus_previous = audio_volume_button.get_path()


func update_music_toggle() -> void:
	if music_volume_button.pressed:
		music_volume_button.text = "Music Volume: On"
		music_slider.show()
		music_volume_button.focus_neighbour_bottom = music_volume_slider.get_path()
		music_volume_button.focus_next = music_volume_slider.get_path()
		music_volume_slider.focus_neighbour_bottom = social_button.get_path()
		music_volume_slider.focus_next = social_button.get_path()
		social_button.focus_neighbour_top = music_volume_slider.get_path()
		social_button.focus_previous = music_volume_slider.get_path()
	else:
		music_volume_button.text = "Music Volume: Off"
		music_slider.hide()
		music_volume_button.focus_neighbour_bottom = social_button.get_path()
		music_volume_button.focus_next = social_button.get_path()
		social_button.focus_neighbour_top = music_volume_button.get_path()
		social_button.focus_previous = music_volume_button.get_path()


func update_toggle_buttons() -> void:
	if social_button.pressed:
		social_button.text = "Show Social Media: On"
	else:
		social_button.text = "Show Social Media: Off"
	if profile_pause_button.pressed:
		profile_pause_button.text = "Profile In Pause Screen: On"
	else:
		profile_pause_button.text = "Profile In Pause Screen: Off"
	if fullscreen_button.pressed:
		fullscreen_button.text = "Fullscreen Mode: On"
	else:
		fullscreen_button.text = "Fullscreen Mode: Off"
	if vsync_button.pressed:
		vsync_button.text = "Use VSync: On"
	else:
		vsync_button.text = "Use VSync: Off"
	if debug_button.pressed or debug_button.disabled:
		debug_button.text = "Debug Console: On"
	else:
		debug_button.text = "Debug Console: Off"


func fullscreen_changed() -> void:
	if OS.window_fullscreen and not fullscreen_button.pressed:
		fullscreen_button.pressed = true
	elif not OS.window_fullscreen and fullscreen_button.pressed:
		fullscreen_button.pressed = false
	update_toggle_buttons()


func _back_pressed() -> void:
	UI.emit_signal("button_pressed", true)
	match UI.current_menu:
		UI.MAIN_MENU_SETTINGS_GENERAL, UI.MAIN_MENU_SETTINGS_GRAPHICS, \
		UI.MAIN_MENU_SETTINGS_CONTROLS, UI.MAIN_MENU_SETTINGS_OTHER:
			UI.emit_signal("changed", UI.MAIN_MENU_SETTINGS)
		UI.PAUSE_MENU_SETTINGS_GENERAL, UI.PAUSE_MENU_SETTINGS_GRAPHICS, \
		UI.PAUSE_MENU_SETTINGS_CONTROLS:
			UI.emit_signal("changed", UI.PAUSE_MENU_SETTINGS)

	match UI.current_menu:
		UI.MAIN_MENU_SETTINGS:
			UI.emit_signal("changed", UI.MAIN_MENU)
		UI.PAUSE_MENU_SETTINGS:
			UI.emit_signal("changed", UI.PAUSE_MENU)


func _ui_changed(menu: int) -> void:
	var switched_not_closed: bool = false
	match menu:
		UI.MAIN_MENU_SETTINGS, UI.PAUSE_MENU_SETTINGS:
			if UI.last_menu == UI.MAIN_MENU or UI.last_menu == UI.PAUSE_MENU:
				show_menu()
			else:
				enable_buttons()
		UI.MAIN_MENU, UI.PAUSE_MENU:
			if UI.last_menu == UI.PAUSE_MENU_SETTINGS or \
					UI.last_menu == UI.MAIN_MENU_SETTINGS:
				hide_menu()
		UI.MAIN_MENU_SETTINGS_CREDITS, UI.PAUSE_MENU_SETTINGS_CREDITS:
			disable_buttons()

		UI.MAIN_MENU_SETTINGS_GENERAL, UI.PAUSE_MENU_SETTINGS_GENERAL:
			if not in_category:
				subcategory_anim_player.play_backwards("slide")
			in_category = true
			general_anim_player.play("slide")
			switched_not_closed = true
		UI.MAIN_MENU_SETTINGS_GRAPHICS, UI.PAUSE_MENU_SETTINGS_GRAPHICS:
			if not in_category:
				subcategory_anim_player.play_backwards("slide")
			in_category = true
			graphics_anim_player.play("slide")
			switched_not_closed = true
		UI.MAIN_MENU_SETTINGS_CONTROLS, UI.PAUSE_MENU_SETTINGS_CONTROLS:
			if not in_category:
				subcategory_anim_player.play_backwards("slide")
			in_category = true
			controls_anim_player.play("slide")

			switched_not_closed = true
		UI.MAIN_MENU_SETTINGS_OTHER:
			if not in_category:
				subcategory_anim_player.play_backwards("slide")
			in_category = true
			other_anim_player.play("slide")
			switched_not_closed = true

	match UI.last_menu:
		UI.MAIN_MENU_SETTINGS_GENERAL, UI.PAUSE_MENU_SETTINGS_GENERAL:
			general_anim_player.play_backwards("slide")
			if not switched_not_closed and (menu == UI.MAIN_MENU_SETTINGS or menu == UI.PAUSE_MENU_SETTINGS):
				in_category = false
				subcategory_anim_player.play("slide")
				general_menu_button.grab_focus()
				disable_side_panel_right_focus()
		UI.MAIN_MENU_SETTINGS_GRAPHICS, UI.PAUSE_MENU_SETTINGS_GRAPHICS:
			graphics_anim_player.play_backwards("slide")
			if not switched_not_closed and (menu == UI.MAIN_MENU_SETTINGS or menu == UI.PAUSE_MENU_SETTINGS):
				in_category = false
				subcategory_anim_player.play("slide")
				graphics_menu_button.grab_focus()
				disable_side_panel_right_focus()
		UI.MAIN_MENU_SETTINGS_CONTROLS, UI.PAUSE_MENU_SETTINGS_CONTROLS:
			controls_anim_player.play_backwards("slide")
			if not switched_not_closed and (menu == UI.MAIN_MENU_SETTINGS or menu == UI.PAUSE_MENU_SETTINGS):
				in_category = false
				subcategory_anim_player.play("slide")
				controls_menu_button.grab_focus()
				disable_side_panel_right_focus()
		UI.MAIN_MENU_SETTINGS_OTHER:
			other_anim_player.play_backwards("slide")
			if not switched_not_closed and (menu == UI.MAIN_MENU_SETTINGS or menu == UI.PAUSE_MENU_SETTINGS):
				in_category = false
				other_menu_button.grab_focus()
				subcategory_anim_player.play("slide")
				disable_side_panel_right_focus()
		UI.MAIN_MENU_SETTINGS_CREDITS, UI.PAUSE_MENU_SETTINGS_CREDITS:
			enable_buttons()
			credits_button.grab_focus()
		UI.MAIN_MENU_SETTINGS_ERASE_PROMPT, UI.MAIN_MENU_SETTINGS_ERASE_PROMPT_EVIL:
			erase_button.grab_focus()
			enable_buttons()
		UI.MAIN_MENU_SETTINGS_DEBUG_ENABLE_PROMPT, UI.MAIN_MENU_SETTINGS_DEBUG_ENABLE_EVIL_PROMPT:
			debug_button.grab_focus()
			enable_buttons()
			if data.cheats:
				debug_button.disabled = true


func _general_pressed() -> void:
	UI.emit_signal("button_pressed")
	side_panel_focus = general_menu_button
	for button in side_panel.get_children():
		button.focus_neighbour_right = social_button.get_path()
	button_focus = social_button
	if not (UI.current_menu == UI.MAIN_MENU_SETTINGS_GENERAL \
			or UI.current_menu == UI.PAUSE_MENU_SETTINGS_GENERAL):
		social_button.grab_focus()
		if Globals.game_state == Globals.GameStates.MENU:
			UI.emit_signal("changed", UI.MAIN_MENU_SETTINGS_GENERAL)
		else:
			UI.emit_signal("changed", UI.PAUSE_MENU_SETTINGS_GENERAL)
	update_left_button_focus()
	update_right_button_focus()


func _graphics_pressed() -> void:
	UI.emit_signal("button_pressed")
	side_panel_focus = graphics_menu_button
	for button in side_panel.get_children():
		button.focus_neighbour_right = fullscreen_button.get_path()
	button_focus = fullscreen_button
	if not (UI.current_menu == UI.MAIN_MENU_SETTINGS_GRAPHICS \
			or UI.current_menu == UI.PAUSE_MENU_SETTINGS_GRAPHICS):
		fullscreen_button.grab_focus()
		if Globals.game_state == Globals.GameStates.MENU:
			UI.emit_signal("changed", UI.MAIN_MENU_SETTINGS_GRAPHICS)
		else:
			UI.emit_signal("changed", UI.PAUSE_MENU_SETTINGS_GRAPHICS)
	update_left_button_focus()
	update_right_button_focus()


func _controls_pressed() -> void:
	UI.emit_signal("button_pressed")
	side_panel_focus = controls_menu_button
	for button in side_panel.get_children():
		button.focus_neighbour_right = controls_test_button.get_path()
	button_focus = controls_test_button
	if not (UI.current_menu == UI.MAIN_MENU_SETTINGS_CONTROLS \
			or UI.current_menu == UI.PAUSE_MENU_SETTINGS_CONTROLS):
		controls_test_button.grab_focus()
		if Globals.game_state == Globals.GameStates.MENU:
			UI.emit_signal("changed", UI.MAIN_MENU_SETTINGS_CONTROLS)
		else:
			UI.emit_signal("changed", UI.PAUSE_MENU_SETTINGS_CONTROLS)
	update_left_button_focus()
	update_right_button_focus()


func _other_pressed() -> void:
	UI.emit_signal("button_pressed")
	side_panel_focus = other_menu_button
	for button in side_panel.get_children():
		button.focus_neighbour_right = debug_button.get_path()
	button_focus = debug_button
	if not UI.current_menu == UI.MAIN_MENU_SETTINGS_OTHER:
		debug_button.grab_focus()
		if Globals.game_state == Globals.GameStates.MENU:
			UI.emit_signal("changed", UI.MAIN_MENU_SETTINGS_OTHER)
		else:
			UI.emit_signal("changed", UI.MAIN_MENU_SETTINGS_OTHER)
	update_left_button_focus()
	update_right_button_focus()


func _social_button_pressed() -> void:
	UI.emit_signal("button_pressed")
	apply_settings()


func _profile_pause_button_pressed() -> void:
	UI.emit_signal("button_pressed")
	apply_settings()


func _credits_button_pressed() -> void:
	UI.emit_signal("button_pressed")
	if UI.current_menu == UI.MAIN_MENU_SETTINGS_GENERAL:
		UI.emit_signal("changed", UI.MAIN_MENU_SETTINGS_CREDITS)
	elif UI.current_menu == UI.PAUSE_MENU_SETTINGS_GENERAL:
		UI.emit_signal("changed", UI.PAUSE_MENU_SETTINGS_CREDITS)


func _music_volume_button_pressed() -> void:
	UI.emit_signal("button_pressed")
	update_music_toggle()
	apply_settings()


func _audio_volume_button_pressed() -> void:
	UI.emit_signal("button_pressed")
	update_audio_toggle()
	apply_settings()


func _audio_volume_changed(value: int) -> void:
	audio_volume_label.text = "Audio Volume: %s" % str(value)
	apply_settings()


func _music_volume_changed(value: int) -> void:
	music_volume_label.text = "Music Volume: %s" % str(value)
	apply_settings()


func _fullscreen_button_pressed() -> void:
	UI.emit_signal("button_pressed")
	update_toggle_buttons()
	data.fullscreen = fullscreen_button.pressed
	apply_settings()


func _aa_button_pressed() -> void:
	UI.emit_signal("button_pressed")
	var viewport: Viewport = get_viewport()
	match viewport.msaa:
		viewport.MSAA_DISABLED:
			data.aa_level = float(viewport.MSAA_2X)
		viewport.MSAA_2X:
			data.aa_level = float(viewport.MSAA_4X)
		viewport.MSAA_4X:
			data.aa_level = float(viewport.MSAA_8X)
		viewport.MSAA_8X:
			data.aa_level = float(viewport.MSAA_16X)
		viewport.MSAA_16X:
			data.aa_level = float(viewport.MSAA_DISABLED)
	update_aa_button_text()
	apply_settings()


func update_aa_button_text() -> void:
	var viewport: Viewport = get_viewport()
	var string: String = "Anti Aliasing: "
	match int(data.aa_level):
		viewport.MSAA_DISABLED:
			string += "Disabled"
		viewport.MSAA_2X:
			string += "Default"
		viewport.MSAA_4X:
			string += "Medium"
		viewport.MSAA_8X:
			string += "High"
		viewport.MSAA_16X:
			string += "Very High"
	aa_button.text = string


func _vsync_button_pressed() -> void:
	UI.emit_signal("button_pressed")
	apply_settings()


func _tonemap_button_pressed() -> void:
	UI.emit_signal("button_pressed")
	var env: WorldEnvironment = Globals.get_env()
	match Globals.get_env().environment.tonemap_mode:
		env.environment.TONE_MAPPER_LINEAR:
			data.tonemap = float(env.environment.TONE_MAPPER_FILMIC)
		env.environment.TONE_MAPPER_FILMIC:
			data.tonemap = float(env.environment.TONE_MAPPER_REINHARDT)
		env.environment.TONE_MAPPER_REINHARDT:
			data.tonemap = float(env.environment.TONE_MAPPER_ACES)
		env.environment.TONE_MAPPER_ACES:
			data.tonemap = float(env.environment.TONE_MAPPER_ACES_FITTED)
		env.environment.TONE_MAPPER_ACES_FITTED:
			data.tonemap = float(env.environment.TONE_MAPPER_LINEAR)
	apply_settings()
	update_tonemap_button_text()


func update_tonemap_button_text() -> void:
	var string: String = "Color Tonemap: "
	var env: WorldEnvironment = Globals.get_env()
	match int(data.tonemap):
		env.environment.TONE_MAPPER_LINEAR:
			string += "Linear"
		env.environment.TONE_MAPPER_FILMIC:
			string += "Filmic"
		env.environment.TONE_MAPPER_REINHARDT:
			string += "Reinhardt"
		env.environment.TONE_MAPPER_ACES:
			string += "ACES (Default)"
		env.environment.TONE_MAPPER_ACES_FITTED:
			string += "ACES Fitted"
	tonemap_button.text = string


func _debug_button_pressed() -> void:
	UI.emit_signal("button_pressed")
	UI.emit_signal("changed", UI.MAIN_MENU_SETTINGS_DEBUG_ENABLE_PROMPT)
#		update_toggle_buttons()
#		apply_settings()


func _erase_button_pressed() -> void:
	UI.emit_signal("button_pressed")
	UI.emit_signal("changed", UI.MAIN_MENU_SETTINGS_ERASE_PROMPT)


func _erase_all_started() -> void:
	disable_buttons()


func _debug_enable_started() -> void:
	disable_buttons()
	if not data.cheats:
		debug_button.pressed = false


func _erase_all_confirmed() -> void:
	yield(get_tree().create_timer(0.9), "timeout")
	reset_file()
	load_stats()
	update_button_toggles()
	update_audio_toggle()
	update_music_toggle()
	update_toggle_buttons()
	update_aa_button_text()
	update_tonemap_button_text()
	update_audio_labels()
	apply_settings()


func _debug_enable_confirmed() -> void:
	debug_button.disabled = true
	data.cheats = true
	apply_settings()


func update_right_button_focus() -> void:
	match UI.current_menu:
		UI.MAIN_MENU_SETTINGS_GENERAL, UI.PAUSE_MENU_SETTINGS_GENERAL:
			for button in general_buttons.get_children():
				button.focus_neighbour_left = side_panel_focus.get_path()
		UI.MAIN_MENU_SETTINGS_GRAPHICS, UI.PAUSE_MENU_SETTINGS_GRAPHICS:
			for button in graphics_buttons.get_children():
				button.focus_neighbour_left = side_panel_focus.get_path()
		UI.MAIN_MENU_SETTINGS_CONTROLS, UI.PAUSE_MENU_SETTINGS_CONTROLS:
			for button in controls_buttons.get_children():
				button.focus_neighbour_left = side_panel_focus.get_path()
		UI.MAIN_MENU_SETTINGS_OTHER:
			for button in other_buttons.get_children():
				button.focus_neighbour_left = side_panel_focus.get_path()


func update_left_button_focus() -> void:
	for button in side_panel.get_children():
		button.focus_neighbour_right = button_focus.get_path()

#
# SIDE PANEL FOCUSES
#
func _on_Back_focus_entered() -> void:
	side_panel_focus = back_button
	update_right_button_focus()


func _on_General_focus_entered() -> void:
	side_panel_focus = general_menu_button
	update_right_button_focus()


func _on_Graphics_focus_entered() -> void:
	side_panel_focus = graphics_menu_button
	update_right_button_focus()


func _on_Controls_focus_entered() -> void:
	side_panel_focus = controls_menu_button
	update_right_button_focus()


func _on_Other_focus_entered() -> void:
	side_panel_focus = other_menu_button
	update_right_button_focus()

#
# GENERAL MENU FOCUSES
#
func _on_SocialMedia_focus_entered() -> void:
	button_focus = social_button
	update_left_button_focus()


func _on_ProfilePause_focus_entered() -> void:
	button_focus = profile_pause_button
	update_left_button_focus()


func _on_Credits_focus_entered() -> void:
	button_focus = credits_button
	update_left_button_focus()


func _on_AudioVolume_focus_entered() -> void:
	button_focus = audio_volume_button
	update_left_button_focus()


func _on_MusicVolume_focus_entered() -> void:
	button_focus = music_volume_button
	update_left_button_focus()

#
# GRAPHICS MENU FOCUSES
#
func _on_Fullscreen_focus_entered() -> void:
	button_focus = fullscreen_button
	update_left_button_focus()


func _on_VSync_focus_entered() -> void:
	button_focus = vsync_button
	update_left_button_focus()


func _on_AA_focus_entered() -> void:
	button_focus = aa_button
	update_left_button_focus()


func _on_Tonemap_focus_entered() -> void:
	button_focus = tonemap_button
	update_left_button_focus()

#
# CONTROLS MENU FOCUSES
#
func _on_Test_focus_entered() -> void:
	button_focus = controls_test_button
	update_left_button_focus()

#
# OTHER MENU FOCUSES
#
func _on_DebugConsole_focus_entered() -> void:
	button_focus = debug_button
	update_left_button_focus()


func _on_EraseGame_focus_entered() -> void:
	button_focus = erase_button
	update_left_button_focus()
