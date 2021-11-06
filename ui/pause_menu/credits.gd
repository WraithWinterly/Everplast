extends Control

onready var main: Main = get_tree().root.get_node("Main")
onready var return_button: Button = $Panel/Return
onready var anim_player: AnimationPlayer = $AnimationPlayer
onready var credits: Label = $Panel/Explanation/Label
onready var version: Label = $Panel/VBoxContainer/PromptText


func _ready() -> void:
	hide()
	credits.text = \
	"Primary Developer: WraithWinterly\n\nGodot Engine <https://godotengine.org>\n-- Copyright (c) 2007-2021 Juan Linietsky, Ariel Manzur.\n-- Copyright (c) 2014-2021 Godot Engine contributors.\n\n*Other Royalty-free assets not created by WraithWinterly are used."
	version.text = "Everplast %s" % get_tree().root.get_node("Main").version
	UI.connect("changed", self, "_ui_changed")


func _on_Return_pressed() -> void:
	UI.emit_signal("button_pressed", true)
	match UI.last_menu:
		UI.MAIN_MENU_SETTINGS:
			UI.emit_signal("changed", UI.MAIN_MENU_SETTINGS)
		UI.PAUSE_MENU_SETTINGS:
			UI.emit_signal("changed", UI.PAUSE_MENU_SETTINGS)


func _ui_changed(menu: int) -> void:
	match menu:
		UI.MAIN_MENU_SETTINGS_CREDITS, UI.PAUSE_MENU_SETTINGS_CREDITS:
			anim_player.play("show")
			show()
			return_button.grab_focus()
		UI.MAIN_MENU_SETTINGS, UI.PAUSE_MENU_SETTINGS:
			if UI.last_menu == UI.MAIN_MENU_SETTINGS_CREDITS \
					or UI.last_menu == UI.PAUSE_MENU_SETTINGS_CREDITS:
				anim_player.play_backwards("show")
