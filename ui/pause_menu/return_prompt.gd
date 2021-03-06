extends Control

onready var anim_player: AnimationPlayer = $AnimationPlayer
onready var yes_button: Button = $Panel/VBoxContainer/HBoxContainer/Yes
onready var no_button: Button = $Panel/VBoxContainer/HBoxContainer/No
onready var title_text: Label = $Panel/VBoxContainer/Title
onready var prompt_text: Label = $Panel/VBoxContainer/PromptText


func _ready() -> void:
	var __: int
	__ = GlobalEvents.connect("level_changed", self, "_level_changed")
	__ = GlobalEvents.connect("ui_pause_menu_return_pressed", self, "_ui_pause_menu_return_pressed")
	__ = no_button.connect("pressed", self, "_no_pressed")
	__ = yes_button.connect("pressed", self, "_yes_pressed")

	for button in $Panel/VBoxContainer/HBoxContainer.get_children():
		__ = button.connect("focus_entered", self, "_button_hovered")
		__ = button.connect("mouse_entered", self, "_button_hovered")

	hide()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and GlobalUI.menu == GlobalUI.Menus.RETURN_PROMPT and not GlobalUI.menu_locked:
		_no_pressed()
		get_tree().set_input_as_handled()


func show_menu() -> void:
	if Globals.game_state == Globals.GameStates.LEVEL:
		prompt_text.text = tr("return_prompt.title_level")
		prompt_text.text = tr("return_prompt.text_level")
	else:
		prompt_text.text = tr("return_prompt.title")
		prompt_text.text = ""
	show()
	title_text.show()
	anim_player.play("show")
	enable_buttons()

	no_button.grab_focus()


func hide_menu() -> void:
	anim_player.play_backwards("show")
	disable_buttons()
	yield(anim_player, "animation_finished")
	if not anim_player.is_playing() and not GlobalUI.menu == GlobalUI.Menus.RETURN_PROMPT:
		hide()
		$BGBlur.hide()


func enable_buttons() -> void:
	yes_button.disabled = false
	no_button.disabled = false


func disable_buttons() -> void:
	yes_button.disabled = true
	no_button.disabled = true


func _level_changed(_world: int, _level: int) -> void:
	if GlobalUI.menu == GlobalUI.Menus.RETURN_PROMPT:
		hide_menu()


func _ui_pause_menu_return_pressed() -> void:
	show_menu()


func _no_pressed() -> void:
	if GlobalUI.menu_locked: return
	GlobalEvents.emit_signal("ui_button_pressed", true)
	GlobalUI.menu = GlobalUI.Menus.PAUSE_MENU
	GlobalEvents.emit_signal("ui_pause_menu_return_prompt_no_pressed")
	hide_menu()


func _yes_pressed() -> void:
	if GlobalUI.menu_locked: return
	yes_button.release_focus()
	GlobalEvents.emit_signal("ui_pause_menu_return_prompt_yes_pressed")
	if Globals.game_state == Globals.GameStates.LEVEL:
		GlobalLevel.checkpoint_active = false
		GlobalLevel.checkpoint_in_sub = false
		Globals.game_state = Globals.GameStates.WORLD_SELECTOR
		GlobalUI.menu = GlobalUI.Menus.NONE
		GlobalLevel.in_boss = false
		yield(GlobalEvents, "ui_faded")
		hide_menu()
		hide()
		get_tree().paused = false
	else:
		GlobalStats.last_powerup = ""
		Globals.game_state = Globals.GameStates.MENU
		GlobalUI.menu = GlobalUI.Menus.MAIN_MENU
		yield(GlobalEvents, "ui_faded")
		hide_menu()
		hide()
		get_tree().paused = false


func _button_hovered() -> void:
	GlobalEvents.emit_signal("ui_button_hovered")

