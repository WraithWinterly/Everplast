extends Node2D

export(Array) var sign_text = [["Default Sign Text", "Sign Name", ""]]

onready var sprite: Sprite = $Sprite
onready var animation_player: AnimationPlayer = $Sprite/AnimationPlayer

var with_player: bool = false

func _ready() -> void:
	with_player = false
	sprite.frame = int(clamp(LevelController.current_world - 1, 0, INF))
	Signals.connect("level_changed", self, "_level_changed")


func _input(event: InputEvent) -> void:
	if event.is_action_released("interact") and with_player and not Globals.dialog_active:
		Signals.emit_signal("dialog", sign_text[0][0], sign_text[0][1], sign_text[0][2])
		yield(get_tree(), "physics_frame")
		for n in sign_text:
			if n.hash() == sign_text[0].hash():
				continue
			if sign_text.size() >= 3:
				Signals.emit_signal("dialog", n[0], n[1], n[2])
			else:
				Signals.emit_signal("dialog", n[0], n[1])


func _level_changed(_world: int, _level: int) -> void:
	with_player = false



func _on_CollisionShape2D_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		with_player = true


func _on_CollisionShape2D_body_exited(body: Node) -> void:
	if body.is_in_group("Player"):
		with_player = false
