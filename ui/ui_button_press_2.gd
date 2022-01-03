extends AudioStreamPlayer
# Profile button click sound

func _ready() -> void:
	var __: int
	__ = GlobalEvents.connect("ui_profile_selector_profile_pressed", self, "_ui_profile_selector_profile_pressed")


func _ui_profile_selector_profile_pressed() -> void:
	play()
