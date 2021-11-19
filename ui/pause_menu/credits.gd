extends Control


onready var return_button: Button = $Panel/Return
onready var anim_player: AnimationPlayer = $AnimationPlayer
onready var credits: TextEdit = $Panel/Copyright
onready var title: Label = $Panel/VBoxContainer/PromptText


func _ready() -> void:
	var __: int
	__ = UI.connect("changed", self, "_ui_changed")
	var copyright: String = "Everplast %s\nCopyright 2021 Ayden Springer." % Globals.get_main().version
	hide()
	var engine_string: String = Engine.get_version_info().string
	credits.text = \
"""Primary Developer: Ayden Springer, "WraithWinterly"

%s

***All rights reserved.***

You are NOT allowed to use any of my assets, or this game, for any comerical use. You are NOT allowed to use Everplast's copyrighted assets or Everplast for Non-fungible Tokens (NFT), or selling the art, or game somewhere else. A detailed list of non-copyrighted assets are listed below. Otherwise, all rights are reserved.
YOU AREE YOU WILL NOT USE EVERPLAST OR EVERPLAST'S ASSETS FOR COMMERCIAL USE OR NFTs.

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
		Another Day
		Feel the Love
		Simple Simplyfied
		Rain
		ET alone ET call home instrumental
		Beach Walk

	Daydream Anatony - 8-Bit-Heroes - 04 Struggle <gamesounds.xyz>

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
""" % [copyright, engine_string]
	title.text = copyright


func _on_Return_pressed() -> void:
	UI.emit_signal("button_pressed", true)
	match UI.current_menu:
		UI.MAIN_MENU_SETTINGS_CREDITS:
			UI.emit_signal("changed", UI.MAIN_MENU_SETTINGS_GENERAL)
		UI.PAUSE_MENU_SETTINGS_CREDITS:
			UI.emit_signal("changed", UI.PAUSE_MENU_SETTINGS_GENERAL)


func _ui_changed(menu: int) -> void:
	match menu:
		UI.MAIN_MENU_SETTINGS_CREDITS, UI.PAUSE_MENU_SETTINGS_CREDITS:
			anim_player.play("show")
			show()
			return_button.grab_focus()
		UI.MAIN_MENU_SETTINGS_GENERAL, UI.PAUSE_MENU_SETTINGS_GENERAL:
			if UI.last_menu == UI.MAIN_MENU_SETTINGS_CREDITS \
					or UI.last_menu == UI.PAUSE_MENU_SETTINGS_CREDITS:
				anim_player.play_backwards("show")
