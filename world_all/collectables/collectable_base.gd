extends Area2D

export var collectable_name: String = "energy"

onready var animation_player: AnimationPlayer = $AnimationPlayer

enum {
	COLLECT,
	USE
}

var mode: int = COLLECT
var give_one := false

func _ready() -> void:
	var __: int
	__ = connect("body_entered", self, "_body_entered")

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
			if give_one:
				GlobalEvents.emit_signal("player_collected_collectable", collectable_name)
			else:
				for _n in range(10):
					GlobalEvents.emit_signal("player_collected_collectable", collectable_name)

