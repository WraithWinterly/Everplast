extends AudioStreamPlayer
# Button that brings up a prompt


func _ready() -> void:
	var __: int
	__ = GlobalEvents.connect("ui_button_pressed_to_prompt", self, "_ui_button_pressed_to_prompt")


func _ui_button_pressed_to_prompt() -> void:
	play()
