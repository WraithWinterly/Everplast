extends Label


func _ready() -> void:
	var __: int
	__ = Signals.connect("settings_updated", self, "_settings_updated")
	show()
	_settings_updated()


func _settings_updated() -> void:
	if Globals.get_settings().data.has("profile_pause"):
		visible = Globals.get_settings().data.profile_pause
