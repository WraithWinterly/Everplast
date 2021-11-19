extends Label


func _ready() -> void:
	var __: int
	__ = UI.connect("faded", self, "_ui_faded")
	__ = Signals.connect("debug_enable_confirmed", self, "_debug_enable_confirmed")
	__ = Signals.connect("erase_all_confirmed", self, "_erase_all_confirmed")
	visible = Globals.get_settings().data.cheats


func _debug_enable_confirmed() -> void:
	show()


func _erase_all_confirmed() -> void:
	hide()


func _ui_faded() -> void:
	visible = Globals.get_settings().data.cheats
