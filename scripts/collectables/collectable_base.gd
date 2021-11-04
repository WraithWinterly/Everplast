extends Area2D

export var collectable_name: String = "energy"

onready var animation_player: AnimationPlayer = $AnimationPlayer

enum {
	COLLECT,
	USE
}

var mode: int = COLLECT


func _ready() -> void:
	connect("body_entered", self, "_body_entered")
	if mode == USE:
		animation_player.play("used")
		yield(animation_player, "animation_finished")
		call_deferred("free")



func _body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		if mode == COLLECT:
			$Sound.play()
			$CollisionShape2D.set_deferred("disabled", true)
			animation_player.play("collected")
			for _n in range(10):
				Signals.emit_signal("collectable_collected", collectable_name)

