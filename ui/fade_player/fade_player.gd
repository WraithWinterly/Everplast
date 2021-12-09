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
onready var animation_player: AnimationPlayer = $FadeRect/AnimationPlayer
onready var level_animation_player: AnimationPlayer = $FadeRect/Control/AnimationPlayer


func _ready() -> void:
	var __: int
	__ = GlobalEvents.connect("level_changed", self, "_level_changed")
	__ = GlobalEvents.connect("level_completed", self, "_level_completed")
	__ = GlobalEvents.connect("level_subsection_changed", self, "_level_subsection_changed")
	__ = GlobalEvents.connect("player_died", self, "_player_died")
	__ = GlobalEvents.connect("story_w1_boss_killed", self, "_story_w1_boss_killed")
	__ = GlobalEvents.connect("story_w1_boss_level_end_completed", self, "_story_w1_boss_level_end_completed")
	__ = GlobalEvents.connect("ui_play_pressed", self, "transition")
	__ = GlobalEvents.connect("ui_profile_selector_profile_pressed", self, "_ui_profile_selector_profile_pressed")
	__ = GlobalEvents.connect("ui_profile_selector_return_pressed", self, "_ui_profile_selector_return_pressed")
	__ = GlobalEvents.connect("ui_profile_selector_delete_prompt_yes_pressed", self, "_ui_profile_selector_delete_prompt_yes_pressed")
	__ = GlobalEvents.connect("ui_pause_menu_return_prompt_yes_pressed", self, "_ui_pause_menu_return_prompt_yes_pressed")
	__ = GlobalEvents.connect("ui_settings_erase_all_prompt_yes_pressed", self, "_ui_settings_erase_all_prompt_yes_pressed")
	__ = GlobalEvents.connect("ui_settings_erase_all_prompt_extra_no_pressed", self, "_ui_settings_erase_all_prompt_extra_no_pressed")
	__ = GlobalEvents.connect("ui_settings_reset_settings_prompt_yes_pressed", self, "_ui_settings_reset_settings_prompt_yes_pressed")
	__ = animation_player.connect("animation_finished", self, "_anim_finished")

	fade_rect.modulate = Color8(0, 0, 0, 255)
	fade_rect.show()
	play(true)
	pause_mode = PAUSE_MODE_PROCESS


func play(fade_out: bool) -> void:
	if not fade_out:
		animation_player.play("fade")
		GlobalUI.fade_player_playing = true
	else:
		animation_player.play_backwards("fade")
		GlobalUI.fade_player_playing = true


func transition() -> void:
	for icon in world_icons.get_children():
		icon.hide()
	GlobalUI.menu_locked = true
	animation_player.get_animation("fade").length = 0.4
	fade_rect.color = Color8(0, 0, 0, 255)
	play(false)
	yield(GlobalEvents, "ui_faded")
	if animation_player.is_playing():
		return
	play(true)
	yield(GlobalEvents, "ui_faded")
	GlobalUI.menu_locked = false


func transition_once() -> void:
	play(false)


func _level_changed(world: int = 0, level: int = 0) -> void:
	animation_player.stop()
	animation_player.get_animation("fade").length = 1.4
	GlobalUI.menu_locked = true
	label.text = "%s - %s" % [GlobalLevel.WORLD_NAMES[world], level]

	for w_icon in world_icons.get_children():
		if int(w_icon.name) == world:
			world_icons.show()
			w_icon.show()
		else:
			w_icon.hide()

	match world:
		1:
			fade_rect.color = color_world_1
		2:
			fade_rect.color = color_world_2
		3:
			fade_rect.color = color_world_3
		4:
			fade_rect.color = color_world_4
		_:
			fade_rect.color = color_world_error
			label.text = "Unofficial World - %s" % level

	level_animation_player.play("level")
	play(false)
	yield(GlobalEvents, "ui_faded")
	play(true)
	GlobalUI.menu_locked = false
	get_tree().paused = false


func _level_completed() -> void:
	transition()


func _level_subsection_changed(_pos: Vector2) -> void:
	GlobalUI.menu_locked = true
	get_tree().paused = true
	animation_player.get_animation("fade").length = 0.4
	transition()
	match GlobalLevel.current_world:
		1:
			fade_rect.color = color_world_1
		2:
			fade_rect.color = color_world_2
		3:
			fade_rect.color = color_world_3
		4:
			fade_rect.color = color_world_4
		_:
			fade_rect.color = color_world_error
	yield(GlobalEvents, "ui_faded")
	GlobalUI.menu_locked = false
	get_tree().paused = false


func _player_died() -> void:
	transition()


func _story_w1_boss_killed() -> void:
	yield(GlobalEvents, "ui_dialogue_hidden")
	transition()


func _story_w1_boss_level_end_completed() -> void:
	transition()


func _ui_profile_selector_profile_pressed() -> void:
	transition()


func _ui_profile_selector_return_pressed() -> void:
	if GlobalUI.menu == GlobalUI.Menus.PROFILE_SELECTOR:
		transition()


func _ui_profile_selector_delete_prompt_yes_pressed() -> void:
	transition()

	yield(GlobalEvents, "ui_faded")
	yield(GlobalEvents, "ui_faded")

	GlobalEvents.emit_signal("ui_notification_shown", "%s %s %s" % [tr("notification.profile_erased"), (GlobalUI.profile_index + 1), tr("notification.profile_erased.2")])


func _ui_pause_menu_return_prompt_yes_pressed() -> void:
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
	if not animation_player.is_playing():
		GlobalUI.fade_player_playing = false
