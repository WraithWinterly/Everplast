extends AudioStreamPlayer
# Button that brings up a menu


func _ready() -> void:
	var __: int
	__ = GlobalEvents.connect("ui_play_pressed", self, "_ui_play_pressed")


func _ui_play_pressed() -> void:
	play()
