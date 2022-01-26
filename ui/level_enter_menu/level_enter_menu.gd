extends Control

var modulate_val: int = 200

var allowed := false

onready var fade_player = get_node(GlobalPaths.FADE_PLAYER)
onready var start_button: Button = $Panel/HBoxContainer/Start
onready var back_button: Button = $Panel/HBoxContainer/Back
onready var anim_player: AnimationPlayer = $AnimationPlayer
onready var not_active: Label = $Panel/LogoBG/NotActive
onready var checkpoint: TextureRect = $Panel/LogoBG/Checkpoint
onready var world_icons: HBoxContainer = $Panel/LogoBG/WorldIcons
onready var logo_color_rect: ColorRect = $Panel/LogoBG/ColorRect
onready var gem_color_rect: ColorRect = $Panel/GemBG/ColorRect
onready var label: Label = $Panel/Label
onready var gem_textures := [
	$Panel/GemBG/GenContainer/GemSlot1/Gem,
	$Panel/GemBG/GenContainer/GemSlot2/Gem,
	$Panel/GemBG/GenContainer/GemSlot3/Gem,
]


func _ready() -> void:
	var __: int
	__ = GlobalEvents.connect("level_changed", self, "_level_changed")
	__ = GlobalEvents.connect("ui_level_enter_menu_pressed", self, "_level_enter_menu_pressed")
	__ = start_button.connect("pressed", self, "_start_pressed")
	__ = back_button.connect("pressed", self, "_back_pressed")

	hide()
	for gem in gem_textures:
		gem.hide()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and GlobalUI.menu == GlobalUI.Menus.LEVEL_ENTER and not GlobalUI.menu_locked:
		_back_pressed()
		get_tree().set_input_as_handled()


func disable_buttons() -> void:
	start_button.disabled = true
	back_button.disabled = true


func enable_buttons() -> void:
	start_button.disabled = false
	back_button.disabled = false


func hide_menu() -> void:
	disable_buttons()
	anim_player.play_backwards("show")
	get_tree().paused = false
	yield(anim_player, "animation_finished")
	if not anim_player.is_playing():
		$BGBlur.hide()


func show_menu() -> void:
	enable_buttons()
	get_tree().paused = true
	label.text = "%s - %s" % [GlobalLevel.WORLD_NAMES[GlobalLevel.selected_world], GlobalLevel.selected_level]
	anim_player.play("show")
	show()

	allowed = false

	if GlobalSave.get_stat("world_max") >= GlobalLevel.selected_world:
		if GlobalSave.get_stat("world_max") == GlobalLevel.selected_world:
			if GlobalSave.get_stat("level_max") >= GlobalLevel.selected_level:
				allowed = true
		else:
				allowed = true

	checkpoint.hide()

	if GlobalLevel.checkpoint_active \
			and GlobalLevel.checkpoint_world == GlobalLevel.selected_world \
			and GlobalLevel.checkpoint_level == GlobalLevel.selected_level:
		checkpoint.show()

	for w_icon in world_icons.get_children():
		if int(w_icon.name) == GlobalLevel.selected_world:
			world_icons.show()
			w_icon.show()
		else:
			w_icon.hide()

	match GlobalLevel.selected_world:
		1:
			logo_color_rect.color = fade_player.color_world_1
			gem_color_rect.color = fade_player.color_world_1
		2:
			logo_color_rect.color = fade_player.color_world_2
			logo_color_rect.color.a8 = modulate_val
			gem_color_rect.color = fade_player.color_world_2

		3:
			logo_color_rect.color = fade_player.color_world_3
			logo_color_rect.color.a8 = modulate_val
			gem_color_rect.color = fade_player.color_world_3
#		4:
#			logo_color_rect.color = fade_player.color_world_4
#			logo_color_rect.color.a8 = modulate_val
#			gem_color_rect.color = fade_player.color_world_4
#		5:
#			logo_color_rect.color = fade_player.color_world_5
#			logo_color_rect.color.a8 = modulate_val
#			gem_color_rect.color = fade_player.color_world_5
#		6:
#			logo_color_rect.color = fade_player.color_world_6
#			logo_color_rect.color.a8 = modulate_val
#			gem_color_rect.color = fade_player.color_world_6
		_:
			logo_color_rect.color = fade_player.color_world_error
			logo_color_rect.color.a8 = modulate_val
			gem_color_rect.color = fade_player.color_world_error

	logo_color_rect.color.a8 = modulate_val
	gem_color_rect.color.a8 = modulate_val

	start_button.visible = allowed
	not_active.visible = not allowed

	if allowed:

		start_button.grab_focus()
	else:

		back_button.grab_focus()

	var index: int = 0
	var gem_dict = GlobalSave.get_stat("gems")

	for gem in gem_textures:
		if gem_dict.has(str(GlobalLevel.selected_world)):
			if gem_dict[str(GlobalLevel.selected_world)].has(str(GlobalLevel.selected_level)):
				if gem_dict[str(GlobalLevel.selected_world)][str(GlobalLevel.selected_level)][index]:
					gem.show()
					gem.get_node("AnimationPlayer").play("show")
				else:
					gem.hide()
			else:
				gem.hide()
		else:
			gem.hide()
		index += 1


func _level_changed(_world: int, _level: int) -> void:
	if GlobalUI.menu == GlobalUI.Menus.LEVEL_ENTER:
		hide_menu()


func _level_enter_menu_pressed() -> void:
	show_menu()


func _start_pressed() -> void:
	GlobalUI.menu = GlobalUI.Menus.NONE
	GlobalEvents.emit_signal("level_changed", GlobalLevel.selected_world, GlobalLevel.selected_level)
	get_tree().paused = true
	disable_buttons()
	yield(GlobalEvents, "ui_faded")
	hide_menu()
	get_tree().paused = false


func _back_pressed() -> void:
	hide_menu()
	GlobalUI.menu = GlobalUI.Menus.NONE
	GlobalEvents.emit_signal("ui_button_pressed", true)
