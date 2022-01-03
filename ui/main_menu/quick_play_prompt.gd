extends Control

onready var anim_player: AnimationPlayer = $AnimationPlayer
onready var yes_button: Button = $Panel/VBoxContainer/HBoxContainer/Yes
onready var no_button: Button = $Panel/VBoxContainer/HBoxContainer/No
onready var prompt_text: Label = $Panel/VBoxContainer/PromptText


func _ready() -> void:
	var __: int
	__ = GlobalEvents.connect("level_changed", self, "_level_changed")
	__ = GlobalEvents.connect("ui_quick_play_pressed", self, "_ui_quick_play_pressed")
	__ = no_button.connect("pressed", self, "_no_pressed")
	__ = yes_button.connect("pressed", self, "_yes_pressed")

	for button in $Panel/VBoxContainer/HBoxContainer.get_children():
		__ = button.connect("focus_entered", self, "_button_hovered")
		__ = button.connect("mouse_entered", self, "_button_hovered")

	hide()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and GlobalUI.menu == GlobalUI.Menus.QUICK_PLAY_PROMPT:
		_no_pressed()
		get_tree().set_input_as_handled()


func enable_buttons() -> void:
	yes_button.disabled = false
	no_button.disabled = false


func disable_buttons() -> void:
	yes_button.disabled = true
	no_button.disabled = true


func show_menu() -> void:
	anim_player.play("show")
	prompt_text.text = "%s %s: %s - %s?" % [
			tr("quick_play.prompt_text"),
			GlobalQuickPlay.data.last_profile + 1,
			GlobalLevel.WORLD_NAMES[GlobalSave.data[GlobalQuickPlay.data.last_profile].world_last],
			GlobalSave.data[GlobalQuickPlay.data.last_profile].level_last]


	no_button.grab_focus()
	show()
	enable_buttons()


func hide_menu() -> void:
	anim_player.play_backwards("show")
	yield(anim_player, "animation_finished")
	if not anim_player.is_playing():
		$BGBlur.hide()


func _level_changed(_world: int, _level: int) -> void:
	if GlobalUI.menu == GlobalUI.Menus.QUICK_PLAY_PROMPT:
		hide_menu()


func _ui_quick_play_pressed() -> void:
	show_menu()


func _no_pressed() -> void:
	if GlobalUI.menu_locked: return
	GlobalEvents.emit_signal("ui_button_pressed", true)
	GlobalEvents.emit_signal("ui_quick_play_prompt_no_pressed")
	GlobalUI.menu = GlobalUI.Menus.MAIN_MENU
	hide_menu()


func _yes_pressed() -> void:
	if GlobalUI.menu_locked: return

	GlobalEvents.emit_signal("ui_quick_play_prompt_yes_pressed")
	GlobalUI.menu = GlobalUI.Menus.NONE
	release_focus()
	disable_buttons()

	GlobalSave.profile = GlobalQuickPlay.data.last_profile
	GlobalEvents.emit_signal("level_changed", GlobalSave.data[GlobalQuickPlay.data.last_profile].world_last, GlobalSave.data[GlobalQuickPlay.data.last_profile].level_last)
	hide_menu()


func _button_hovered() -> void:
	GlobalEvents.emit_signal("ui_button_hovered")
