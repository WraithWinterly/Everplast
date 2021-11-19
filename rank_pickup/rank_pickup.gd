extends Area2D

export(PlayerStats.Ranks) var rank: int = 1

onready var sprite: Sprite = $SpriteHolder/Sprite
onready var anim_player: AnimationPlayer = $AnimationPlayer
onready var rank_start_sound: AudioStreamPlayer = $RankStart
onready var collision_shape: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	var __: int
	__ = connect("body_entered", self, "_body_entered")
	show()
	anim_player.play("normal")
	match rank:
		PlayerStats.Ranks.NONE, PlayerStats.Ranks.SILVER:
			sprite.region_rect = Rect2(0, 0, 11, 13)
		PlayerStats.Ranks.GOLD:
			sprite.region_rect = Rect2(11, 0, 11, 13)
		PlayerStats.Ranks.DIAMOND:
			sprite.region_rect = Rect2(22, 0, 11, 13)
		PlayerStats.Ranks.EMERALD:
			sprite.region_rect = Rect2(33, 0, 11, 13)
		PlayerStats.Ranks.GLITCH:
			sprite.region_rect = Rect2(44, 0, 11, 13)
		PlayerStats.Ranks.VOLCANO:
			sprite.region_rect = Rect2(55, 0, 11, 13)
	if PlayerStats.get_stat("rank") >= rank:
		sprite.region_rect = Rect2(66, 0, 11, 13)

func _body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		collision_shape.set_deferred("disabled", true)
		rank_start_sound.play()
		if rank > PlayerStats.get_stat("rank"):
			anim_player.play("collect")
		else:
			anim_player.play("collect_used")
		yield(anim_player, "animation_finished")
		if rank > PlayerStats.get_stat("rank"):
			PlayerStats.set_stat("rank", rank)
			UI.emit_signal("show_notification", "Rank Upgraded to %s!" %  PlayerStats.ranks[rank].capitalize())
			Signals.emit_signal("save", false)