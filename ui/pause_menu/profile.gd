extends Label


func _ready() -> void:
	var __: int
	__ = GlobalEvents.connect("ui_settings_updated", self, "_ui_settings_updated")

	show()
	update_visibility()


func update_visibility() -> void:
	if get_node(GlobalPaths.SETTINGS).data.has("profile_pause"):
		visible = get_node(GlobalPaths.SETTINGS).data.profile_pause


func _ui_settings_updated() -> void:
	update_visibility()
