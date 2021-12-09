extends Control

const FILE: String = \
	"user://settings.json"

const DEFAULT_DATA: Dictionary = {
	"show_social": true,
	"vsync": true,
	"tonemap": 3.0,
	"fullscreen": true,
	"post_processing": true,
	"audio_enabled": true,
	"audio_value": 100.0,
	"music_enabled": true,
	"music_value": 100.0,
	"language": "not_set",
	"controls": {
		"ability": KEY_CONTROL,
		"move_left": KEY_A,
		"move_right": KEY_D,
		"move_down": KEY_S,
		"move_jump": KEY_SPACE,
		"move_sprint": KEY_SHIFT,
		"interact": KEY_F,
		"inventory": KEY_E,
		"equip": KEY_R,
		"powerup": KEY_X,
	},

	"controls_2": {
		"ability": null,
		"move_left": KEY_LEFT,
		"move_right": KEY_RIGHT,
		"move_down": KEY_DOWN,
		"move_jump": KEY_W,
		"move_sprint": null,
		"interact": null,
		"inventory": null,
		"fire": null,
		"equip": null,
		"powerup": null,
	},
}

var data: Dictionary = {}

var side_panel_focus: Button = null
var button_focus: Button = null
var in_category: bool = false

onready var subcategory: Label = $Panel/BG/Subcategory
onready var subcategory_anim_player: AnimationPlayer = $Panel/BG/Subcategory/AnimationPlayer

#
# GENERAL MENU
#
onready var general_buttons: VBoxContainer = $Panel/BG/GeneralMenu/HBoxContainer
onready var social_button: Button = $Panel/BG/GeneralMenu/HBoxContainer/Social
onready var language_button: Button = $Panel/BG/GeneralMenu/HBoxContainer/Language
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
onready var vsync_button: Button = $Panel/BG/GraphicsMenu/HBoxContainer/VSync
onready var tonemap_button: Button = $Panel/BG/GraphicsMenu/HBoxContainer/Tonemap
onready var post_processing_button: Button = $Panel/BG/GraphicsMenu/HBoxContainer/PostProcessing

#
# CONTROLS MENU
#
onready var controls_buttons: VBoxContainer = $Panel/BG/ControlsMenu/HBoxContainer
onready var controls_customize_button: Button = $Panel/BG/ControlsMenu/HBoxContainer/CustomizeControls

#
# OTHER MENU
#
onready var other_buttons: VBoxContainer = $Panel/BG/OtherMenu/HBoxContainer
onready var reset_settings_button: Button = $Panel/BG/OtherMenu/HBoxContainer/ResetSettings
onready var erase_all_button: Button = $Panel/BG/OtherMenu/HBoxContainer/EraseGame

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
	__ = GlobalEvents.connect("level_changed", self, "_level_changed")
	__ = GlobalEvents.connect("ui_settings_pressed", self, "_ui_settings_pressed")
	__ = GlobalEvents.connect("ui_settings_credits_back_pressed", self, "_ui_settings_credits_back_pressed")
	__ = GlobalEvents.connect("ui_settings_controls_customize_back_pressed", self, "_ui_settings_controls_customize_back_pressed")
	__ = GlobalEvents.connect("ui_settings_erase_all_prompt_no_pressed", self, "_ui_settings_erase_all_prompt_no_pressed")
	__ = GlobalEvents.connect("ui_settings_erase_all_prompt_extra_no_pressed", self, "_ui_settings_erase_all_prompt_extra_no_pressed")
	__ = GlobalEvents.connect("ui_settings_erase_all_prompt_extra_yes_pressed", self, "_ui_settings_erase_all_prompt_extra_yes_pressed")
	__ = GlobalEvents.connect("ui_settings_reset_settings_prompt_no_pressed", self, "_ui_settings_reset_settings_prompt_no_pressed")
	__ = GlobalEvents.connect("ui_settings_reset_settings_prompt_yes_pressed", self, "_ui_settings_reset_settings_prompt_yes_pressed")
	__ = GlobalEvents.connect("ui_settings_language_back_pressed", self, "_ui_settings_language_back_pressed")
	__ = GlobalEvents.connect("ui_settings_language_english_pressed", self, "_ui_settings_language_english_pressed")
	__ = GlobalEvents.connect("ui_settings_language_spanish_pressed", self, "_ui_settings_language_spanish_pressed")
	__ = general_menu_button.connect("pressed", self, "_general_pressed")
	__ = graphics_menu_button.connect("pressed", self, "_graphics_pressed")
	__ = controls_menu_button.connect("pressed", self, "_controls_pressed")
	__ = other_menu_button.connect("pressed", self, "_other_pressed")
	__ = language_button.connect("pressed", self, "_language_button_pressed")
	__ = audio_volume_button.connect("pressed", self, "_audio_volume_button_pressed")
	__ = audio_volume_slider.connect("value_changed", self, "_audio_volume_changed")
	__ = music_volume_button.connect("pressed", self, "_music_volume_button_pressed")
	__ = music_volume_slider.connect("value_changed", self, "_music_volume_changed")
	__ = social_button.connect("pressed", self, "_social_button_pressed")
	__ = credits_button.connect("pressed", self, "_credits_button_pressed")
	__ = fullscreen_button.connect("pressed", self, "_fullscreen_button_pressed")
	__ = vsync_button.connect("pressed", self, "_vsync_button_pressed")
	__ = tonemap_button.connect("pressed", self, "_tonemap_button_pressed")
	__ = post_processing_button.connect("pressed", self, "_post_processing_button_pressed")
	__ = controls_customize_button.connect("pressed", self, "_controls_customize_button_pressed")
	__ = reset_settings_button.connect("pressed", self, "_reset_settings_button_pressed")
	__ = erase_all_button.connect("pressed", self, "_erase_all_button_pressed")
	__ = back_button.connect("pressed", self, "_back_button_pressed")

	load_stats()

	yield(get_tree(), "physics_frame")
	update_button_toggles()
	update_audio_toggle()
	update_music_toggle()
	update_toggle_buttons()
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
		save_settings()

		var file: File = File.new()
		var __: int = file.open(FILE, File.WRITE)
		file.store_string(to_json(data))
		file.close()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and (GlobalUI.menu == GlobalUI.Menus.SETTINGS\
			or GlobalUI.menu == GlobalUI.Menus.SETTINGS_GENERAL or GlobalUI.menu == GlobalUI.Menus.SETTINGS_GRAPHICS\
			or GlobalUI.menu == GlobalUI.Menus.SETTINGS_CONTROLS or GlobalUI.menu == GlobalUI.Menus.SETTINGS_OTHER) and not GlobalUI.menu_locked:
		back()
		get_tree().set_input_as_handled()


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED:
		update_button_toggles()
		update_audio_toggle()
		update_music_toggle()
		update_toggle_buttons()
		update_tonemap_button_text()
		update_audio_labels()


func update_audio_labels() -> void:
	music_volume_label.text = "%s" % data.music_value
	audio_volume_label.text = "%s" % data.audio_value


func disable_side_panel_right_focus() -> void:
	for button in side_panel.get_children():
		button.focus_neighbour_right = button.get_path()


func update_button_toggles() -> void:
	social_button.pressed = data.show_social
	fullscreen_button.pressed = data.fullscreen
	vsync_button.pressed = data.vsync
	post_processing_button.pressed = data.post_processing
	audio_volume_button.pressed = data.audio_enabled
	audio_volume_slider.value = data.audio_value
	music_volume_button.pressed = data.music_enabled
	music_volume_slider.value = data.music_value
	GlobalEvents.emit_signal("ui_settings_language_buttons_updated", data.language)


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
	update_tonemap_button_text()


func hide_menu() -> void:
	animation_player.play_backwards("show")
	disable_buttons()
	in_category = false
	yield(animation_player, "animation_finished")
	hide()


func enable_buttons() -> void:
	general_menu_button.disabled = false
	graphics_menu_button.disabled = false
	controls_menu_button.disabled = false
	other_menu_button.disabled = false

	social_button.disabled = false
	language_button.disabled = false
	credits_button.disabled = false
	audio_volume_button.disabled = false
	audio_volume_slider.show()
	music_volume_button.disabled = false
	music_volume_slider.show()

	fullscreen_button.disabled = false
	vsync_button.disabled = false
	tonemap_button.disabled = false

	controls_customize_button.disabled = false

	erase_all_button.disabled = false

	reset_settings_button.disabled = false

	if Globals.game_state == Globals.GameStates.MENU:
		other_menu_button.disabled = false
	else:
		other_menu_button.disabled = true

	back_button.disabled = false


func disable_buttons() -> void:
	general_menu_button.disabled = true
	graphics_menu_button.disabled = true
	controls_menu_button.disabled = true
	other_menu_button.disabled = true

	social_button.disabled = true
	language_button.disabled = true
	credits_button.disabled = true
	audio_volume_button.disabled = true
	audio_volume_slider.hide()
	music_volume_button.disabled = true
	music_volume_slider.hide()

	fullscreen_button.disabled = true
	vsync_button.disabled = true
	tonemap_button.disabled = true

	controls_customize_button.disabled = true

	reset_settings_button.disabled = true
	erase_all_button.disabled = true

	back_button.disabled = true


func load_stats() -> void:
	var file: File = File.new()
	if file.file_exists(FILE):
		var __: int = file.open(FILE, File.READ)
		var loaded_data = parse_json(file.get_as_text())
		file.close()
		var allow: bool = true
		if typeof(loaded_data) == TYPE_DICTIONARY:
			for i in DEFAULT_DATA:
				if not loaded_data.has(i):
					allow = false
					continue
				elif not typeof(loaded_data[i]) == typeof(DEFAULT_DATA[i]):
					allow = false
					continue
			if loaded_data.size() == DEFAULT_DATA.size() and allow:
				data = loaded_data
			else:
				reset_file()
		else:
			reset_file()
	else:
		reset_file()


func reset_file() -> void:
	data = DEFAULT_DATA
	var file: File = File.new()
	var __: int = file.open(FILE, File.WRITE)
	file.store_string(to_json(data))
	file.close()
	load_stats()


func save_settings() -> void:
	data.show_social = social_button.pressed
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
	OS.window_fullscreen = data.fullscreen
	OS.vsync_enabled = data.vsync

	get_node(GlobalPaths.WORLD_ENVIRONMENT).environment.tonemap_mode = data.tonemap
	get_node(GlobalPaths.WORLD_ENVIRONMENT).environment.glow_enabled = data.post_processing
	get_node(GlobalPaths.WORLD_ENVIRONMENT).environment.adjustment_enabled = data.post_processing

	if data.audio_enabled:
		AudioServer.set_bus_volume_db(2, get_db_value(data.audio_value))
	else:
		AudioServer.set_bus_volume_db(2, get_db_value(0))

	if data.music_enabled:
		AudioServer.set_bus_volume_db(1, get_db_value(data.music_value))
	else:
		AudioServer.set_bus_volume_db(1, get_db_value(0))

	if not data.language == "not_set":
		TranslationServer.set_locale(data.language)

	GlobalEvents.emit_signal("ui_settings_updated")


func get_db_value(db_level: float) -> float:
	db_level *= 0.01
	return linear2db(db_level)


func update_audio_toggle() -> void:
	if audio_volume_button.pressed:
		audio_volume_button.text = "%s: %s" % [tr("settings.general.audio_volume"), tr("global.on")]
		audio_slider.show()
		audio_volume_button.focus_neighbour_bottom = audio_volume_slider.get_path()
		audio_volume_button.focus_next = audio_volume_slider.get_path()
		social_button.focus_neighbour_top = audio_volume_slider.get_path()
		social_button.focus_previous = audio_volume_slider.get_path()
	else:
		audio_volume_button.text = "%s: %s" % [tr("settings.general.audio_volume"), tr("global.off")]
		audio_slider.hide()
		audio_volume_button.focus_neighbour_bottom = social_button.get_path()
		audio_volume_button.focus_next = social_button.get_path()
		social_button.focus_neighbour_top = audio_volume_button.get_path()
		social_button.focus_previous = audio_volume_button.get_path()


func update_music_toggle() -> void:
	if music_volume_button.pressed:
		music_volume_button.text = "%s: %s" % [tr("settings.general.music_volume"), tr("global.on")]
		music_slider.show()
		music_volume_button.focus_neighbour_bottom = music_volume_slider.get_path()
		music_volume_button.focus_next = music_volume_slider.get_path()
		music_volume_slider.focus_neighbour_bottom = audio_volume_button.get_path()
		music_volume_slider.focus_next = audio_volume_button.get_path()
		audio_volume_button.focus_neighbour_top = music_volume_slider.get_path()
		audio_volume_button.focus_previous = music_volume_slider.get_path()
	else:
		music_volume_button.text = "%s: %s" % [tr("settings.general.music_volume"), tr("global.off")]
		music_slider.hide()
		music_volume_button.focus_neighbour_bottom = audio_volume_button.get_path()
		music_volume_button.focus_next = audio_volume_button.get_path()
		audio_volume_button.focus_neighbour_top = music_volume_button.get_path()
		audio_volume_button.focus_previous = music_volume_button.get_path()


func update_toggle_buttons() -> void:

	if social_button.pressed:
		social_button.text = "%s: %s" % [tr("settings.general.social"), tr("global.on")]
	else:
		social_button.text = "%s: %s" % [tr("settings.general.social"), tr("global.off")]

	if fullscreen_button.pressed:
		fullscreen_button.text = "%s: %s" % [tr("settings.graphics.fullscreen"), tr("global.on")]
	else:
		fullscreen_button.text = "%s: %s" % [tr("settings.graphics.fullscreen"), tr("global.off")]

	if vsync_button.pressed:
		vsync_button.text = "%s: %s" % [tr("settings.graphics.vsync"), tr("global.on")]
	else:
		vsync_button.text = "%s: %s" % [tr("settings.graphics.vsync"), tr("global.off")]

	if post_processing_button.pressed:
		post_processing_button.text = "%s: %s" % [tr("settings.graphics.post_processing"), tr("global.on")]
	else:
		post_processing_button.text = "%s: %s" % [tr("settings.graphics.post_processing"), tr("global.off")]


func fullscreen_changed() -> void:
	if OS.window_fullscreen and not fullscreen_button.pressed:
		fullscreen_button.pressed = true
	elif not OS.window_fullscreen and fullscreen_button.pressed:
		fullscreen_button.pressed = false
	update_toggle_buttons()


func previous_menu_back() -> void:
	match GlobalUI.menu:
		GlobalUI.Menus.SETTINGS_GENERAL:
			general_anim_player.play_backwards("slide")
		GlobalUI.Menus.SETTINGS_GRAPHICS:
			graphics_anim_player.play_backwards("slide")
		GlobalUI.Menus.SETTINGS_CONTROLS:
			controls_anim_player.play_backwards("slide")
		GlobalUI.Menus.SETTINGS_OTHER:
			other_anim_player.play_backwards("slide")


func back() -> void:
	if GlobalUI.menu_locked: return
	GlobalEvents.emit_signal("ui_button_pressed", true)

	match GlobalUI.menu:
		GlobalUI.Menus.SETTINGS_GENERAL:
			general_anim_player.play_backwards("slide")
			subcategory_anim_player.play("slide")
			general_menu_button.grab_focus()
			GlobalUI.menu = GlobalUI.Menus.SETTINGS
			in_category = false

		GlobalUI.Menus.SETTINGS_GRAPHICS:
			graphics_anim_player.play_backwards("slide")
			subcategory_anim_player.play("slide")
			graphics_menu_button.grab_focus()
			GlobalUI.menu = GlobalUI.Menus.SETTINGS
			in_category = false

		GlobalUI.Menus.SETTINGS_CONTROLS:
			controls_anim_player.play_backwards("slide")
			subcategory_anim_player.play("slide")
			controls_menu_button.grab_focus()
			GlobalUI.menu = GlobalUI.Menus.SETTINGS
			in_category = false

		GlobalUI.Menus.SETTINGS_OTHER:
			other_anim_player.play_backwards("slide")
			subcategory_anim_player.play("slide")
			other_menu_button.grab_focus()
			GlobalUI.menu = GlobalUI.Menus.SETTINGS
			in_category = false

		GlobalUI.Menus.SETTINGS:
			GlobalEvents.emit_signal("ui_settings_back_pressed")
			hide_menu()
			if Globals.game_state == Globals.GameStates.MENU:
				GlobalUI.menu = GlobalUI.Menus.MAIN_MENU
			else:
				GlobalUI.menu = GlobalUI.Menus.PAUSE_MENU


func update_tonemap_button_text() -> void:
	var string: String = "%s: " % tr("settings.graphics.tonemap")
	var env: WorldEnvironment = get_node(GlobalPaths.WORLD_ENVIRONMENT)
	match int(data.tonemap):
		env.environment.TONE_MAPPER_LINEAR:
			string += "Linear"
		env.environment.TONE_MAPPER_FILMIC:
			string += "Filmic"
		env.environment.TONE_MAPPER_REINHARDT:
			string += "Reinhardt"
		env.environment.TONE_MAPPER_ACES:
			string += "ACES (%s)" % tr("default")
		env.environment.TONE_MAPPER_ACES_FITTED:
			string += "ACES Fitted"
	tonemap_button.text = string


func update_right_button_focus() -> void:
	match GlobalUI.menu:
		GlobalUI.Menus.SETTINGS_GENERAL:
			for button in general_buttons.get_children():
				button.focus_neighbour_left = side_panel_focus.get_path()
		GlobalUI.Menus.SETTINGS_GRAPHICS:
			for button in graphics_buttons.get_children():
				button.focus_neighbour_left = side_panel_focus.get_path()
		GlobalUI.Menus.SETTINGS_CONTROLS:
			for button in controls_buttons.get_children():
				button.focus_neighbour_left = side_panel_focus.get_path()
		GlobalUI.Menus.SETTINGS_OTHER:
			for button in other_buttons.get_children():
				button.focus_neighbour_left = side_panel_focus.get_path()


func update_left_button_focus() -> void:
	for button in side_panel.get_children():
		button.focus_neighbour_right = button_focus.get_path()


# Start of Global Events
func _level_changed(_world: int, _level: int) -> void:
	if GlobalUI.menu == GlobalUI.Menus.SETTINGS \
			or GlobalUI.menu == GlobalUI.Menus.SETTINGS_GENERAL \
			or GlobalUI.menu == GlobalUI.Menus.SETTINGS_GRAPHICS \
			or GlobalUI.menu == GlobalUI.Menus.SETTINGS_CONTROLS \
			or GlobalUI.menu == GlobalUI.Menus.SETTINGS_OTHER:
		back()
		hide_menu()


func _ui_settings_pressed() -> void:
	show_menu()


func _ui_settings_credits_back_pressed() -> void:
	enable_buttons()
	credits_button.grab_focus()


func _ui_settings_controls_customize_back_pressed() -> void:
	enable_buttons()
	controls_customize_button.grab_focus()


func _ui_settings_erase_all_prompt_no_pressed() -> void:
	enable_buttons()
	erase_all_button.grab_focus()


func _ui_settings_erase_all_prompt_extra_no_pressed() -> void:
	enable_buttons()
	erase_all_button.grab_focus()


func _ui_settings_erase_all_prompt_extra_yes_pressed() -> void:
	yield(get_tree().create_timer(0.75), "timeout")
	reset_file()
	load_stats()
	update_button_toggles()
	update_audio_toggle()
	update_music_toggle()
	update_toggle_buttons()
	update_tonemap_button_text()
	update_audio_labels()
	apply_settings()


func _ui_settings_reset_settings_prompt_no_pressed() -> void:
	enable_buttons()
	reset_settings_button.grab_focus()


func _ui_settings_reset_settings_prompt_yes_pressed() -> void:
	# Give time for Controls Menu to delete InputMaps based off of settings
	yield(get_tree(), "physics_frame")
	yield(get_tree(), "physics_frame")

	enable_buttons()
	reset_settings_button.grab_focus()
	reset_file()


func _ui_settings_language_back_pressed() -> void:
	enable_buttons()
	language_button.grab_focus()


func _ui_settings_language_english_pressed() -> void:
	data.language = "en"
	apply_settings()


func _ui_settings_language_spanish_pressed() -> void:
	data.language = "es"
	apply_settings()


# End of Global Events
func _general_pressed() -> void:
	GlobalEvents.emit_signal("ui_button_pressed")
	side_panel_focus = general_menu_button
	for button in side_panel.get_children():
		button.focus_neighbour_right = social_button.get_path()
	button_focus = social_button
	if not GlobalUI.menu == GlobalUI.Menus.SETTINGS_GENERAL:
		general_anim_player.play("slide")
		if not in_category:
			subcategory_anim_player.play_backwards("slide")
			in_category = true
		else:
			previous_menu_back()
		GlobalUI.menu = GlobalUI.Menus.SETTINGS_GENERAL
		language_button.grab_focus()
	update_left_button_focus()
	update_right_button_focus()


func _graphics_pressed() -> void:
	GlobalEvents.emit_signal("ui_button_pressed")
	side_panel_focus = graphics_menu_button
	for button in side_panel.get_children():
		button.focus_neighbour_right = fullscreen_button.get_path()
	button_focus = fullscreen_button
	if not GlobalUI.menu == GlobalUI.Menus.SETTINGS_GRAPHICS:
		graphics_anim_player.play("slide")
		if not in_category:
			subcategory_anim_player.play_backwards("slide")
			in_category = true
		else:
			previous_menu_back()
		GlobalUI.menu = GlobalUI.Menus.SETTINGS_GRAPHICS
		fullscreen_button.grab_focus()
	update_left_button_focus()
	update_right_button_focus()


func _controls_pressed() -> void:
	GlobalEvents.emit_signal("ui_button_pressed")
	side_panel_focus = controls_menu_button
	for button in side_panel.get_children():
		button.focus_neighbour_right = controls_customize_button.get_path()
	button_focus = controls_customize_button
	if not GlobalUI.menu == GlobalUI.Menus.SETTINGS_CONTROLS:
		controls_anim_player.play("slide")
		if not in_category:
			subcategory_anim_player.play_backwards("slide")
			in_category = true
		else:
			previous_menu_back()
		GlobalUI.menu = GlobalUI.Menus.SETTINGS_CONTROLS
		controls_customize_button.grab_focus()
	update_left_button_focus()
	update_right_button_focus()


func _other_pressed() -> void:
	GlobalEvents.emit_signal("ui_button_pressed")
	side_panel_focus = other_menu_button
	for button in side_panel.get_children():
		button.focus_neighbour_right = reset_settings_button.get_path()
	button_focus = reset_settings_button
	if not GlobalUI.menu == GlobalUI.Menus.SETTINGS_OTHER:
		other_anim_player.play("slide")
		if not in_category:
			subcategory_anim_player.play_backwards("slide")
			in_category = true
		else:
			previous_menu_back()
		GlobalUI.menu = GlobalUI.Menus.SETTINGS_OTHER
		reset_settings_button.grab_focus()
	update_left_button_focus()
	update_right_button_focus()


func _language_button_pressed() -> void:
	GlobalEvents.emit_signal("ui_button_pressed")
	GlobalEvents.emit_signal("ui_settings_language_pressed")
	GlobalUI.menu = GlobalUI.Menus.SETTINGS_GENERAL_LANGUAGE
	disable_buttons()


func _music_volume_button_pressed() -> void:
	GlobalEvents.emit_signal("ui_button_pressed")
	update_music_toggle()
	apply_settings()


func _audio_volume_button_pressed() -> void:
	GlobalEvents.emit_signal("ui_button_pressed")
	update_audio_toggle()
	apply_settings()


func _audio_volume_changed(value: int) -> void:
	audio_volume_label.text = str(value)
	apply_settings()


func _music_volume_changed(value: int) -> void:
	music_volume_label.text = str(value)
	apply_settings()


func _social_button_pressed() -> void:
	GlobalEvents.emit_signal("ui_button_pressed")
	apply_settings()


func _credits_button_pressed() -> void:
	GlobalEvents.emit_signal("ui_button_pressed")
	if GlobalUI.menu == GlobalUI.Menus.SETTINGS_GENERAL:
		GlobalUI.menu = GlobalUI.Menus.SETTINGS_CREDITS
		GlobalEvents.emit_signal("ui_settings_credits_pressed")
		disable_buttons()


func _fullscreen_button_pressed() -> void:
	GlobalEvents.emit_signal("ui_button_pressed")
	update_toggle_buttons()
	data.fullscreen = fullscreen_button.pressed
	apply_settings()


func _vsync_button_pressed() -> void:
	GlobalEvents.emit_signal("ui_button_pressed")
	apply_settings()


func _tonemap_button_pressed() -> void:
	GlobalEvents.emit_signal("ui_button_pressed")
	var env: WorldEnvironment = get_node(GlobalPaths.WORLD_ENVIRONMENT)
	match env.environment.tonemap_mode:
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


func _post_processing_button_pressed() -> void:
	GlobalEvents.emit_signal("ui_button_pressed")
	data.post_processing = post_processing_button.pressed
	apply_settings()


func _controls_customize_button_pressed() -> void:
	GlobalEvents.emit_signal("ui_button_pressed")
	GlobalEvents.emit_signal("ui_settings_controls_customize_pressed")
	GlobalUI.menu = GlobalUI.Menus.SETTINGS_CONTROLS_CUSTOMIZE
	disable_buttons()


func _reset_settings_button_pressed() -> void:
	GlobalEvents.emit_signal("ui_button_pressed")
	GlobalEvents.emit_signal("ui_settings_reset_settings_pressed")
	GlobalUI.menu = GlobalUI.Menus.SETTINGS_RESET_SETTINGS_PROMPT
	disable_buttons()


func _erase_all_button_pressed() -> void:
	GlobalEvents.emit_signal("ui_button_pressed")
	GlobalEvents.emit_signal("ui_settings_erase_all_pressed")
	GlobalUI.menu = GlobalUI.Menus.SETTINGS_ERASE_ALL_PROMPT
	disable_buttons()


func _back_button_pressed() -> void:
	if GlobalUI.menu_locked: return
	GlobalEvents.emit_signal("ui_button_pressed", true)
	GlobalEvents.emit_signal("ui_settings_back_pressed")
	previous_menu_back()
	if Globals.game_state == Globals.GameStates.MENU:
		GlobalUI.menu = GlobalUI.Menus.MAIN_MENU
	else:
		GlobalUI.menu = GlobalUI.Menus.PAUSE_MENU
	hide_menu()


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


func _on_Language_focus_entered() -> void:
	button_focus = language_button
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


func _on_Tonemap_focus_entered() -> void:
	button_focus = tonemap_button
	update_left_button_focus()


func _on_PostProcessing_focus_entered() -> void:
	button_focus = post_processing_button
	update_left_button_focus()

#
# CONTROLS MENU FOCUSES
#
func _on_Test_focus_entered() -> void:
	button_focus = controls_customize_button
	update_left_button_focus()

#
# OTHER MENU FOCUSES
#
func _on_DebugConsole_focus_entered() -> void:
	button_focus = reset_settings_button
	update_left_button_focus()


func _on_EraseGame_focus_entered() -> void:
	button_focus = erase_all_button
	update_left_button_focus()
