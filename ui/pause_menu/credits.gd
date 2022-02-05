extends Control


onready var return_button: Button = $Panel/Return
onready var anim_player: AnimationPlayer = $AnimationPlayer
onready var credits: TextEdit = $Panel/Copyright
onready var title: Label = $Panel/VBoxContainer/PromptText


func _ready() -> void:
	var __: int
	__ = GlobalEvents.connect("ui_settings_credits_pressed", self, "_ui_settings_credits_pressed")
	__ = return_button.connect("focus_entered", self, "_button_hovered")
	__ = return_button.connect("mouse_entered", self, "_button_hovered")

	hide()

	yield(get_tree(), "physics_frame")
	var copyright: String = "%s\nCopyright (c) 2021-2022 WraithWinterly" % Globals.version_string

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
		Some Kind of Music (Main Menu Theme)
		Blue Arpeggio (World Selector World 1 Theme)
		Feel the Love (World 1 Theme)
		Beach Walk (World 1 Alt Theme)
		ET alone ET call home instrumental (World 1 & 2 Underground Theme)
		Guitars and Things (World 2 World Selector Theme)
		Simple Simplified (World 2 Theme)
		Beachy Beach (World 2 Alt Theme)
		Little Guitar (World 2 Alt Theme)
		Rain (World 3 Theme)
		Arpy Arp (World 3 Alt Theme)
		Fun in the Sun (World 3 Dark Theme)

	Daydream Anatomy - 8-Bit-Heroes - 04 Struggle <gamesounds.xyz> (World 1 Cloud Theme)

	CodeManu - "Iceland Theme" <opengameart.org> (World 3 World Selector Theme)

Sound Effects:
	[button_press.ogg] (zapThreeToneUp)
	Kenney "Kenny's Sound Pack" <kenney.nl>
	(Button Press)

	[glass2]
	FXHome.com is a website for professional and amateur film makers, and provides many resources for creating great movies.
	(Vase Break)

	[421184__inspectorj__water-pouring-a.wav]
	"Water, Pouring, A.wav" by InspectorJ(www.jshaw.co.uk) of Freesound.org
	(Water Out Sound)

	[413749__inspectorj__ui-confirmation-alert-d1.wav]
	"UI Confirmation Alert, D1.wav" by InspectorJ (www.jshaw.co.uk) of Freesound.org
	(Splash Sound)

	[397946__inspectorj__footsteps-snow-a.wav]
	"Footsteps, Snow, A.wav" by InspectorJ (www.jshaw.co.uk) of Freesound.org
	(Snow Footstep)

	[splash16.wav]
	https://freesound.org/people/Rocktopus/sounds/233415/
	(Water Enter)

	[49190__angel-perez-grandi__ice-breaking]
	https://freesound.org/people/Angel_Perez_Grandi/sounds/49190/
	(Falling Ice Break)

	[501888__greenfiresound__snow-07.wav]
	https://freesound.org/people/GreenFireSound/sounds/501888/
	(Snowball Sound)

	[369778__morganpurkis__snow-step-2.wav]
	https://freesound.org/people/morganpurkis/sounds/369778/
	(Snowball Sound)

	[560961__bricklover__snowball-smash-1.wav]
	https://freesound.org/people/Bricklover/sounds/560961/
	(Gun No Amo)

	[][556858__uberproduktion__impulse-response-elemente-snow.wav]
	https://freesound.org/people/Uberproduktion/sounds/556858/
	(Snowman Kill)

	[276918__kodimynatt__snowstep5.wav]
	https://freesound.org/people/kodimynatt/sounds/276918/
	(Snowman Hurt)

	[204129__craxic__glass16.wav]
	https://freesound.org/people/Craxic/sounds/204129/
	(Ice Cube)

	[411460__inspectorj__power-up-bright-a.wav]
	https://freesound.org/people/InspectorJ/sounds/411460/
	(Everplast Logo Sound)

	[https://freesound.org/people/MATRIXXX_/sounds/523650/]
	https://freesound.org/people/MATRIXXX_/sounds/523650/
	(Player Level Up)

	[353069__ying16__highlight-harpepianoedit02.wav]
	https://freesound.org/people/ying16/sounds/353069/
	(Play Button Sound)

	[531511__eponn__menu-beep.wav]
	https://freesound.org/people/Eponn/sounds/531511/
	(UI Leave)

	[531509__eponn__soft-dreamy-beep-alternative-version.wav]
	https://freesound.org/people/Eponn/sounds/531509/
	(Main Menu Press Any Button)

	[50794__smcameron__rocks2.wav]
	https://freesound.org/people/smcameron/sounds/50794/
	(Footstep Sound)

	[50797__smcameron__rocks5.wav]
	https://freesound.org/people/smcameron/sounds/50797/
	(Footstep Sound)

	[50798__smcameron__rocks6.wav]
	https://freesound.org/people/smcameron/sounds/50798/
	(Footstep Sound)

	[110101__ronaldvanwonderen__heavy-wood-footstep-2.wav]
	https://freesound.org/people/RonaldVanWonderen/sounds/110101/
	(Footstep Sound)

	[151229__owlstorm__grassy-footstep-2.wav]
	(Footstep Sound)

	[211457__pgi__sand-step.wav]
	https://freesound.org/people/pgi/sounds/211457/
	(Footstep Sound)

	[347371__drfx__soft-grass-foot-step.wav]
	https://freesound.org/people/DRFX/sounds/347371/
	(Footstep Sound)

	[397946__inspectorj__footsteps-snow-a.wav]
	"Footsteps, Snow, A.wav" by InspectorJ (www.jshaw.co.uk) of Freesound.org
	(Footstep Sound)

	[150839__toxicwafflezz__bullet-impact-3.wav]
	https://freesound.org/people/toxicwafflezz/sounds/150839/

	Other Utilities Used:
	JFXR <jfxr.frozenfractal.com>
	"A browser-based tool to create sound effects for games."

	BFXR <https://www.bfxr.net>
	"Make sound effects for your games."

	Audacity <https://www.audacityteam.org/>
	"Audacity is an easy-to-use, multi-track audio editor and recorder for Windows, macOS, GNU/Linux and other operating systems.Audacity is free, open source software."

Art:
	https://opengameart.org/content/fox-animated
	(Fox)

	https://opengameart.org/content/2d-spider-animated
	(Spider)

	https://opengameart.org/content/country-side-platform-tiles
	(World 1 Backgrounds)

	https://itch.io/s/63033/winter-sale-2021-pt
	(World 1 / 2 / 3 Backgrounds)

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
	if not anim_player.is_playing() and not GlobalUI.menu == GlobalUI.Menus.SETTINGS_CREDITS:
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


func _button_hovered() -> void:
	GlobalEvents.emit_signal("ui_button_hovered")
