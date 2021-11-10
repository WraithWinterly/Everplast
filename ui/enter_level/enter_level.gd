extends Control

var enter_level: bool = false
var allowed: bool = false

onready var main: Main = get_tree().root.get_node("Main")
onready var fade_player = main.get_node("FadePlayer")
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
	UI.connect("changed", self, "_ui_changed")
	start_button.connect("pressed", self, "_start_pressed")
	back_button.connect("pressed", self, "_back_pressed")

	hide()
	for gem in gem_textures:
		gem.hide()


func show_menu() -> void:
	show()
	enable_buttons()
	get_tree().paused = true
	anim_player.play("show")
	label.text = "%s - %s" % [main.world_names[Globals.selected_world], Globals.selected_level]

	allowed = false

	if PlayerStats.get_stat("world_max") >= Globals.selected_world:
		if PlayerStats.get_stat("world_max") == Globals.selected_world:
			if PlayerStats.get_stat("level_max") >= Globals.selected_level:
				allowed = true
		else:
				allowed = true

	checkpoint.hide()

	if LevelController.checkpoint_active \
			and LevelController.checkpoint_world == Globals.selected_world \
			and LevelController.checkpoint_level == Globals.selected_level:
		checkpoint.show()

	for w_icon in world_icons.get_children():
		if int(w_icon.name) == Globals.selected_world:
			world_icons.show()
			w_icon.show()
		else:
			w_icon.hide()

	match Globals.selected_world:
		1:
			logo_color_rect.color = fade_player.color_world_1
			gem_color_rect.color = fade_player.color_world_1
		2:
			logo_color_rect.color = fade_player.color_world_2
			gem_color_rect.color = fade_player.color_world_2
		3:
			logo_color_rect.color = fade_player.color_world_3
			gem_color_rect.color = fade_player.color_world_3
		4:
			logo_color_rect.color = fade_player.color_world_4
			gem_color_rect.color = fade_player.color_world_4
		5:
			logo_color_rect.color = fade_player.color_world_5
			gem_color_rect.color = fade_player.color_world_5
		6:
			logo_color_rect.color = fade_player.color_world_6
			gem_color_rect.color = fade_player.color_world_6
		_:
			logo_color_rect.color = fade_player.color_world_error
			gem_color_rect.color = fade_player.color_world_error

	start_button.visible = allowed
	not_active.visible = not allowed

	if allowed:
		start_button.grab_focus()
	else:
		back_button.grab_focus()

	var index: int = 0
	var gem_dict = PlayerStats.get_stat("gems")

	for gem in gem_textures:
		if gem_dict.has(str(Globals.selected_world)):
			if gem_dict[str(Globals.selected_world)].has(str(Globals.selected_level)):
				if gem_dict[str(Globals.selected_world)][str(Globals.selected_level)][index]:
					gem.show()
					gem.get_node("AnimationPlayer").play("show")
				else:
					gem.hide()
			else:
				gem.hide()
		else:
			gem.hide()
		index += 1


func disable_buttons() -> void:
	start_button.disabled = true
	back_button.disabled = true


func enable_buttons() -> void:
	start_button.disabled = false
	back_button.disabled = false


func _ui_changed(menu: int) -> void:
	if UI.last_menu == UI.WORLD_SELECTOR_LEVEL_ENTER and menu == UI.NONE:
		if enter_level:
			enter_level = false
			Signals.emit_signal("level_changed", Globals.selected_world, Globals.selected_level)
			yield(UI, "faded")
			get_tree().paused = false
			hide()
		else:
			hide_menu()
	elif menu == UI.WORLD_SELECTOR_LEVEL_ENTER and UI.last_menu == UI.NONE:
		UI.emit_signal("button_pressed")
		show_menu()


func _start_pressed() -> void:
	enter_level = true
	UI.emit_signal("changed", UI.NONE)


func hide_menu() -> void:
	disable_buttons()
	anim_player.play_backwards("show")
	get_tree().paused = false
	yield(anim_player, "animation_finished")


func _back_pressed() -> void:
	enter_level = false
	UI.emit_signal("changed", UI.NONE)
	UI.emit_signal("button_pressed", true)

