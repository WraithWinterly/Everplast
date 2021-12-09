extends Control

var dialogue_content: Array = []

var dialogue_index: int = 0
var content_length: int = 1
var queued_menu_check: int = GlobalUI.Menus.NONE

var next_dialogue_allowed := false
var dialogue_locked := false
var fast_speed := false
var was_in_cutscene := false
var clicked := false

onready var anim_player: AnimationPlayer = $AnimationPlayer
onready var header: Panel = $Panels/Header
onready var header_text: Label = $Panels/Header/Text
onready var content_text: Label = $Panels/Content/Text
onready var content_text_anim_player: AnimationPlayer = $Panels/Content/Text/AnimationPlayer
onready var pointer: TextureRect = $Panels/Content/Pointer
onready var pointer_anim_player: AnimationPlayer = $Panels/Content/Pointer/AnimationPlayer
onready var show_sound: AudioStreamPlayer = $Show
onready var text_sound: AudioStreamPlayer = $Text


func _ready() -> void:
	var __: int
	__ = GlobalEvents.connect("level_changed", self, "_level_changed")
	__ = GlobalEvents.connect("ui_dialogued", self, "_ui_dialogued")

	hide()
	header.hide()
	pointer.hide()


func _input(event: InputEvent) -> void:
	if (event.is_action_pressed("move_jump") or event.is_action_pressed("fire") or event.is_action_pressed("ui_cancel")):
		if next_dialogue_allowed:
			if event.is_action_pressed("fire"):
				clicked = true
			next_dialogue()
			print(" next duia")
		else:
			fast_speed = true
			update_dialogue_speed()


func show_dialogue() -> void:
	if dialogue_locked: return

	was_in_cutscene = queued_menu_check == GlobalUI.Menus.CUTSCENE

	content_text.percent_visible = 0
	content_text_anim_player.stop()
	content_text.text = ""
	header_text.text = ""

	show()
	header.show()
	update_dialogue(false)
	anim_player.play("show")
	get_tree().paused = true

	yield(anim_player, "animation_finished")
	next_dialogue()


func next_dialogue() -> void:
	if dialogue_locked: return

#	if GlobalUI.menu == GlobalUI.Menus.NONE:
#		GlobalUI.menu = GlobalUI.Menus.DIALOGUE

	fast_speed = false
	content_text.text = ""
	header_text.text = ""
	show_sound.play()
	show_sound.pitch_scale = 0.8

	update_dialogue(false)

	if dialogue_index >= dialogue_content.size():
		close_dialogue()
		return

	var content = dialogue_content[dialogue_index]

	content_text.text = content[0]

	if content[1] == "":
		content[1] = "???"
	header_text.text = content[1]

	if not content[2] == "":
		if has_method(content[2]):
			call(content[2])
		else:
			printerr("dialogue Function %s Does Not Exist!" % content[2])

	content_length = int(content_text.text.length())

	# Cannot divide by zero crash
	if content_length == 0:
		content_length = 1

	update_dialogue_speed()

	content_text_anim_player.play("show")
	if not content_text.text == "":
		yield(content_text_anim_player, "animation_finished")
	update_dialogue(true)
	dialogue_index += 1


func close_dialogue() -> void:
	dialogue_locked = true

	# Prevents shooting
	if clicked:
		GlobalInput.ignore_fire = true
		clicked = false

	GlobalEvents.emit_signal("ui_dialogue_hidden")
	dialogue_index = 0

#	if not GlobalUI.menu == GlobalUI.Menus.DIALOGUE:
#		return
	dialogue_content.clear()

	anim_player.play_backwards("show")

	# Prevents jump after closing
	yield(get_tree(), "physics_frame")

	if not was_in_cutscene:
		GlobalUI.menu = GlobalUI.Menus.NONE
		get_tree().paused = false
	else:
		GlobalUI.menu = GlobalUI.Menus.CUTSCENE


	dialogue_index = 0
	content_text.text = ""
	content_text_anim_player.stop()

	yield(anim_player, "animation_finished")

	content_text.percent_visible = 0

	if not anim_player.is_playing():
		hide()

	content_text.text = ""
	dialogue_locked = false


func update_dialogue(allowed := false) -> void:
	next_dialogue_allowed = allowed

	if allowed:
		pointer.show()
		pointer_anim_player.play("float")
	else:
		pointer.hide()
		pointer_anim_player.stop()


func update_dialogue_speed() -> void:
	if content_length == 0:
		content_length = 1

	if fast_speed:
		content_text_anim_player.playback_speed = (1.0 / content_length * 50)
	else:
		content_text_anim_player.playback_speed = (1.0 / content_length * 10)


func _level_changed(_world: int, _level: int) -> void:
	if GlobalUI.menu == GlobalUI.Menus.DIALOGUE:
		close_dialogue()
		hide()


func _ui_dialogued(content: String, person: String = "", func_call: String = "") -> void:
	if dialogue_locked: return

	queued_menu_check = GlobalUI.menu


	if GlobalUI.menu == GlobalUI.Menus.DIALOGUE:
		dialogue_content.push_back([content, person, func_call])
	else:
		GlobalUI.menu = GlobalUI.Menus.DIALOGUE
		dialogue_content.clear()
		dialogue_content.push_back([content, person, func_call])
		show_dialogue()
