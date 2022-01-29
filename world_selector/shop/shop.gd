extends Node2D

export var items := {
	#         Amount | Coins
	"gems": 3,
	"carrot": [false, 10, 10],
	"bunny egg": [false, 1, 20],
	"coconut": [false, 10, 25],
	"pear": [false, 2, 250],
	"cherry": [false, 5, 25],
	"ice spike": [false, 1, 25],
	"glitch orb": [false, 1, 30],
	"glitch soul": [false, 1, 35],
	"orbs": [false, 100, 40],

	"water": [false, 5, 10],
	"energy": [false, 5, 20],
	"nail": [false, 5, 30],
	"snowball": [false, 5, 40],

	"water gun": [false, 1, 50],
	"laser gun": [false, 1, 100],
	"snow gun": [false, 1, 150],
	"ice gun": [false, 1, 250],
	"nail gun": [false, 1, 300],
}

var with_player := false


func _ready() -> void:
	$AnimationPlayer.play("idle_glow")


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and with_player:
		GlobalEvents.emit_signal("ui_shop_opened", items)



func _on_Shop_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		with_player = true
		$AnimationPlayer.play("glow")
		GlobalInput.interact_activators += 1


func _on_Shop_body_exited(body: Node) -> void:
	if body.is_in_group("Player"):
		with_player = false
		$AnimationPlayer.play("idle_glow")
		GlobalInput.interact_activators -= 1
