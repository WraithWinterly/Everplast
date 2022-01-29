extends Control

onready var anim_player: AnimationPlayer = $CanvasLayer/Panel/AnimationPlayer
onready var label: Label = $CanvasLayer/Panel/Label
onready var sound: AudioStreamPlayer = $AudioStreamPlayer


func _ready() -> void:
	var __: int
	__ = GlobalEvents.connect("save_file_saved", self, "_save_file_saved")
	__ = GlobalEvents.connect("ui_notification_shown", self, "_ui_notification_shown")

	hide()


func show_notification(noti: String, wait: bool = false) -> void:
	show()

	if wait:
		if not anim_player.is_playing():
			label.text = noti
			sound.play()
			anim_player.play("notification")
			yield(anim_player, "animation_finished")
			GlobalEvents.emit_signal("ui_notification_finished")
		else:
			yield(GlobalEvents, "ui_notification_finished")
			show()
			label.text = noti
			sound.play()
			anim_player.play("notification")
	else:
		sound.play()
		anim_player.play("RESET")
		anim_player.play("notification")
		yield(get_tree(), "idle_frame")
		label.text = noti
		yield(anim_player, "animation_finished")
		GlobalEvents.emit_signal("ui_notification_finished")


func _save_file_saved(save_silent: bool = false) -> void:
	if GlobalUI.menu_locked:
		yield(GlobalEvents, "ui_faded")

	if save_silent: return

	yield(get_tree(), "physics_frame")
	yield(get_tree(), "physics_frame")

	if anim_player.is_playing():
		yield(GlobalEvents, "ui_notification_finished")
	GlobalEvents.emit_signal("ui_notification_shown", tr("notification.saved"))


func _ui_notification_shown(noti: String) -> void:
	show_notification(noti)
