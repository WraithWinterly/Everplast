extends Control

onready var anim_player: AnimationPlayer = $AnimationPlayer
onready var yes_button: Button = $Panel/VBoxContainer/HBoxContainer/Yes
onready var no_button: Button = $Panel/VBoxContainer/HBoxContainer/No
onready var prompt_text: Label = $Panel/VBoxContainer/PromptText


func _ready() -> void:
	var __: int
	__ = GlobalEvents.connect("ui_profile_selector_delete_pressed", self, "_ui_profile_selector_delete_pressed")
	__ = no_button.connect("pressed", self, "_no_pressed")
	__ = yes_button.connect("pressed", self, "_yes_pressed")

	for button in $Panel/VBoxContainer/HBoxContainer.get_children():
		__ = button.connect("focus_entered", self, "_button_hovered")
		__ = button.connect("mouse_entered", self, "_button_hovered")

	hide()


func _unhandled_key_input(event: InputEventKey) -> void:
	if event.is_action_pressed("ui_cancel") and GlobalUI.menu == GlobalUI.Menus.PROFILE_SELECTOR_DELETE_PROMPT:
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
	show()
	enable_buttons()

	no_button.grab_focus()
	prompt_text.text = "%s %s?" % [tr("delete_prompt.text"),GlobalUI.profile_index + 1]


func hide_menu() -> void:
	anim_player.play_backwards("show")
	disable_buttons()
	yield(anim_player, "animation_finished")
	if not anim_player.is_playing() and not GlobalUI.menu == GlobalUI.Menus.PROFILE_SELECTOR_DELETE_PROMPT:
		$BGBlur.hide()


func _ui_profile_selector_delete_pressed() -> void:
	show_menu()


func _no_pressed() -> void:
	GlobalEvents.emit_signal("ui_button_pressed", true)
	GlobalUI.menu = GlobalUI.Menus.PROFILE_SELECTOR_DELETE
	GlobalEvents.emit_signal("ui_profile_selector_delete_prompt_no_pressed")
	hide_menu()


func _yes_pressed() -> void:
	GlobalEvents.emit_signal("ui_button_pressed")
	GlobalUI.menu = GlobalUI.Menus.PROFILE_SELECTOR_DELETE
	GlobalEvents.emit_signal("ui_profile_selector_delete_prompt_yes_pressed")
	hide_menu()


func _button_hovered() -> void:
	GlobalEvents.emit_signal("ui_button_hovered")
