extends Area2D

export var world: int = 0
export var level: int = 0

var with_player: bool = false
var used: bool = false

onready var anim_player: AnimationPlayer = $AnimationPlayer
onready var anim_player_glow: AnimationPlayer = $AnimationPlayerGlow
onready var sound: AudioStreamPlayer = $AudioStreamPlayer


func _ready() -> void:
	var __: int
	__ = connect("body_entered", self, "_body_entered")
	__ = connect("body_exited", self, "_body_exited")
	show()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and with_player \
			and not UI.menu_transitioning and not used:
		used = true
		get_tree().paused = true
		anim_player.play("hide")
		sound.play()
		while anim_player.is_playing():
			get_node(Globals.player_camera_path).set_trauma(0.2)
			yield(get_tree(), "physics_frame")
		Signals.emit_signal("level_completed")


func _body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		with_player = true
		anim_player_glow.play("glow")


func _body_exited(body: Node) -> void:
	if body.is_in_group("Player"):
		with_player = false
		anim_player_glow.play_backwards("glow")


