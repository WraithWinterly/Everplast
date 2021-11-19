extends CanvasLayer
class_name FadePlayer

export(Color, RGB) var color_world_error
export(Color, RGB) var color_world_1
export(Color, RGB) var color_world_2
export(Color, RGB) var color_world_3
export(Color, RGB) var color_world_4
export(Color, RGB) var color_world_5
export(Color, RGB) var color_world_6

onready var fade_rect: ColorRect = $FadeRect
onready var world_icons = $FadeRect/Control/HBoxContainer/Control/WorldIcons
onready var label: Label = $FadeRect/Control/HBoxContainer/Label
onready var animation_player: AnimationPlayer = $FadeRect/AnimationPlayer
onready var level_animation_player: AnimationPlayer = $FadeRect/Control/AnimationPlayer


func _ready() -> void:
	var __: int
	__ = UI.connect("changed", self, "_ui_changed")
	__ = Signals.connect("level_changed", self, "_level_changed")
	__ = Signals.connect("player_death", self, "_player_death")
	__ = Signals.connect("level_completed", self, "_level_completed")
	__ = Signals.connect("profile_deleted", self, "_profile_deleted")
	__ = Signals.connect("sublevel_changed", self, "_sublevel_changed")
	__ = Signals.connect("erase_all_started", self, "_erase_all_started")
	__ = Signals.connect("erase_all_canceled", self, "_erase_all_canceled")
	__ = Signals.connect("debug_enable_started", self, "_debug_enable_started")
	__ = Signals.connect("debug_enable_canceled", self, "_debug_enable_canceled")
	__ = Signals.connect("debug_enable_confirmed", self, "_debug_enable_confirmed")
	__ = animation_player.connect("animation_finished", self, "_on_animation_finished")
	fade_rect.modulate = Color8(0, 0, 0, 255)
	fade_rect.show()
	get_tree().paused = true
	play(true)
	yield(get_tree().create_timer(1), "timeout")
	get_tree().paused = false
	animation_player.get_animation("fade").length = 0.8


func _ui_changed(menu: int) -> void:
	match menu:
		UI.PROFILE_SELECTOR:
			if UI.last_menu == UI.MAIN_MENU:
				transition()
		UI.MAIN_MENU:
			if UI.last_menu == UI.PROFILE_SELECTOR or\
					UI.last_menu == UI.PAUSE_MENU_RETURN_PROMPT:
				transition()
		UI.NONE:
			if UI.last_menu == UI.PAUSE_MENU_RETURN_PROMPT or \
					UI.last_menu == UI.PROFILE_SELECTOR:
				transition()


func transition() -> void:
	for icon in world_icons.get_children():
		icon.hide()
	UI.menu_transitioning = true
	animation_player.get_animation("fade").length = 0.4
	fade_rect.color = Color8(0, 0, 0, 255)
	play(false)
	yield(UI, "faded")
	if animation_player.is_playing():
		return
	play(true)
	yield(UI, "faded")
	UI.menu_transitioning = false


func transition_once() -> void:
	play(false)


func play(fade_out: bool) -> void:
	if not fade_out:
		animation_player.play("fade")
	else:
		animation_player.play_backwards("fade")


func _level_changed(world: int = 0, level: int = 0, _from_start: bool = false) -> void:
	animation_player.get_animation("fade").length = 0.8
	UI.menu_transitioning = true
	label.text = "%s - %s" % [Globals.get_main().world_names[world], level]
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
		5:
			fade_rect.color = color_world_5
		6:
			fade_rect.color = color_world_6
		_:
			fade_rect.color = color_world_error
			label.text = "Not an official level: \"%s - %s\"" % [Globals.get_main().world_names[world], level]
	level_animation_player.play("level")
	play(false)
	yield(UI, "faded")
	play(true)
	UI.menu_transitioning = false


func _sublevel_changed(_pos: Vector2) -> void:
	UI.menu_transitioning = true
	get_tree().paused = true
	animation_player.get_animation("fade").length = 0.4
	transition()
	match LevelController.current_world:
		1:
			fade_rect.color = color_world_1
		2:
			fade_rect.color = color_world_2
		3:
			fade_rect.color = color_world_3
		4:
			fade_rect.color = color_world_4
		5:
			fade_rect.color = color_world_5
		6:
			fade_rect.color = color_world_6
		_:
			fade_rect.color = color_world_error
	yield(UI, "faded")
	UI.menu_transitioning = false
	get_tree().paused = false


func _on_animation_finished(_anim_name: String) -> void:
	UI.emit_signal("faded")


func _return_pressed() -> void:
	transition()


func _player_death() -> void:
	transition()


func _profile_deleted() -> void:
	yield(UI, "changed")
	transition()
	yield(UI, "faded")
	yield(UI, "faded")
	UI.emit_signal("show_notification", "Profile %s Erased!" % (UI.profile_index + 1))


func _world_selector_ready() -> void:
	transition()


func _level_completed() -> void:
	transition()


func _erase_all_started() -> void:
	play(false)


func _erase_all_canceled() -> void:
	play(true)


func _debug_enable_started() -> void:
	play(false)


func _debug_enable_canceled() -> void:
	play(true)


func _debug_enable_confirmed() -> void:
	play(true)
