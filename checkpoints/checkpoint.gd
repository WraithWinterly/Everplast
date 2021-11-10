extends Area2D

onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var sound: AudioStreamPlayer = $AudioStreamPlayer
onready var light: Sprite = $Sprite/Light2D
onready var coll_shape: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	light.self_modulate = Color8(122, 122, 122, 255)
	connect("body_entered", self, "_body_entered")
	if LevelController.checkpoint_active and \
			LevelController.checkpoint_world == LevelController.current_world and \
			LevelController.checkpoint_level == LevelController.current_level:
		disable(false)


func _body_entered(body: Node) -> void:
	if body.is_in_group("Player") and not LevelController.checkpoint_active:
		Signals.emit_signal("checkpoint_activated")
		UI.emit_signal("show_notification", "Checkpoint Reached!")
		Signals.emit_signal("save")
		sound.play()
		disable()


func disable(animation: bool = true) -> void:
	coll_shape.set_deferred("disabled", true)
	if animation:
		animation_player.play("hide")
		yield(animation_player, "animation_finished")
	light.self_modulate = Color8(20, 135, 30, 255)
	animation_player.play_backwards("hide")

