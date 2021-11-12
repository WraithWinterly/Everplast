extends Control

onready var anim_player: AnimationPlayer = $CanvasLayer/AnimationPlayer
onready var no_button: Button = $CanvasLayer/Panel/VBoxContainer/HBoxContainer/No
onready var yes_button: Button = $CanvasLayer/Panel/VBoxContainer/HBoxContainer/Yes
onready var prompt_text: Label = $CanvasLayer/Panel/VBoxContainer/PromptText
onready var title: Label = $CanvasLayer/Panel/VBoxContainer/Title


func _ready() -> void:
	var __: int
	__ = UI.connect("changed", self, "_ui_changed")
	__ = no_button.connect("pressed", self, "_no_pressed")
	__ = yes_button.connect("pressed", self, "_yes_pressed")


func _ui_changed(menu: int) -> void:
	match menu:
		UI.MAIN_MENU_SETTINGS_DEBUG_ENABLE_PROMPT:
			show()
			enable_buttons()
			anim_player.play("show")
			no_button.grab_focus()
		UI.MAIN_MENU_SETTINGS_OTHER:
			if UI.last_menu == UI.MAIN_MENU_SETTINGS_DEBUG_ENABLE_PROMPT:
				disable_buttons()
				anim_player.play_backwards("show")
			elif UI.last_menu == UI.MAIN_MENU_SETTINGS_DEBUG_ENABLE_EVIL_PROMPT:
				Signals.emit_signal("erase_all_canceled")
				Globals.in_evil_mode = false
				if visible:
					anim_player.play_backwards("show")
					yield(anim_player, "animation_finished")
				title.text = "Enable Debug Console and Cheats?"
				prompt_text.text = "Enabling Debug Console will enable cheats throughout the game.\nThis can only be undone by erasing all data. An icon will appear\non the screen when cheats are enabled. Are you sure about this?"
				disable_buttons()


func disable_buttons() -> void:
	no_button.disabled = true
	yes_button.disabled = true

func enable_buttons() -> void:
	no_button.disabled = false
	yes_button.disabled = false


func _no_pressed() -> void:
	UI.emit_signal("button_pressed", true)
	UI.emit_signal("changed", UI.MAIN_MENU_SETTINGS_OTHER)


func _yes_pressed() -> void:
	UI.emit_signal("button_pressed", true)
	if not Globals.in_evil_mode:
		disable_buttons()
		Globals.in_evil_mode = true
		UI.emit_signal("changed", UI.MAIN_MENU_SETTINGS_DEBUG_ENABLE_EVIL_PROMPT)
		anim_player.play_backwards("show")
		disable_buttons()
		UI.menu_transitioning = true
		Signals.emit_signal("debug_enable_started")
		yield(get_tree().create_timer(1), "timeout")
		UI.menu_transitioning = false
		enable_buttons()
		no_button.grab_focus()
		UI.emit_signal("button_pressed")
		title.text = "Enabling Debug and Cheats..."
		prompt_text.text = "This can ONLY be undone by using the \"Erase All Data\" option!\nOtherwise, THIS CAN NOT BE UNDONE!"
		anim_player.play("show")
	else:
		UI.menu_transitioning = true
		disable_buttons()
		anim_player.play_backwards("show")
		yield(get_tree().create_timer(1), "timeout")
		hide()
		Signals.emit_signal("debug_enable_confirmed")
		Globals.in_evil_mode = false
		UI.menu_transitioning = false
		UI.emit_signal("changed", UI.MAIN_MENU_SETTINGS_OTHER)
