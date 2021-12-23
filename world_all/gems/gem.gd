extends Area2D

export var index: int = 0

var collected: bool = false

onready var coll_shape: CollisionShape2D = $CollisionShape2D
onready var anim_player: AnimationPlayer = $AnimationPlayer
onready var sound: AudioStreamPlayer = $AudioStreamPlayer


func _ready() -> void:
	var __: int
	__ = connect("body_entered", self, "_body_entered")

	index = int(clamp(index, 0, 2))

	var gem_dict: Dictionary = GlobalSave.get_stat("gems")

	if gem_dict.has(str(GlobalLevel.current_world)):
		if gem_dict[str(GlobalLevel.current_world)].has(str(GlobalLevel.current_level)):
			if gem_dict[str(GlobalLevel.current_world)][str(GlobalLevel.current_level)][index]:
				collected = true
				$Sprite.texture = load(GlobalPaths.GEM_USED)
				$Sprite/Light.hide()


func _body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		if not collected:
			GlobalEvents.emit_signal("player_collected_gem", index)

		GlobalInput.start_normal_vibration()
		coll_shape.set_deferred("disabled", true)
		anim_player.play("use")
		sound.play()
		yield(anim_player, "animation_finished")
		queue_free()

