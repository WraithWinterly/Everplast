extends Control

var is_visible := true

onready var web_button: Button = $HBoxContainer/VBoxContainer/Web/Button
onready var web_icon: Button = $HBoxContainer/VBoxContainer/Web/Icon
onready var anim_player: AnimationPlayer = $AnimationPlayer
onready var vbox: VBoxContainer = $HBoxContainer/VBoxContainer


func _ready() -> void:
	var __: int
	__ = GlobalEvents.connect("level_changed", self, "_level_changed")
	__ = GlobalEvents.connect("ui_play_pressed", self, "_ui_play_pressed")
	__ = GlobalEvents.connect("ui_profile_selector_return_pressed", self, "_ui_profile_selector_return_pressed")
	__ = GlobalEvents.connect("ui_pause_menu_return_prompt_yes_pressed", self, "_ui_pause_menu_return_prompt_yes_pressed")
	__ = web_button.connect("pressed", self, "_web_button_pressed")
	__ = web_icon.connect("pressed", self, "_web_button_pressed")

	hide()
	enable_buttons()
	yield(GlobalEvents, "ui_faded")
	yield(get_tree(), "physics_frame")
	yield(get_tree(), "physics_frame")
	if not GlobalUI.fade_player_playing:
		show()
		anim_player.play("show")


func enable_buttons() -> void:
	web_button.disabled = false


func disable_buttons() -> void:
	web_button.disabled = true


func _level_changed(_world: int, _level: int) -> void:
	if is_visible:
		anim_player.play_backwards("show")
		is_visible = false


func _ui_play_pressed() -> void:
	anim_player.play_backwards("show")
	is_visible = false


func _ui_profile_selector_return_pressed() -> void:
	if GlobalUI.menu == GlobalUI.Menus.PROFILE_SELECTOR:
		#yield(GlobalEvents, "ui_faded")
		#yield(GlobalEvents, "ui_faded")
		anim_player.play("show")
		is_visible = true


func _ui_pause_menu_return_prompt_yes_pressed() -> void:
	if Globals.game_state == Globals.GameStates.WORLD_SELECTOR:
		yield(GlobalEvents, "ui_faded")
		yield(GlobalEvents, "ui_faded")
		anim_player.play("show")
		is_visible = true


func _web_button_pressed() -> void:
	GlobalEvents.emit_signal("ui_button_pressed")
	var __: int = OS.shell_open("https://sites.google.com/view/everplast")

