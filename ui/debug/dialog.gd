extends Control

var can_next_dialog: bool = false

var dialog_index: int = 0

var dialog_content: Array = []

onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var header: Panel = $Panels/Header
onready var header_text: Label = $Panels/Header/Text
onready var content_text: Label = $Panels/Content/Text
onready var content_text_animation_player: AnimationPlayer = \
		$Panels/Content/Text/AnimationPlayer
onready var pointer: TextureRect = $Panels/Content/Pointer
onready var pointer_animation_player: AnimationPlayer = $Panels/Content/Pointer/AnimationPlayer
onready var show_sound: AudioStreamPlayer = $Show
onready var text_sound: AudioStreamPlayer = $Text


func _ready() -> void:
	UI.connect("changed", self, "_ui_changed")
	Signals.connect("dialog", self, "_dialog")
	Signals.connect("level_changed", self, "_level_changed")
	hide()
	header.hide()
	pointer.hide()

func _level_changed(_world: int, _level: int) -> void:
	close_dialog()

	hide()

func _ui_changed(menu: int) -> void:
	if menu == UI.NONE and UI.last_menu == UI.PAUSE_MENU_RETURN_PROMPT:
		close_dialog()
	if menu == UI.MAIN_MENU and visible:
		close_dialog()

func lol() -> void:
	Signals.emit_signal("level_changed", 2, 1)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("move_jump") and UI.current_menu == UI.NONE:
		if Globals.dialog_active and can_next_dialog:
			next_dialog()


func _dialog(content: String, person: String = "", func_call: String = "") -> void:
	if Globals.dialog_active:
		dialog_content.push_back([content, person, func_call])
	else:
		Globals.dialog_active = true
		dialog_content.clear()
		dialog_content.push_back([content, person, func_call])
		show_dialog()


func show_dialog() -> void:
	content_text.percent_visible = 0
	content_text_animation_player.stop()
	content_text.text = ""
	header_text.text = ""
	show()
	header.show()
	Globals.dialog_active = true
	update_dialog(false)
	animation_player.play("show")
	get_tree().paused = true
	yield(animation_player, "animation_finished")
	next_dialog()


func close_dialog() -> void:
	dialog_index = 0
	if Globals.dialog_active == false:
		return
	dialog_content.clear()
	animation_player.play_backwards("show")
	# prevents jump after closing
	yield(get_tree(), "physics_frame")
	if Globals.dialog_active:
		Globals.dialog_active = false
		get_tree().paused = false
	dialog_index = 0
	content_text.text = ""
	content_text_animation_player.stop()
	yield(animation_player, "animation_finished")
	content_text.percent_visible = 0
	if not animation_player.is_playing():
		hide()
	content_text.text = ""


func next_dialog() -> void:
	content_text.text = ""
	header_text.text = ""
	show_sound.play()
	show_sound.pitch_scale = 0.8
	update_dialog(false)
	if dialog_index >= dialog_content.size():
		close_dialog()
		return
	var content = dialog_content[dialog_index]
	content_text.text = content[0]

	if content[1] == "":
		content[1] = "???"
	header_text.text = content[1]
	if not content[2] == "":
		if has_method(content[2]):
			call(content[2])
		else:
			printerr("Dialog Function %s Does Not Exist!" % content[2])

	var content_length: int = int(content_text.text.length())

	# Cannot divide by zero crash
	if content_length == 0:
		content_length = 1
	content_text_animation_player.playback_speed = (1.0 / content_length * 10)
	content_text_animation_player.play("show")
	if not content_text.text == "":
		yield(content_text_animation_player, "animation_finished")
	update_dialog(true)
	dialog_index += 1


func update_dialog(allowed: bool = false) -> void:
	can_next_dialog = allowed
	if allowed:
		pointer.show()
		pointer_animation_player.play("float")
	else:
		pointer.hide()
		pointer_animation_player.stop()

