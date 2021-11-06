extends Area2D

onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var sound: AudioStreamPlayer = $AudioStreamPlayer


func _ready() -> void:
	connect("body_entered", self, "_body_entered")
	if LevelController.checkpoint_active and \
			LevelController.checkpoint_world == LevelController.current_world and \
			LevelController.checkpoint_level == LevelController.current_level:
		hide_self()


func _body_entered(body: Node) -> void:
	if body.is_in_group("Player") and not LevelController.checkpoint_active:
		Signals.emit_signal("checkpoint_activated")
		UI.emit_signal("show_notification", "Checkpoint Reached!")
		Signals.emit_signal("save")
		sound.play()
		hide_self()


func hide_self() -> void:
	animation_player.play("hide")
	yield(animation_player, "animation_finished")
	call_deferred("free")
