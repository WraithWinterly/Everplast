extends Control

onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var yes_button: Button = $Panel/VBoxContainer/HBoxContainer/Yes
onready var no_button: Button = $Panel/VBoxContainer/HBoxContainer/No
onready var prompt_text: Label = $Panel/VBoxContainer/PromptText


func _ready() -> void:
	var __: int
	__ = UI.connect("changed", self, "_ui_changed")
	__ = no_button.connect("pressed", self, "_no_pressed")
	__ = yes_button.connect("pressed", self, "_yes_pressed")
	hide()


func enable_buttons() -> void:
	yes_button.disabled = false
	no_button.disabled = false


func disable_buttons() -> void:
	yes_button.disabled = true
	no_button.disabled = true


func _ui_changed(menu: int) -> void:
	match menu:
		UI.PROFILE_SELECTOR_DELETE_PROMPT:
			prompt_text.text = "Are you sure you want to completely erase profile %s?" % (UI.profile_index + 1)
			show()
			no_button.grab_focus()
			animation_player.play("show")
			enable_buttons()
		UI.PROFILE_SELECTOR_DELETE:
			if UI.last_menu == UI.PROFILE_SELECTOR_DELETE_PROMPT:
				animation_player.play_backwards("show")
				disable_buttons()


func _no_pressed() -> void:
	UI.prompt_no = true
	UI.emit_signal("button_pressed", true)
	UI.emit_signal("changed", UI.PROFILE_SELECTOR_DELETE)
	yield(animation_player, "animation_finished")
	if not animation_player.is_playing():
		hide()


func _yes_pressed() -> void:
	UI.prompt_no = false
	UI.emit_signal("button_pressed")
	Signals.emit_signal("profile_deleted")
	UI.emit_signal("changed", UI.PROFILE_SELECTOR_DELETE)
