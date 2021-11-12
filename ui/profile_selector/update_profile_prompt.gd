#extends Control
#
#var index: int = 0
#
#onready var yes_button: Button = $Panel/VBoxContainer/HBoxContainer/Yes
#onready var no_button: Button = $Panel/VBoxContainer/HBoxContainer/No
#onready var animation_player: AnimationPlayer = $AnimationPlayer
#onready var label_text: Label = $Panel/VBoxContainer/PromptText
#
#
#func _ready() -> void:
#	hide()
#	yes_button.connect("pressed", self, "_yes_pressed")
#	no_button.connect("pressed", self, "_no_pressed")
#	Signals.connect("ui_profile_prompt_pressed", self, "_ui_profile_prompt_pressed")
#
#
#func _yes_pressed() -> void:
#	Signals.emit_signal("profile_update", index)
#	Globals.menu_locked = true
#	Signals.emit_signal("ui_profile_prompt_back", index)
#	animation_player.play_backwards("show")
#	yield(animation_player, "animation_finished")
#	hide()
#	Globals.menu_locked = false
#
#
#func _no_pressed() -> void:
#	Globals.menu_locked = true
#	Signals.emit_signal("ui_profile_prompt_back", index)
#	animation_player.play_backwards("show")
#	yield(animation_player, "animation_finished")
#	hide()
#	Globals.menu_locked = false
#
#
#func _ui_profile_prompt_pressed(new_index: int) -> void:
#	no_button.grab_focus()
#	show()
#	animation_player.play("show")
#	index = new_index
#	label_text.text = "This save file is not updated.\nDo you want to upgrade profile %s to the latest version?" % (index + 1)

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
		UI.PROFILE_SELECTOR_UPDATE_PROMPT:
			prompt_text.text = "This save file is not updated.\nDo you want to upgrade profile %s to the latest version?" % (UI.profile_index + 1)
			show()
			no_button.grab_focus()
			animation_player.play("show")
			enable_buttons()
		UI.PROFILE_SELECTOR:
			if UI.last_menu == UI.PROFILE_SELECTOR_UPDATE_PROMPT:
				animation_player.play_backwards("show")
				disable_buttons()


func _no_pressed() -> void:
	UI.prompt_no = true
	UI.emit_signal("button_pressed", true)
	UI.emit_signal("changed", UI.PROFILE_SELECTOR)


func _yes_pressed() -> void:
	UI.prompt_no = false
	UI.emit_signal("button_pressed")
	UI.emit_signal("changed", UI.PROFILE_SELECTOR)
	Signals.emit_signal("profile_updated")
