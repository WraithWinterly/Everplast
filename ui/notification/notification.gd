extends Control


onready var animation_player: AnimationPlayer = $CanvasLayer/Panel/AnimationPlayer
onready var label: Label = $CanvasLayer/Panel/Label
onready var sound: AudioStreamPlayer = $AudioStreamPlayer


func _ready() -> void:
	var __: int
	__ = Signals.connect("save", self, "_save")
	__ = UI.connect("show_notification", self, "show_notification")
	hide()


func show_notification(message: String) -> void:
	show()
	label.text = message
	if not animation_player.is_playing():
		sound.play()
		animation_player.play("notification")
		yield(animation_player, "animation_finished")
		UI.emit_signal("notification_finished")
		hide()


func _save(noti: bool = true) -> void:
	if UI.menu_transitioning:
		yield(UI, "faded")
	if animation_player.is_playing():
		yield(UI, "notification_finished")
	if not noti: return
	show_notification("Saved Game!")
