extends Particles2D


func _enter_tree() -> void:
	emitting = true


func _physics_process(_delta: float) -> void:
	if not emitting:
		$AnimationPlayer.play("fade")


func _on_AnimationPlayer_animation_finished(_anim_name: String) -> void:
	call_deferred("free")
