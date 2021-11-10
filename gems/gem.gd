extends Area2D


export var index: int = 0

var collected: bool = false

onready var coll_shape: CollisionShape2D = $CollisionShape2D
onready var anim_player: AnimationPlayer = $AnimationPlayer
onready var sound: AudioStreamPlayer = $AudioStreamPlayer


func _ready() -> void:
	index = int(clamp(index, 0, 2))
	connect("body_entered", self, "_body_entered")
	var gem_dict: Dictionary = PlayerStats.get_stat("gems")
	if gem_dict.has(str(LevelController.current_world)):
		if gem_dict[str(LevelController.current_world)].has(str(LevelController.current_level)):
			if gem_dict[str(LevelController.current_world)][str(LevelController.current_level)][index]:
				collected = true
				$Sprite.texture = load(FileLocations.gem_used)


func _body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		if not collected:
			Signals.emit_signal("gem_collected", index)
		coll_shape.set_deferred("disabled", true)
		anim_player.play("use")
		sound.play()
		yield(anim_player, "animation_finished")
		queue_free()

