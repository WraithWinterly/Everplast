extends CanvasLayer
class_name FadePlayer

export(Color, RGB) var color_world_error
export(Color, RGB) var color_world_1
export(Color, RGB) var color_world_2
export(Color, RGB) var color_world_3

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
	__ = GlobalEvents.connect("story_w3_attempt_beat", self, "_story_w3_attempt_beat")
	__ = GlobalEvents.connect("story_w3_fernand_anim_finished", self, "_story_w3_fernand_anim_finished")
	__ = GlobalEvents.connect("story_fernand_beat", self, "_story_fernand_beat")
	__ = GlobalEvents.connect("ui_profile_selector_profile_pressed", self, "_ui_profile_selector_profile_pressed")
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


func play(fade_out: bool, fancy := false, black := false) -> void:
	fade_rect.material.set_shader_param("in_color", color)
	fade_rect.color = color

	if black or Globals.death_in_progress:
		fade_rect.material.set_shader_param("in_color", Color(0, 0, 0, 255))
		fade_rect.color = Color(0, 0, 0, 255)

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


func transition(with_color := false, fancy := false, black := false) -> void:
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
		if black:
			play(false, true, true)
		else:
			play(false, true)
	else:
		if black:
			play(false, false, true)
		else:
			play(false)

	yield(GlobalEvents, "ui_faded")

#	if anim_player.is_playing():
#		return

	if fancy:
		if black:
			play(true, true, true)
		else:
			play(true, true)
	else:
		if black:
			play(true, false, true)
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
		_:
			color = color_world_error
			label.text = "Unofficial World - %s" % level


func _level_changed(world: int = 0, level: int = 0) -> void:
	GlobalUI.menu_locked = true
	set_color_per_world(world, level)
	main_logo.hide()

	if Globals.death_in_progress:
		anim_player.get_animation("fade").length = 0.4
		anim_player.get_animation("fade_fancy").length = 0.4
		play(false, true)
		yield(anim_player, "animation_finished")
		level_enter.play()
		play(true, true)
		yield(anim_player, "animation_finished")
		GlobalUI.menu_locked = false
		get_tree().paused = false
		return

	level_enter.play()
	#anim_player.stop()
	anim_player.get_animation("fade").length = 1.4
	anim_player.get_animation("fade_fancy").length = 1.4

	for w_icon in world_icons.get_children():
		if int(w_icon.name) == world:
			world_icons.show()
			w_icon.show()
		else:
			w_icon.hide()


	level_anim_player.play("level")
	yield(get_tree(), "physics_frame")

	label.text = "%s %s\n%s - %s" % [tr("profile_selector.button.normal"), GlobalSave.profile + 1, GlobalLevel.WORLD_NAMES[world], level]
	if world == 4:
		label.text = "The End"
	play(false)
	yield(GlobalEvents, "ui_faded")
	play(true)
	GlobalUI.menu_locked = false
	get_tree().paused = false


func _level_completed() -> void:
	transition(true, true, false)


func _level_subsection_changed(_pos: Vector2) -> void:
	GlobalUI.menu_locked = true
	get_tree().paused = true
	anim_player.get_animation("fade").length = 0.4
	anim_player.get_animation("fade_fancy").length = 0.4
	transition(false, true, true)

	match GlobalLevel.current_world:
		1:
			color = color_world_1
		2:
			color = color_world_2
		3:
			color = color_world_3
		_:
			color = color_world_error

	yield(GlobalEvents, "ui_faded")

	GlobalUI.menu_locked = false
	get_tree().paused = false


func _player_died() -> void:
	if Globals.game_state == Globals.GameStates.WORLD_SELECTOR:
		transition(false, true, true)


func _story_boss_killed(_idx: int) -> void:
	yield(GlobalEvents, "ui_dialogue_hidden")
	transition()


func _story_w3_attempt_beat() -> void:
	yield(GlobalEvents, "ui_dialogue_hidden")
	transition()


func _story_boss_level_end_completed(_idx: int) -> void:
	transition()


func _story_w3_fernand_anim_finished() -> void:
	transition()


func _story_fernand_beat() -> void:
	transition(true, true)



func _ui_profile_selector_profile_pressed() -> void:
	transition(true, true)


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
