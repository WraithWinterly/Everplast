extends Node2D

export var items := {
	#         Amount | Coins
	"gems": 3,
	"carrot": [false, 10, 50],
	"bunny egg": [false, 1, 150],
	"cherry": [false, 5, 300],
	"coconut": [false, 10, 250],
	"glitch orb": [false, 1, 500],
	"glitch soul": [false, 1, 300],
	"pear": [false, 2, 250],
	"ice spike": [false, 1, 250],
	"orbs": [false, 100, 250],

	"water": [false, 10, 100],
	"energy": [false, 10, 200],
	"nail": [false, 10, 300],
	"snowball": [false, 10, 400],

	"water gun": [false, 1, 250],
	"laser gun": [false, 1, 350],
	"nail gun": [false, 1, 450],
	"snow gun": [false, 1, 500],
	"ice gun": [false, 1, 500],
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
