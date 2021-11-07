extends Area2D

export var world: int = 0
export var level: int = 0

var with_player: bool = false

onready var anim_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	connect("body_entered", self, "_body_entered")
	connect("body_exited", self, "_body_exited")
	hide()
	set_process_input(false)

	if PlayerStats.get_stat("world_max") >= world:
		if PlayerStats.get_stat("world_max") == world:
			if PlayerStats.get_stat("level_max") >= level:
				show()
				set_process_input(true)
		else:
				show()
				set_process_input(true)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and with_player \
			and not UI.menu_transitioning:
		Signals.emit_signal("level_changed", world, level)


func _body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		with_player = true
		anim_player.play("glow")


func _body_exited(body: Node) -> void:
	if body.is_in_group("Player"):
		with_player = false
		anim_player.play_backwards("glow")


