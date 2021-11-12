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
		UI.MAIN_MENU_SETTINGS_ERASE_PROMPT:
			show()
			enable_buttons()
			anim_player.play("show")
			no_button.grab_focus()
		UI.MAIN_MENU_SETTINGS_OTHER:
			if UI.last_menu == UI.MAIN_MENU_SETTINGS_ERASE_PROMPT:
				disable_buttons()
				anim_player.play_backwards("show")
			elif UI.last_menu == UI.MAIN_MENU_SETTINGS_ERASE_PROMPT_EVIL:
				anim_player.play_backwards("show")
				disable_buttons()
				Signals.emit_signal("erase_all_canceled")
				Globals.in_evil_mode = false
				title.text = "Erase ALL Save Data?"
				prompt_text.text = "All save data will be deleted. All profiles will be deleted. All settings will be reset. Everything will be reset."


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
		UI.emit_signal("changed", UI.MAIN_MENU_SETTINGS_ERASE_PROMPT_EVIL)
		anim_player.play_backwards("show")
		disable_buttons()
		UI.menu_transitioning = true
		Signals.emit_signal("erase_all_started")
		yield(get_tree().create_timer(1), "timeout")
		UI.menu_transitioning = false
		enable_buttons()
		no_button.grab_focus()
		UI.emit_signal("button_pressed")
		title.text = "ERASE EVERYTHING?"
		prompt_text.text = "You are about to reset EVERTHING. THIS CAN NOT BE UNDONE! Are you sure about this?"
		anim_player.play("show")
	else:
		UI.menu_transitioning = true
		Signals.emit_signal("erase_all_confirmed")
		disable_buttons()
		anim_player.play_backwards("show")
		yield(get_tree().create_timer(1), "timeout")
		Globals.in_evil_mode = false
		UI.emit_signal("changed", UI.MAIN_MENU)
		UI.current_menu = UI.MAIN_MENU
		UI.last_menu = UI.MAIN_MENU
		UI.menu_transitioning = false
		var __ = get_tree().change_scene("res://main.tscn")
