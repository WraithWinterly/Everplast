extends Control

var is_visible := true

onready var youtube_button: Button = $HBoxContainer/VBoxContainer/Youtube/Button
onready var twitter_button: Button = $HBoxContainer/VBoxContainer/Twitter/Button
onready var discord_button: Button = $HBoxContainer/VBoxContainer/Discord/Button
onready var anim_player: AnimationPlayer = $AnimationPlayer
onready var vbox: VBoxContainer = $HBoxContainer/VBoxContainer


func _ready() -> void:
	var __: int
	__ = GlobalEvents.connect("level_changed", self, "_level_changed")
	__ = GlobalEvents.connect("ui_play_pressed", self, "_ui_play_pressed")
	__ = GlobalEvents.connect("ui_profile_selector_return_pressed", self, "_ui_profile_selector_return_pressed")
	__ = GlobalEvents.connect("ui_pause_menu_return_prompt_yes_pressed", self, "_ui_pause_menu_return_prompt_yes_pressed")
	__ = GlobalEvents.connect("ui_social_disabled", self, "_ui_social_disabled")
	__ = GlobalEvents.connect("ui_social_enabled", self, "_ui_social_enabled")
	__ = GlobalEvents.connect("ui_settings_updated", self, "_ui_settings_updated")
	__ = youtube_button.connect("pressed", self, "_youtube_pressed")
	__ = twitter_button.connect("pressed", self, "_twitter_pressed")
	__ = discord_button.connect("pressed", self, "_discord_pressed")

	hide()
	enable_buttons()
	yield(GlobalEvents, "ui_faded")
	anim_player.play("show")
	yield(get_tree(), "physics_frame")
	visible = get_node(GlobalPaths.SETTINGS).data.show_social


func enable_buttons() -> void:
	youtube_button.disabled = false
	twitter_button.disabled = false
	discord_button.disabled = false


func disable_buttons() -> void:
	youtube_button.disabled = true
	twitter_button.disabled = true
	discord_button.disabled = true


func _level_changed(_world: int, _level: int) -> void:
	if is_visible:
		anim_player.play_backwards("show")
		is_visible = false


func _ui_play_pressed() -> void:
	anim_player.play_backwards("show")
	is_visible = false


func _ui_profile_selector_return_pressed() -> void:
	if GlobalUI.menu == GlobalUI.Menus.PROFILE_SELECTOR:
		yield(GlobalEvents, "ui_faded")
		yield(GlobalEvents, "ui_faded")
		anim_player.play("show")
		is_visible = true


func _ui_pause_menu_return_prompt_yes_pressed() -> void:
	if Globals.game_state == Globals.GameStates.WORLD_SELECTOR:
		yield(GlobalEvents, "ui_faded")
		yield(GlobalEvents, "ui_faded")
		anim_player.play("show")
		is_visible = true


func _ui_social_enabled() -> void:
	enable_buttons()


func _ui_social_disabled() -> void:
	disable_buttons()


func _youtube_pressed() -> void:
	GlobalEvents.emit_signal("ui_button_pressed")
	var __: int = OS.shell_open("https://www.youtube.com/channel/UCoY-P1UvFcRNqE2pDRGyZ4w")


func _twitter_pressed() -> void:
	GlobalEvents.emit_signal("ui_button_pressed")
	var __: int = OS.shell_open("https://twitter.com/WraithWinterly")


func _discord_pressed() -> void:
	GlobalEvents.emit_signal("ui_button_pressed")
	var __: int = OS.shell_open("https://discord.gg/36ee6SpDAq")


func _ui_settings_updated() -> void:
	if not GlobalUI.menu_locked:
		visible = get_node(GlobalPaths.SETTINGS).data.show_social
