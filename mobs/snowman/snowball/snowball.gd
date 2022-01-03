extends RigidBody2D


func _ready() -> void:
	for snowman in get_tree().get_nodes_in_group("Snowman"):
		add_collision_exception_with(snowman)
	$ThrowSound.play()


func destroy() -> void:
	$AnimationPlayer.play("destroy")
	$CollisionShape2D.set_deferred("disabled", true)
	$Particles.emitting = true
	$BreakSound.play()
	sleeping = true


func _on_Snowball_body_entered(body: Node) -> void:
	var collides_with_self := false

	for body in get_colliding_bodies():
		if body.is_in_group("Snowman"):
			collides_with_self = true
			continue
		elif body.is_in_group("Player"):
			GlobalEvents.emit_signal("player_hurt_from_enemy", Globals.HurtTypes.TOUCH, 150, 5)
	if body.is_in_group("Bullet"):
		destroy()
		return
	if collides_with_self:
		if get_colliding_bodies().size() > 1:
			destroy()
	else:
		if get_colliding_bodies().size() > 0:
			destroy()


func _on_AnimationPlayer_animation_finished(_anim_name: String) -> void:
	call_deferred("free")
