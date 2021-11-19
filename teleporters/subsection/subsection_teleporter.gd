extends Area2D

enum Types {
	START,
	START_SUBSECTION,
	END_SUBSECTION,
	END,
}

export(Types) var type: int = 0
export var start_subsection_path: NodePath
export var start_path: NodePath
export var end_path: NodePath

var with_player: bool = false
var used: bool = false

onready var start: Area2D = get_node(start_path)
onready var start_subsection: Area2D = get_node(start_subsection_path)
onready var end: Area2D = get_node(end_path)
onready var anim_player: AnimationPlayer = $AnimationPlayer
onready var anim_player_glow: AnimationPlayer = $AnimationPlayerGlow
onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer


func _ready() -> void:
	var __: int
	__ = Signals.connect("sublevel_changed", self, "_sublevel_changed")
	__ = connect("body_entered", self, "_body_entered")
	__ = connect("body_exited", self, "_body_exited")
	show()
	if type == Types.END:
		hide()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and with_player \
			and not UI.menu_transitioning and not used:
		if type == Types.START:
			anim_player.play("hide")
			Signals.emit_signal("sublevel_changed", start_subsection.global_position)
			used = true
			with_player = false
			Globals.in_subsection = true
		if type == Types.END_SUBSECTION:
			used = true
			anim_player.play("hide")
			Signals.emit_signal("sublevel_changed", end.global_position)
			Globals.in_subsection = false
			with_player = false
		if type == Types.START_SUBSECTION:
			return
		if type == Types.END:
			return
		audio_player.play()
		anim_player.play("hide")
		yield(anim_player, "animation_finished")
		hide()


func _sublevel_changed(pos: Vector2) -> void:
	if pos == end.global_position and type == Types.START:
		used = false
		show()
		anim_player.play_backwards("hide")
		return
#	if type == Types.START:
#		show()
#		yield(UI, "faded")
#		anim_player.play("hide")
	if type == Types.START_SUBSECTION and pos == start_subsection.global_position:
		used = true
		show()
		anim_player.play("RESET")
		yield(UI, "faded")
		anim_player.play("hide")
	elif type == Types.END:
		if pos == end.global_position:
			show()
			yield(UI, "faded")
			yield(UI, "faded")
			anim_player.play("hide")
			yield(anim_player, "animation_finished")
			hide()
		if pos == start_subsection.global_position:
			anim_player.play("RESET")
			show()
	if type == Types.END_SUBSECTION and pos == start_subsection.global_position:
		used = false
		anim_player.play("RESET")
		show()


func _body_entered(body: Node) -> void:
	if body.is_in_group("Player") and not used:
		with_player = true
		anim_player_glow.play("glow")


func _body_exited(body: Node) -> void:
	if body.is_in_group("Player") and not used:
		with_player = false
		anim_player_glow.play_backwards("glow")


