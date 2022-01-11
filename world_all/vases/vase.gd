extends Area2D

enum Types {
	NORMAL,
	BULLLET
}

export(bool) var use_override_item: bool
export var override_item: PackedScene

var item: PackedScene

var type: int = Types.NORMAL

var height: int = 6
var offset_x: int = 0

var ignore: int = false

onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
onready var anim_player: AnimationPlayer = $AnimationPlayer
onready var sprite: Sprite = $Sprite
onready var static_body_coll_shape: CollisionShape2D = $StaticBody2D/CollisionShape2D


func _ready() -> void:
	var __: int
	__ = connect("body_entered", self, "_body_entered")

	if use_override_item:
		item = override_item
		return

	# Determine Item with RNG
	var rng := RandomNumberGenerator.new()
	rng.seed = 694209999

	#Add consistent randomization
	rng.seed += int(name)
	rng.seed += GlobalLevel.current_world + GlobalLevel.current_level

	var num: int = rng.randi_range(0, 100)

	if num <= 35:
		item = load(GlobalPaths.COIN)

	elif num <= 50:
		if GlobalLevel.current_world == 1:
			item = load(GlobalPaths.CARROT)
		elif GlobalLevel.current_world == 2:
			item = load(GlobalPaths.COCONUT)
		elif GlobalLevel.current_world == 3:
			item = load(GlobalPaths.CHERRY)

	elif num <= 75:
		if GlobalLevel.current_world == 1:
			item = load(GlobalPaths.WATER)
		elif GlobalLevel.current_world == 2:
			item = load(GlobalPaths.ENERGY)
		elif GlobalLevel.current_world == 3:
			item = load(GlobalPaths.SNOWBALL_ITEM)
	elif num <= 100:
		if GlobalLevel.current_world == 1:
			# Bullet vases can't be used yet, awkward to show them
			if GlobalLevel.current_level <= 4:
				item = load(GlobalPaths.CARROT)
				return
			item = load(GlobalPaths.BUNNY_EGG)
		elif GlobalLevel.current_world == 2:
			item = load(GlobalPaths.PEAR)
		elif GlobalLevel.current_world == 3:
			item = load(GlobalPaths.ICE_SPIKE)
		type = Types.BULLLET

	if type == Types.BULLLET:
		sprite.texture = load(GlobalPaths.VASE_BULLET)


func _body_entered(body: Node) -> void:
	if ignore: return

	if type == Types.NORMAL:
		if not (body.is_in_group("Player") or body.is_in_group("Bullet")):
			return
	elif type == Types.BULLLET:
		if not body.is_in_group("Bullet"):
			return

	GlobalInput.start_low_vibration()
	static_body_coll_shape.set_deferred("disabled", true)
	ignore = true

	if not item == null:
		var item_instance = item.instance()

		item_instance.global_position = Vector2(global_position.x,
				global_position.y - height)
		get_node(GlobalPaths.LEVEL).call_deferred("add_child", item_instance)
#		if not modifier_name == "":
#			item_instance.set(modifier_name, modifier_value)
		anim_player.play("break")
		audio_stream_player.play()
		yield(anim_player, "animation_finished")
		hide()
		call_deferred("free")
