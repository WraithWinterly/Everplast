extends Control

onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var yes_button: Button = $Panel/VBoxContainer/HBoxContainer/Yes
onready var no_button: Button = $Panel/VBoxContainer/HBoxContainer/No


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
		UI.MAIN_MENU_QUIT_PROMPT:
			show()
			no_button.grab_focus()
			animation_player.play("show")
			enable_buttons()
		UI.MAIN_MENU:
			if UI.last_menu == UI.MAIN_MENU_QUIT_PROMPT:
				animation_player.play_backwards("show")
				disable_buttons()


func _no_pressed() -> void:
	UI.emit_signal("button_pressed", true)
	UI.emit_signal("changed", UI.MAIN_MENU)


func _yes_pressed() -> void:
	get_tree().quit()
