extends RigidBody2D

var damage: int = 0
var speed: int = 0


func _ready() -> void:
	$Sound.play()
	match PlayerStats.get_stat("equiped_item"):
		"nail gun":
			damage = 5
			speed = 300
		"laser gun":
			damage = 10
			speed = 700
		"water gun":
			damage = 1
			speed = 500


func _body_entered(body: Node) -> void:
	yield(get_tree(), "physics_frame")
	$CollisionShape2D.set_deferred("disabled", true)
	set_deferred("mode", MODE_KINEMATIC)
	$AnimationPlayer.play("collected")
	yield($AnimationPlayer, "animation_finished")
	call_deferred("free")


func _on_VisibilityNotifier2D_screen_exited() -> void:
	call_deferred("free")
