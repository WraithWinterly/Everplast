extends Area2D

var active := true

onready var anim_player: AnimationPlayer = $Sprite/AnimationPlayer
onready var particles: Particles2D = $Particles2D


func _ready() -> void:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	$Sprite.frame = rng.randi_range(0, 2)


func _on_PiledSnow_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		particles.emitting = true
		anim_player.play("hit")
		active = false
		var lvl: Node2D = get_node(GlobalPaths.LEVEL)
		var snowball = load(GlobalPaths.SNOWBALL_ITEM).instance()
		lvl.call_deferred("add_child", snowball)
		yield(get_tree(), "physics_frame")
		yield(get_tree(), "physics_frame")
		snowball.global_position.x = global_position.x
		snowball.global_position.y = global_position.y
		snowball.get_node("CollectableBase").give_one = true


func _on_AnimationPlayer_animation_finished(_anim_name: String) -> void:
	call_deferred("free")
