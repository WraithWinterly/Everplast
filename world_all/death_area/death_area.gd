extends Area2D


func _ready() -> void:
	var __: int = connect("body_entered", self, "_body_entered")


func _body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		GlobalEvents.emit_signal("player_death_started")
