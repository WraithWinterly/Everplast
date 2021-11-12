extends Control


func _ready() -> void:
	var __: int
	__ = Signals.connect("settings_updated", self, "_settings_updated")
	show()
	yield(UI, "faded")
	_settings_updated()


func _settings_updated() -> void:
	if Globals.get_settings().data.has("show_social"):
		visible = Globals.get_settings().data.show_social
