extends RigidBody2D

var self_collisions: int = 0

func _ready() -> void:
	for cannon in get_tree().get_nodes_in_group("Cannon"):
		add_collision_exception_with(cannon)


func destroy() -> void:
	$AnimationPlayer.play("destroy")
	$CollisionShape2D.set_deferred("disabled", true)
	$Particles.emitting = true
	$BreakSound.play()


func _on_Snowball_body_entered(_body: Node) -> void:
	var collides_with_self := false

	for body in get_colliding_bodies():
		if body.is_in_group("Cannon"):
			self_collisions += 1
		elif body.is_in_group("Player"):
			GlobalEvents.emit_signal("player_hurt_from_enemy", Globals.HurtTypes.TOUCH, 150, 10)

	if collides_with_self:
		if get_colliding_bodies().size() > self_collisions:
			destroy()
	else:
		if get_colliding_bodies().size() > 0:
			destroy()


func _on_AnimationPlayer_animation_finished(_anim_name: String) -> void:
	call_deferred("free")
