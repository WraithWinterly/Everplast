extends Area2D

export var index: int = 0

var enabled: bool = true

onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var sound: AudioStreamPlayer = $AudioStreamPlayer
onready var light: Sprite = $Sprite/Light2D
onready var coll_shape: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	var __: int
	__ = GlobalEvents.connect("level_checkpoint_activated", self, "_level_checkpoint_activated")
	__ = connect("body_entered", self, "_body_entered")

	light.self_modulate = Color8(122, 122, 122, 255)

	if index <= GlobalLevel.checkpoint_index and GlobalLevel.checkpoint_active and \
			GlobalLevel.checkpoint_world == GlobalLevel.current_world and \
			GlobalLevel.checkpoint_level == GlobalLevel.current_level:
		disable(false)


func disable(animation: bool = true) -> void:
	enabled = false
	coll_shape.set_deferred("disabled", true)
	if animation:
		animation_player.play("hide")
		yield(animation_player, "animation_finished")
	light.self_modulate = Color8(20, 135, 30, 255)
	animation_player.play_backwards("hide")


func _body_entered(body: Node) -> void:
	if body.is_in_group("Player") and not (GlobalLevel.checkpoint_active and GlobalLevel.checkpoint_index == index):
		GlobalInput.start_high_vibration()
		GlobalLevel.checkpoint_in_sub = GlobalLevel.in_subsection
		GlobalLevel.checkpoint_index = index
		GlobalEvents.emit_signal("level_checkpoint_activated")
		GlobalEvents.emit_signal("ui_notification_shown", tr("notification.checkpoint"))
		GlobalEvents.emit_signal("save_file_saved", true)
		sound.play()
		disable()


func _level_checkpoint_activated() -> void:
	if GlobalLevel.checkpoint_index > index and enabled:
		disable()
