extends CanvasLayer
class_name FadePlayer

export(Color, RGB) var color_world_error
export(Color, RGB) var color_world_1
export(Color, RGB) var color_world_2
export(Color, RGB) var color_world_3
export(Color, RGB) var color_world_4

onready var fade_rect: ColorRect = $FadeRect
onready var world_icons = $FadeRect/Control/HBoxContainer/Control/WorldIcons
onready var label: Label = $FadeRect/Control/HBoxContainer/Label
onready var anim_player: AnimationPlayer = $FadeRect/AnimationPlayer
onready var anim_player_logo: AnimationPlayer = $FadeRect/MainLogo/AnimationPlayer
onready var level_anim_player: AnimationPlayer = $FadeRect/Control/AnimationPlayer
onready var level_enter: AudioStreamPlayer = $LevelEnter
onready var main_logo: CenterContainer = $FadeRect/MainLogo

var color: Color

func _ready() -> void:
	var __: int
	__ = GlobalEvents.connect("level_changed", self, "_level_changed")
	__ = GlobalEvents.connect("level_completed", self, "_level_completed")
	__ = GlobalEvents.connect("level_subsection_changed", self, "_level_subsection_changed")
	__ = GlobalEvents.connect("player_died", self, "_player_died")
	__ = GlobalEvents.connect("story_boss_killed", self, "_story_boss_killed")
	__ = GlobalEvents.connect("story_boss_level_end_completed", self, "_story_boss_level_end_completed")
	__ = GlobalEvents.connect("ui_play_pressed", self, "_ui_play_pressed")
	__ = GlobalEvents.connect("ui_profile_selector_profile_pressed", self, "_ui_profile_selector_profile_pressed")
	__ = GlobalEvents.connect("ui_profile_selector_return_pressed", self, "_ui_profile_selector_return_pressed")
	__ = GlobalEvents.connect("ui_profile_selector_delete_prompt_yes_pressed", self, "_ui_profile_selector_delete_prompt_yes_pressed")
	__ = GlobalEvents.connect("ui_pause_menu_return_prompt_yes_pressed", self, "_ui_pause_menu_return_prompt_yes_pressed")
	__ = GlobalEvents.connect("ui_settings_erase_all_prompt_yes_pressed", self, "_ui_settings_erase_all_prompt_yes_pressed")
	__ = GlobalEvents.connect("ui_settings_erase_all_prompt_extra_no_pressed", self, "_ui_settings_erase_all_prompt_extra_no_pressed")
	__ = GlobalEvents.connect("ui_settings_reset_settings_prompt_yes_pressed", self, "_ui_settings_reset_settings_prompt_yes_pressed")
	__ = anim_player.connect("animation_finished", self, "_anim_finished")

	fade_rect.show()
	pause_mode = PAUSE_MODE_PROCESS
	anim_player.pause_mode = PAUSE_MODE_PROCESS
	main_logo.hide()
	main_logo.set_as_toplevel(true)

#func _physics_process(_delta: float) -> void:
#	print(fade_rect.material.get_shader_param("position"))
#
#func _input(event: InputEvent) -> void:
#	if event.is_action_pressed("ui_up"):
#		anim_player.play("fade")
#	if event.is_action_pressed("ui_down"):
#		anim_player.play("fade_fancy")


func play(fade_out: bool, fancy := false) -> void:
	fade_rect.material.set_shader_param("in_color", color)
	fade_rect.color = color

	if not fade_out:
		if fancy:
			anim_player.play("fade_fancy")
			anim_player_logo.play("fade")
		else:
			anim_player.play("fade")
			anim_player_logo.play("fade")

		GlobalUI.fade_player_playing = true

	else:
		if fancy:
			anim_player.play_backwards("fade_fancy")
			anim_player_logo.play_backwards("fade")
		else:
			anim_player.play_backwards("fade")
			anim_player_logo.play_backwards("fade")

		GlobalUI.fade_player_playing = true


func transition(with_color := false, fancy := false) -> void:
	for icon in world_icons.get_children():
		icon.hide()

	GlobalUI.menu_locked = true

	if with_color:
		anim_player.get_animation("fade").length = 0.75
		anim_player.get_animation("fade_fancy").length = 0.75
		set_color_per_world(GlobalSave.get_stat("world_max"), 0)
		main_logo.show()
	else:
		anim_player.get_animation("fade").length = 0.4
		anim_player.get_animation("fade_fancy").length = 0.4
		color = Color8(0, 0, 0, 255)
		main_logo.hide()

	if fancy:
		play(false, true)
	else:
		play(false)

	yield(GlobalEvents, "ui_faded")

#	if anim_player.is_playing():
#		return

	if fancy:
		play(true, true)
	else:
		play(true)

	yield(GlobalEvents, "ui_faded")

	GlobalUI.menu_locked = false


func transition_once() -> void:
	play(false)


func set_color_per_world(world: int, level: int) -> void:
	match world:
		1:
			color = color_world_1
		2:
			color = color_world_2
		3:
			color = color_world_3
		4:
			color = color_world_4
		_:
			color = color_world_error
			label.text = "Unofficial World - %s" % level


func _level_changed(world: int = 0, level: int = 0) -> void:
	set_color_per_world(world, level)
	main_logo.hide()
	level_enter.play()
	#anim_player.stop()
	anim_player.get_animation("fade").length = 1.4
	anim_player.get_animation("fade_fancy").length = 1.4
	GlobalUI.menu_locked = true
	label.text = "%s - %s" % [GlobalLevel.WORLD_NAMES[world], level]

	for w_icon in world_icons.get_children():
		if int(w_icon.name) == world:
			world_icons.show()
			w_icon.show()
		else:
			w_icon.hide()


	level_anim_player.play("level")
	play(false)
	yield(GlobalEvents, "ui_faded")
	play(true)
	GlobalUI.menu_locked = false
	get_tree().paused = false


func _level_completed() -> void:
	transition(true, true)


func _level_subsection_changed(_pos: Vector2) -> void:
	GlobalUI.menu_locked = true
	get_tree().paused = true
	anim_player.get_animation("fade").length = 0.4
	anim_player.get_animation("fade_fancy").length = 0.4
	transition()

	match GlobalLevel.current_world:
		1:
			color = color_world_1
		2:
			color = color_world_2
		3:
			color = color_world_3
		4:
			color = color_world_4
		_:
			color = color_world_error

	yield(GlobalEvents, "ui_faded")

	GlobalUI.menu_locked = false
	get_tree().paused = false


func _player_died() -> void:
	transition(false, true)


func _story_boss_killed(_idx: int) -> void:
	yield(GlobalEvents, "ui_dialogue_hidden")
	transition()


func _story_boss_level_end_completed(_idx: int) -> void:
	transition()


func _ui_play_pressed() -> void:
	transition()


func _ui_profile_selector_profile_pressed() -> void:
	transition(true, true)


func _ui_profile_selector_return_pressed() -> void:
	if GlobalUI.menu == GlobalUI.Menus.PROFILE_SELECTOR:
		transition()


func _ui_profile_selector_delete_prompt_yes_pressed() -> void:
	transition()

	yield(GlobalEvents, "ui_faded")
	yield(GlobalEvents, "ui_faded")

	GlobalEvents.emit_signal("ui_notification_shown", "%s %s %s" % [tr("notification.profile_erased"), (GlobalUI.profile_index + 1), tr("notification.profile_erased.2")])


func _ui_pause_menu_return_prompt_yes_pressed() -> void:
	if Globals.game_state == Globals.GameStates.LEVEL:
		transition(false, true)
	else:
		transition()


func _ui_settings_erase_all_prompt_yes_pressed() -> void:
	play(false)


func _ui_settings_erase_all_prompt_extra_no_pressed() -> void:
	play(true)


func _ui_settings_reset_settings_prompt_yes_pressed() -> void:
	transition()


func _anim_finished(_anim_name: String) -> void:
	GlobalEvents.emit_signal("ui_faded")
	yield(get_tree(), "physics_frame")
	if not anim_player.is_playing():
		GlobalUI.fade_player_playing = false


func _on_Timer_timeout() -> void:
	play(true, true)
