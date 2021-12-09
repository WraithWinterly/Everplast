extends Control

var is_visible: bool = false

onready var anim_player := $AnimationPlayer as AnimationPlayer


func _ready() -> void:
	var __: int
	__ = GlobalEvents.connect("level_changed", self, "_level_changed")
	__ = GlobalEvents.connect("ui_pause_menu_return_pressed", self, "_ui_pause_menu_return_pressed")
	__ = GlobalEvents.connect("ui_inventory_opened", self, "_ui_inventory_opened")
	__ = GlobalEvents.connect("ui_pause_menu_pressed", self, "_ui_pause_menu_pressed")
	__ = GlobalEvents.connect("ui_level_enter_menu_pressed", self, "_ui_level_enter_menu_pressed")

	hide()


func _physics_process(_delta: float) -> void:
	if not is_visible and not anim_player.is_playing() and GlobalUI.menu == GlobalUI.Menus.NONE and Globals.game_state == Globals.GameStates.WORLD_SELECTOR and not GlobalUI.menu_locked:
		show_label()


func show_label() -> void:
	if not is_visible:
		if Globals.game_state == Globals.GameStates.WORLD_SELECTOR:
			is_visible = true
			show()
			yield(get_tree(), "physics_frame")
			anim_player.play("show")


func hide_label() -> void:
	if is_visible:
		anim_player.play_backwards("show")
		yield(anim_player, "animation_finished")
		if not anim_player.is_playing():
			is_visible = false
			hide()


func _level_changed(_world: int, _level: int) -> void:
	hide_label()


func _ui_pause_menu_pressed() -> void:
	hide_label()


func _ui_inventory_opened() -> void:
	hide_label()


func _ui_pause_menu_return_pressed() -> void:
	hide_label()


func _ui_level_enter_menu_pressed() -> void:
	hide_label()

