extends Node2D

export(Array) var sign_text = [["Default Sign Text", "Sign Name", ""]]

var with_player: bool = false

onready var sprite: Sprite = $Sprite
onready var anim_player: AnimationPlayer = $Sprite/AnimationPlayer
onready var label: Label = $Sprite/Label


func _ready() -> void:
	var __: int
	__ = GlobalEvents.connect("level_changed", self, "_level_changed")
	with_player = false
	sprite.frame = int(clamp(GlobalLevel.current_world - 1, 0, INF))

	#label.hide()


func _input(event: InputEvent) -> void:
	if event.is_action_released("interact") and with_player:
		GlobalEvents.emit_signal("ui_dialogued", tr(sign_text[0][0]), tr(sign_text[0][1]), sign_text[0][2])
		yield(get_tree(), "physics_frame")
		for n in sign_text:
			if n.hash() == sign_text[0].hash():
				continue
			if n.size() >= 3:
				GlobalEvents.emit_signal("ui_dialogued", tr(n[0]), tr(n[1]), n[2])
			elif n.size() >= 2:
				GlobalEvents.emit_signal("ui_dialogued", tr(n[0]), tr(n[1]))
			else:
				GlobalEvents.emit_signal("ui_dialogued", tr(n[0]))


func _level_changed(_world: int, _level: int) -> void:
	with_player = false


func _on_CollisionShape2D_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		GlobalInput.interact_activators += 1
		with_player = true
		anim_player.play("show")


func _on_CollisionShape2D_body_exited(body: Node) -> void:
	if body.is_in_group("Player"):
		GlobalInput.interact_activators -= 1
		with_player = false
		anim_player.play_backwards("show")
