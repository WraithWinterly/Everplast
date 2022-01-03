extends AudioStreamPlayer


func _ready() -> void:
	var __: int
	__ = GlobalEvents.connect("ui_pause_menu_return_prompt_yes_pressed", self, "_ui_pause_menu_return_prompt_yes_pressed")


func _ui_pause_menu_return_prompt_yes_pressed() -> void:
	play()
