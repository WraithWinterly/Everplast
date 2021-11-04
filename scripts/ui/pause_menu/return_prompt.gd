extends Control

onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var yes_button: Button = $Panel/VBoxContainer/HBoxContainer/Yes
onready var no_button: Button = $Panel/VBoxContainer/HBoxContainer/No
onready var title_text: Label = $Panel/VBoxContainer/Title
onready var prompt_text: Label = $Panel/VBoxContainer/PromptText


func _ready() -> void:
	hide()
	UI.connect("changed", self, "_ui_changed")
	yes_button.connect("pressed", self, "_yes_pressed")
	no_button.connect("pressed", self, "_no_pressed")


func _ui_changed(menu: int) -> void:
	match menu:
		UI.PAUSE_MENU_RETURN_PROMPT:
			show_menu()
		UI.PAUSE_MENU:
			if UI.last_menu == UI.PAUSE_MENU_RETURN_PROMPT:
				UI.emit_signal("button_pressed")
				hide_menu()
		UI.MAIN_MENU:
			hide_menu()
		UI.NONE:
			if visible:
				hide_menu()



func show_menu() -> void:
	if Globals.game_state == Globals.GameStates.LEVEL:
		prompt_text.text = "Exit Level?"
		prompt_text.text = "All unsaved progress will be lost!"
	else:
		prompt_text.text = "Return to Main Menu?"
		prompt_text.text = ""
	show()
	title_text.show()
	no_button.grab_focus()
	animation_player.play("show")
	enable_buttons()


func hide_menu() -> void:
	animation_player.play_backwards("show")
	disable_buttons()
	yield(animation_player, "animation_finished")
	hide()


func enable_buttons() -> void:
	yes_button.disabled = false
	no_button.disabled = false


func disable_buttons() -> void:
	yes_button.disabled = true
	no_button.disabled = true


func _no_pressed() -> void:
	UI.emit_signal("button_pressed")
	UI.emit_signal("changed", UI.PAUSE_MENU)


func _yes_pressed() -> void:
	UI.emit_signal("button_pressed")
	if Globals.game_state == Globals.GameStates.WORLD_SELECTOR:
		UI.emit_signal("changed", UI.MAIN_MENU)
	else:
		UI.emit_signal("changed", UI.NONE)



