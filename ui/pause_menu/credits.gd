extends Control


onready var return_button: Button = $Panel/Return
onready var anim_player: AnimationPlayer = $AnimationPlayer
onready var credits: TextEdit = $Panel/Copyright
onready var title: Label = $Panel/VBoxContainer/PromptText


func _ready() -> void:
	var __: int
	__ = GlobalEvents.connect("ui_settings_credits_pressed", self, "_ui_settings_credits_pressed")

	hide()

	yield(get_tree(), "physics_frame")
	var copyright: String = "%s\nCopyright (c) 2021 Ayden Springer." % Globals.version_string

	credits.scroll_vertical = 0
	var engine_string: String = Engine.get_version_info().string
	credits.get_child(1).set("custom_styles/scroll", load(GlobalPaths.CREDITS_SCROLL))
	credits.get_child(1).set("custom_styles/scroll_focus", load(GlobalPaths.CREDITS_SCROLL))
	credits.get_child(1).set("custom_styles/grabber", load(GlobalPaths.CREDITS_SCROLL_GRABBER))
	credits.get_child(1).set("custom_styles/grabber_highlight", load(GlobalPaths.CREDITS_SCROLL_GRABBER))
	credits.get_child(1).set("custom_styles/grabber_pressed", load(GlobalPaths.CREDITS_SCROLL_GRABBER))
	credits.get_child(5).set("custom_styles/panel", load("res://ui/ui_panel_bg.tres"))
	credits.get_child(5).set("custom_styles/hover", load("res://ui/ui_panel.tres"))
	credits.get_child(5).set("custom_fonts/font", load("res://ui/fonts/32x.tres"))
	credits.text = \
"""%s
***All rights reserved.***

Primary Developer: Ayden Springer, "WraithWinterly"

This game uses Godot Engine %s
	Copyright (c) 2007-2021 Juan Linietsky, Ariel Manzur.
	Copyright (c) 2014-2021 Godot Engine contributors.

	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in all
	copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE.

	-- Godot Engine <https://godotengine.org>
	<https://godotengine.org/license>

Music Tracks:
	Antti Luode - Anttis Instrumentals <gamesounds.xyz>
		Blue Arpeggio
		Wonderful Lie
		Some Kind of Music
		Feel the Love
		Simple Simplified
		Rain
		ET alone ET call home instrumental
		Beach Walk

	Daydream Anatomy - 8-Bit-Heroes - 04 Struggle <gamesounds.xyz>

	Trevor Lentz - "Lines of Code" <opengameart.org>

	CodeManu - "Iceland Theme" <opengameart.org>

Sound Effects:
	Kenney "Kenny's Sound Pack" <kenney.nl>
		zapThreeToneUp

	FXHome:
		glass2
		FXHome.com is a website for professional and amateur film makers,
		and provides many resources for creating great movies.

	JFXR <jfxr.frozenfractal.com>
		A browser-based tool to create sound effects for games.

	BFXR <https://www.bfxr.net>
		Make sound effects for your games.

Art:
	Fox: https://opengameart.org/content/fox-animated
""" % [copyright, engine_string]
	title.text = copyright


func _physics_process(_delta: float) -> void:
	if GlobalUI.menu == GlobalUI.Menus.SETTINGS_CREDITS:
		if Input.is_action_pressed("stick_ui_down") or Input.is_action_pressed("ui_down"):
			credits.scroll_vertical += 0.25
		elif Input.is_action_pressed("stick_ui_up") or Input.is_action_pressed("ui_up"):
			credits.scroll_vertical -= 0.25


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and GlobalUI.menu == GlobalUI.Menus.SETTINGS_CREDITS and not GlobalUI.menu_locked:
		_on_Return_pressed()
		get_tree().set_input_as_handled()


func disable_buttons() -> void:
	return_button.disabled = true


func enable_buttons() -> void:
	return_button.disabled = false


func hide_menu() -> void:
	anim_player.play_backwards("show")
	return_button.release_focus()
	disable_buttons()
	yield(anim_player, "animation_finished")
	$BGBlur.hide()
	hide()


func show_menu() -> void:
	anim_player.play("show")
	show()
	enable_buttons()
	return_button.grab_focus()


func _ui_settings_credits_pressed() -> void:
	show_menu()


func _on_Return_pressed() -> void:
	GlobalEvents.emit_signal("ui_button_pressed", true)
	GlobalEvents.emit_signal("ui_settings_credits_back_pressed")
	GlobalUI.menu = GlobalUI.Menus.SETTINGS_GENERAL
	hide_menu()

