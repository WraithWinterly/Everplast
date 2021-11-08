extends Area2D

enum Types {
	START,
	START_END,
	END,
}

export(Types) var type: int = 0
export var start_end_path: NodePath
export var start_path: NodePath

var with_player: bool = false
var used: bool = false

onready var start_end: Area2D = get_node(start_end_path)
onready var start: Area2D = get_node(start_path)
onready var anim_player: AnimationPlayer = $AnimationPlayer
onready var anim_player_glow: AnimationPlayer = $AnimationPlayerGlow
onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer


func _ready() -> void:
	connect("body_entered", self, "_body_entered")
	connect("body_exited", self, "_body_exited")
	Signals.connect("sublevel_changed", self, "_sublevel_changed")
	show()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and with_player \
			and not UI.menu_transitioning and not used:
		audio_player.play()
		if type == Types.START:
			anim_player.play("hide")
			Signals.emit_signal("sublevel_changed", start_end.global_position)
			used = true
		elif type == Types.END:
			anim_player.play("hide")
			Signals.emit_signal("sublevel_changed", start.global_position)
			used = true
		anim_player.play("hide")
		yield(anim_player, "animation_finished")
		hide()


func _sublevel_changed(pos: Vector2) -> void:
	if not pos == global_position: return
	if type == Types.START:
		show()
		yield(UI, "faded")
		anim_player.play("hide")
	if type == Types.START_END:
		used = true
		show()
		yield(UI, "faded")
		yield(UI, "faded")
		anim_player.play("hide")
	elif type == Types.START and used:
		yield(UI, "faded")
		anim_player.play("hide")


func _body_entered(body: Node) -> void:
	if body.is_in_group("Player") and not used:
		with_player = true
		anim_player_glow.play("glow")


func _body_exited(body: Node) -> void:
	if body.is_in_group("Player") and not used:
		with_player = false
		anim_player_glow.play_backwards("glow")


