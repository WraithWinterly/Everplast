extends AudioStreamPlayer


func _ready() -> void:
	var __: int
	__ = GlobalEvents.connect("ui_button_hovered", self, "_ui_button_hovered")


func _ui_button_hovered() -> void:
	# Disabled for now
	return
#	if GlobalUI.dis_focus_sound:
#		GlobalUI.dis_focus_sound = false
#		return
#	pitch_scale = rand_range(1.05, 1.15)
#	play()
