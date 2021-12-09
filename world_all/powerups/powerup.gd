extends Area2D

export var item_name: String = "carrot"

onready var animation_player: AnimationPlayer = $AnimationPlayer

enum {
	COLLECT,
	USE
}

var mode: int = COLLECT

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
			GlobalEvents.emit_signal("player_collected_powerup", item_name)

