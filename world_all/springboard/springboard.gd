extends StaticBody2D

export var mimick_level := 0

var used := false
var amount: int = 100

onready var anim_player: AnimationPlayer = $Sprite/AnimationPlayer
onready var area_2d: Area2D = $Area2D
onready var sound: AudioStreamPlayer = $AudioStreamPlayer
onready var particles := $Sprite/Particles2D as Particles2D


func _ready() -> void:
	var __: int
	__ = area_2d.connect("body_entered", self, "_body_entered")
	# Fit stutter on first use
	particles.emitting = true
	if GlobalLevel.current_world == 3 or mimick_level == 3:
		amount *= 2


func _body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		GlobalEvents.emit_signal("player_used_springboard", amount)
	elif body.is_in_group("Mob"):
		GlobalEvents.emit_signal("mob_used_springboard", body, amount)
	else:
		return
	anim_player.play("jump")
	sound.play()
	particles.emitting = true

