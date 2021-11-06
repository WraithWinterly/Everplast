extends Control

onready var main: Main = get_tree().root.get_node("Main")
onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var yes_button: Button = $Panel/VBoxContainer/HBoxContainer/Yes
onready var no_button: Button = $Panel/VBoxContainer/HBoxContainer/No
onready var prompt_text: Label = $Panel/VBoxContainer/PromptText


func _ready() -> void:
	hide()
	UI.connect("changed", self, "_ui_changed")
	yes_button.connect("pressed", self, "_yes_pressed")
	no_button.connect("pressed", self, "_no_pressed")


func enable_buttons() -> void:
	yes_button.disabled = false
	no_button.disabled = false


func disable_buttons() -> void:
	yes_button.disabled = true
	no_button.disabled = true


func _ui_changed(menu: int) -> void:
	match menu:
		UI.MAIN_MENU_QUICK_PLAY:
			prompt_text.text = "Play Profile %s: %s - %s?" % [
					QuickPlay.data.last_profile + 1,
					main.world_names[\
						PlayerStats.data[\
						QuickPlay.data.last_profile].world_last],
						(PlayerStats.data[\
					QuickPlay.data.last_profile].level_last)]
			show()
			no_button.grab_focus()
			animation_player.play("show")
			enable_buttons()
		UI.MAIN_MENU:
			if UI.last_menu == UI.MAIN_MENU_QUICK_PLAY:
				animation_player.play_backwards("show")
				disable_buttons()
		UI.NONE:
			if UI.last_menu == UI.MAIN_MENU_QUICK_PLAY:
				animation_player.play_backwards("show")
				disable_buttons()
				yield(UI, "faded")
				hide()


func _no_pressed() -> void:
	UI.emit_signal("button_pressed", true)
	UI.emit_signal("changed", UI.MAIN_MENU)


func _yes_pressed() -> void:
	UI.emit_signal("button_pressed")
	Signals.emit_signal("level_changed", PlayerStats.data[QuickPlay.data.last_profile].world_last, PlayerStats.data[QuickPlay.data.last_profile].level_last)
