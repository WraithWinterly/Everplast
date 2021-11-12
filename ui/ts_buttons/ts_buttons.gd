extends Control


onready var buttons := [$"PauseHolder/Pause/Pause",
$"PauseHolder/Inventory/Inventory",
$"DebugHolder/Debug/Debug",
$"DebugHolder/DebugConsole/DebugConsole",
$"InteractHolder/Interact/Interact",
$"MoveHolder/Left/Left",
$"MoveHolder/Down/Down",
$"MoveHolder/Right/Right",
$"HBoxContainer2/Jump/Dash",
$"HBoxContainer2/Sprint/Sprint",
$"HBoxContainer2/Dash/Dash"]


func _ready() -> void:
	var __: int
	__ = UI.connect("changed", self, "_ui_changed")
	__ = Signals.connect("level_changed", self, "_level_changed")
	__ = Signals.connect("inventory_changed", self, "_inventory_changed")
	__ = Signals.connect("dialog", self, "_dialog")
	__ = Signals.connect("dialog_hidden", self, "_dialog_hidden")
	hide()
	if not Globals.is_mobile:
		set_process(false)
		set_physics_process(false)
		set_process_input(false)


func _process(_delta: float) -> void:
	Globals.ts_button_pressed = false
	for button in buttons:
		if button.is_pressed():
			Globals.ts_button_pressed = true



func _ui_changed(menu: int) -> void:
	match menu:
		UI.MAIN_MENU:
			if UI.last_menu == UI.PAUSE_MENU_RETURN_PROMPT and Globals.is_mobile:
				yield(UI, "faded")
				hide()
		UI.NONE:
			if Globals.is_mobile:
				if UI.last_menu == UI.PROFILE_SELECTOR:
					yield(UI, "faded")
					show()
				else:
					show()
		UI.PAUSE_MENU:
			if Globals.is_mobile:
				hide()


func _level_changed(_world: int, _level: int) -> void:
	yield(UI, "faded")
	if Globals.is_mobile:
		show()


func _inventory_changed(is_open: bool):
	visible = not is_open


func _dialog(_content: String, _person: String = "", _func_call: String = "") -> void:
	hide()


func _dialog_hidden() -> void:
	show()
