extends StaticBody2D

onready var anim_player: AnimationPlayer = $Sprite/AnimationPlayer
onready var area_2d: Area2D = $Area2D
onready var sound: AudioStreamPlayer = $AudioStreamPlayer

var used: bool = false
var amount: int = 80


func _ready() -> void:
	area_2d.connect("body_entered", self, "_body_entered")
	
	
func _body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		if body.get_parent().falling:
			anim_player.play("jump")
			Signals.emit_signal("springboard_used", amount)
			sound.play()


