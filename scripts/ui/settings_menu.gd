extends Control

const FILE: String = \
	"user://settings.json"

var data: Dictionary = {
	"fullscreen": false,
	"audio_enabled": true,
	"audio_value": 100,
	"music_enabled": true,
	"music_value": 100,
}

onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var controls_button: Button = $Panel/VBoxContainer/HBoxContainer/Controls
onready var fullscreen_button: Button = $Panel/VBoxContainer/HBoxContainer/Fullscreen
onready var audio_volume_button: Button = $Panel/VBoxContainer/HBoxContainer/AudioVolume
onready var audio_volume_slider: HSlider = $Panel/VBoxContainer/HBoxContainer/AudioSlider/Slider
onready var audio_volume_label: Label = $Panel/VBoxContainer/HBoxContainer/AudioSlider/Value
onready var music_volume_button: Button = $Panel/VBoxContainer/HBoxContainer/MusicVolume
onready var music_volume_slider: HSlider = $Panel/VBoxContainer/HBoxContainer/MusicSlider/Slider
onready var music_volume_label: Label = $Panel/VBoxContainer/HBoxContainer/MusicSlider/Value
onready var credits_button: Button = $Panel/VBoxContainer/HBoxContainer/Credits
onready var save_button: Button = $Panel/HBoxContainer2/Save
onready var back_button: Button = $Panel/HBoxContainer2/Back
onready var audio_slider: HBoxContainer = $Panel/VBoxContainer/HBoxContainer/AudioSlider
onready var music_slider: HBoxContainer = $Panel/VBoxContainer/HBoxContainer/MusicSlider


func _ready() -> void:
	load_stats()
	apply_settings()
	hide()
	controls_button.connect("pressed", self, "_controls_button_pressed")
	fullscreen_button.connect("pressed", self, "_fullscreen_button_pressed")
	audio_volume_button.connect("pressed", self, "_audio_volume_button_pressed")
	#audio_volume_button.connect("pressed", self, "update_audio_toggle")
	audio_volume_slider.connect("value_changed", self, "_audio_volume_changed")
	music_volume_button.connect("pressed", self, "_music_volume_button_pressed")
	#music_volume_button.connect("pressed", self, "update_music_toggle")
	music_volume_slider.connect("value_changed", self, "_music_volume_changed")
	credits_button.connect("pressed", self, "_credits_pressed")
	back_button.connect("pressed", self, "_back_pressed")
	save_button.connect("pressed", self, "_save_pressed")
	UI.connect("changed", self, "_ui_changed")
	if Globals.is_mobile:
		fullscreen_button.hide()
		controls_button.hide()
		audio_volume_button.focus_neighbour_left = back_button.get_path()
		audio_volume_button.focus_neighbour_bottom = back_button.get_path()
		audio_volume_button.focus_previous = back_button.get_path()
		back_button.focus_neighbour_bottom = audio_volume_button.get_path()
		save_button.focus_neighbour_bottom = audio_volume_button.get_path()


func _input(event: InputEvent) -> void:
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
		file.open(FILE, File.WRITE)
		file.store_string(to_json(data))
		file.close()


func _ui_changed(menu: int) -> void:
	match menu:
		UI.MAIN_MENU_SETTINGS, UI.PAUSE_MENU_SETTINGS:
			if UI.last_menu == UI.MAIN_MENU or UI.last_menu == UI.PAUSE_MENU:
				show_menu()
			else:
				enable_buttons()
				if UI.last_menu == UI.MAIN_MENU_SETTINGS_CREDITS or UI.last_menu == UI.PAUSE_MENU_SETTINGS_CREDITS:
					credits_button.grab_focus()
		UI.MAIN_MENU, UI.PAUSE_MENU:
			if UI.last_menu == UI.PAUSE_MENU_SETTINGS or \
					UI.last_menu == UI.MAIN_MENU_SETTINGS:
				hide_menu()
		UI.MAIN_MENU_SETTINGS_CREDITS, UI.PAUSE_MENU_SETTINGS_CREDITS:
			disable_buttons()



func show_menu() -> void:
	if Globals.is_mobile:
		audio_volume_button.grab_focus()
	else:
		controls_button.grab_focus()
	show()
	animation_player.play("show")
	fullscreen_button.pressed = data.fullscreen
	audio_volume_button.pressed = data.audio_enabled
	audio_volume_slider.value = data.audio_value
	music_volume_button.pressed = data.music_enabled
	music_volume_slider.value = data.music_value
	update_audio_toggle()
	update_music_toggle()
	update_fullscreen_button()
	enable_buttons()


func hide_menu() -> void:
	animation_player.play_backwards("show")
	disable_buttons()


func enable_buttons() -> void:
	controls_button.disabled = false
	fullscreen_button.disabled = false
	audio_volume_button.disabled = false
	audio_volume_slider.show()
	music_volume_button.disabled = false
	music_volume_slider.show()
	save_button.disabled = false
	back_button.disabled = false


func disable_buttons() -> void:
	controls_button.disabled = true
	fullscreen_button.disabled = true
	audio_volume_button.disabled = true
	audio_volume_slider.hide()
	music_volume_button.disabled = true
	music_volume_slider.hide()
	save_button.disabled = true
	back_button.disabled = true


func load_stats() -> void:
	var file: File = File.new()
	if file.file_exists(FILE):
		file.open(FILE, File.READ)
		var loaded_data = parse_json(file.get_as_text())
		file.close()
		if typeof(loaded_data) == TYPE_DICTIONARY:
			data = loaded_data
			#print("Settings: %s" % data)
		else: save_settings()
	else: save_settings()


func save_settings() -> void:
	data.audio_enabled = audio_volume_button.pressed
	data.audio_value = audio_volume_slider.value
	data.music_enabled = music_volume_button.pressed
	data.music_value = music_volume_slider.value
	data.fullscreen = fullscreen_button.pressed
	var file: File = File.new()
	file.open(FILE, File.WRITE)
	file.store_string(to_json(data))
	file.close()


func apply_settings() -> void:
	if data.audio_enabled:
		AudioServer.set_bus_volume_db(2, get_db_value(data.audio_value))
	else:
		AudioServer.set_bus_volume_db(2, get_db_value(0))

	if data.music_enabled:
		AudioServer.set_bus_volume_db(1, get_db_value(data.music_value))
	else:
		AudioServer.set_bus_volume_db(1, get_db_value(0))
	OS.window_fullscreen = data.fullscreen


func get_db_value(db_level: int) -> int:
	match db_level:
		0:
			db_level = -100
		10:
			db_level = -36
		20:
			db_level = -32
		30:
			db_level = -28
		40:
			db_level = -24
		50:
			db_level = -20
		60:
			db_level = -16
		70:
			db_level = -12
		80:
			db_level = -8
		90:
			db_level = -4
		100:
			db_level = 0
		_:
			db_level = 0
	return db_level


func _music_volume_button_pressed() -> void:
	UI.emit_signal("button_pressed")
	update_music_toggle()

func _audio_volume_button_pressed() -> void:
	UI.emit_signal("button_pressed")
	update_audio_toggle()

func _credits_pressed() -> void:
	UI.emit_signal("button_pressed")
	if UI.current_menu == UI.MAIN_MENU_SETTINGS:
		UI.emit_signal("changed", UI.MAIN_MENU_SETTINGS_CREDITS)
	elif UI.current_menu == UI.PAUSE_MENU_SETTINGS:
		UI.emit_signal("changed", UI.PAUSE_MENU_SETTINGS_CREDITS)



func update_audio_toggle() -> void:
	if audio_volume_button.pressed:
		audio_volume_button.text = "Audio Volume: On"
		audio_slider.show()
		audio_volume_button.focus_neighbour_right = audio_volume_slider.get_path()
		audio_volume_button.focus_neighbour_bottom = audio_volume_slider.get_path()
		audio_volume_button.focus_next = audio_volume_slider.get_path()
		music_volume_button.focus_neighbour_left = audio_volume_slider.get_path()
		music_volume_button.focus_neighbour_top = audio_volume_slider.get_path()
		music_volume_button.focus_previous = audio_volume_slider.get_path()
	else:
		audio_volume_button.text = "Audio Volume: Off"
		audio_slider.hide()
		audio_volume_button.focus_neighbour_right = music_volume_button.get_path()
		audio_volume_button.focus_neighbour_bottom = music_volume_button.get_path()
		audio_volume_button.focus_next = music_volume_button.get_path()
		music_volume_button.focus_neighbour_left = audio_volume_button.get_path()
		music_volume_button.focus_neighbour_top = audio_volume_button.get_path()
		music_volume_button.focus_previous = audio_volume_button.get_path()


func update_music_toggle() -> void:
	if music_volume_button.pressed:
		music_volume_button.text = "Music Volume: On"
		music_slider.show()
		music_volume_button.focus_neighbour_right = music_volume_slider.get_path()
		music_volume_button.focus_neighbour_bottom = music_volume_slider.get_path()
		music_volume_button.focus_next = music_volume_slider.get_path()
		music_volume_slider.focus_neighbour_right = credits_button.get_path()
		music_volume_slider.focus_neighbour_bottom = credits_button.get_path()
		music_volume_slider.focus_next = back_button.get_path()
		credits_button.focus_neighbour_left = music_volume_slider.get_path()
		credits_button.focus_neighbour_top = music_volume_slider.get_path()
		credits_button.focus_previous = music_volume_slider.get_path()
		save_button.focus_neighbour_top = music_volume_slider.get_path()
	else:
		music_volume_button.text = "Music Volume: Off"
		music_slider.hide()
		music_volume_button.focus_neighbour_right = credits_button.get_path()
		music_volume_button.focus_neighbour_bottom = credits_button.get_path()
		music_volume_button.focus_next = credits_button.get_path()
		credits_button.focus_neighbour_left = music_volume_button.get_path()
		credits_button.focus_neighbour_top = music_volume_button.get_path()
		credits_button.focus_previous = music_volume_button.get_path()
		save_button.focus_neighbour_top = music_volume_button.get_path()


func _back_pressed() -> void:
	UI.emit_signal("button_pressed", true)
	match UI.current_menu:
		UI.MAIN_MENU_SETTINGS:
			UI.emit_signal("changed", UI.MAIN_MENU)
		UI.PAUSE_MENU_SETTINGS:
			UI.emit_signal("changed", UI.PAUSE_MENU)


func update_fullscreen_button() -> void:
	if fullscreen_button.pressed:
		fullscreen_button.text = "Fullscreen Mode: On"
	else:
		fullscreen_button.text = "Fullscreen Mode: Off"


func fullscreen_changed() -> void:
	if OS.window_fullscreen and not fullscreen_button.pressed:
		fullscreen_button.pressed = true
	elif not OS.window_fullscreen and fullscreen_button.pressed:
		fullscreen_button.pressed = false
	update_fullscreen_button()


func _save_pressed() -> void:
	save_settings()
	apply_settings()
	UI.emit_signal("button_pressed")
	UI.emit_signal("show_notification", "Settings Saved")


func _controls_button_pressed() -> void:
	UI.emit_signal("button_pressed")


func _fullscreen_button_pressed() -> void:
	UI.emit_signal("button_pressed")
	update_fullscreen_button()


func _audio_volume_changed(value: int) -> void:
	audio_volume_label.text = "Audio Volume: %s" % str(value)


func _music_volume_changed(value: int) -> void:
	music_volume_label.text = "Music Volume: %s" % str(value)
