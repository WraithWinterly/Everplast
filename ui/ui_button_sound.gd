extends AudioStreamPlayer
#Normal button click sound

func _ready() -> void:
	var __: int
	__ = GlobalEvents.connect("ui_button_pressed", self, "_ui_button_pressed")


func _ui_button_pressed(other_sound := false) -> void:
	if other_sound:
		pitch_scale = 1
	else:
		pitch_scale = 1.3

	play()
