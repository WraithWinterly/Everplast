extends Area2D

enum Types {
	NORMAL,
	BULLLET
}

export(Types) var type: int = 0
export var item: PackedScene
export var height: int = 6
export var offset_x: int = 0
export var modifier_name: String = ""
export var modifier_value = ""

onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
onready var anim_player: AnimationPlayer = $AnimationPlayer
onready var sprite: Sprite = $Sprite
onready var static_body_coll_shape: CollisionShape2D = $StaticBody2D/CollisionShape2D

func _ready() -> void:
	connect("body_entered", self, "_body_entered")
	if type == Types.BULLLET:
		sprite.texture = load(FileLocations.vase_bullet)



func _body_entered(body: Node) -> void:
	if type == Types.NORMAL:
		if not (body.is_in_group("Player") or body.is_in_group("Bullet")):
			return
	elif type == Types.BULLLET:
		if not body.is_in_group("Bullet"):
			return
	static_body_coll_shape.set_deferred("disabled", true)
	if not item == null:
		var item_instance = item.instance()
		item_instance.global_position = Vector2(global_position.x,
				global_position.y - height)
		get_node(Globals.level_path).call_deferred("add_child", item_instance)
		if not modifier_name == "":
			item_instance.set(modifier_name, modifier_value)
		anim_player.play("break")
		audio_stream_player.play()
		yield(anim_player, "animation_finished")
		hide()
		call_deferred("free")
