extends Area2D

export(GlobalStats.Ranks) var rank: int = 1

onready var sprite: Sprite = $SpriteHolder/Sprite
onready var anim_player: AnimationPlayer = $AnimationPlayer
onready var rank_start_sound: AudioStreamPlayer = $RankStart
onready var collision_shape: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	var __: int
	__ = connect("body_entered", self, "_body_entered")
	show()
	update()


func update() -> void:
	anim_player.play("normal")
	match rank:
		GlobalStats.Ranks.NONE, GlobalStats.Ranks.SILVER:
			sprite.region_rect = Rect2(0, 0, 11, 13)
		GlobalStats.Ranks.GOLD:
			sprite.region_rect = Rect2(11, 0, 11, 13)
		GlobalStats.Ranks.DIAMOND:
			sprite.region_rect = Rect2(22, 0, 11, 13)
		GlobalStats.Ranks.GLITCH:
			sprite.region_rect = Rect2(33, 0, 11, 13)
	if GlobalSave.get_stat("rank") >= rank:
		sprite.region_rect = Rect2(44, 0, 11, 13)


func _body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		rank_start_sound.play()
		collision_shape.set_deferred("disabled", true)
		if rank > GlobalSave.get_stat("rank"):
			anim_player.play("collect")
		else:
			anim_player.play("collect_used")
		yield(anim_player, "animation_finished")
		if rank > GlobalSave.get_stat("rank"):
			GlobalSave.set_stat("rank", rank)
			GlobalEvents.emit_signal("ui_notification_shown", "%s %s!" % [tr("notification.rank_upgrade"), GlobalStats.Ranks.keys()[rank].capitalize()])
			GlobalEvents.emit_signal("save_file_saved", false)
