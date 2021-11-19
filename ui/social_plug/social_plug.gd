extends Control

onready var youtube_button: Button = $HBoxContainer/VBoxContainer/YoutubeButton
onready var twitter_button: Button = $HBoxContainer/VBoxContainer/TwitterButton
onready var discord_button: Button = $HBoxContainer/VBoxContainer/DiscordButton

onready var vbox: VBoxContainer = $HBoxContainer/VBoxContainer


func _ready() -> void:
	var __: int
	#__ = UI.connect("changed", self, "_ui_changed")
	__ = Signals.connect("settings_updated", self, "_settings_updated")
	__ = Signals.connect("social_disabled", self, "_social_disabled")
	__ = Signals.connect("social_enabled", self, "_social_enabled")
	__ = youtube_button.connect("pressed", self, "_youtube_pressed")
	__ = twitter_button.connect("pressed", self, "_twitter_pressed")
	__ = discord_button.connect("pressed", self, "_discord_pressed")
	hide()
	yield(UI, "faded")
	_settings_updated()
	show()
	enable_buttons()
#
#func _ui_changed(menu: int) -> void:
#	print(menu)
#	if menu == UI.MAIN_MENU or menu == UI.PAUSE_MENU:
#		enable_buttons()
#	else:
#		disable_buttons()


func enable_buttons() -> void:
	for child in vbox.get_children():
		if child is Button:
			child.disabled = false


func _social_enabled() -> void:
	enable_buttons()


func _social_disabled() -> void:
	disable_buttons()


func disable_buttons() -> void:
	for child in vbox.get_children():
		if child is Button:
			child.disabled = true


func _settings_updated() -> void:
	if Globals.get_settings().data.has("show_social"):
		visible = Globals.get_settings().data.show_social



func _youtube_pressed() -> void:
	UI.emit_signal("button_pressed")
	var __: int = OS.shell_open("https://www.youtube.com/channel/UCoY-P1UvFcRNqE2pDRGyZ4w")


func _twitter_pressed() -> void:
	UI.emit_signal("button_pressed")
	var __: int = OS.shell_open("https://twitter.com/WraithWinterly")


func _discord_pressed() -> void:
	UI.emit_signal("button_pressed")
	var __: int = OS.shell_open("https://discord.gg/tsrbNCs3rS")

