extends Area2D


func _ready():
	connect("body_entered", self, "_body_entered")


func _body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		Signals.emit_signal("start_player_death")
