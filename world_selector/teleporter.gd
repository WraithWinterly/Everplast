extends Area2D

export var world: int = 0
export var level: int = 0

var with_player: bool = false
var allowed: bool = false

onready var anim_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	var __: int
	__ = connect("body_entered", self, "_body_entered")
	__ = connect("body_exited", self, "_body_exited")
	show()
	if PlayerStats.get_stat("world_max") >= world:
		if PlayerStats.get_stat("world_max") == world:
			if PlayerStats.get_stat("level_max") >= level:
				allowed = true
		else:
				allowed = true
	else:
		allowed = false

	if not allowed:
		$Sprite/Light2D.hide()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and with_player \
			and not UI.menu_transitioning:
		Globals.selected_world = world
		Globals.selected_level = level
		UI.emit_signal("changed", UI.WORLD_SELECTOR_LEVEL_ENTER)


func _body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		with_player = true
		anim_player.play("glow")


func _body_exited(body: Node) -> void:
	if body.is_in_group("Player"):
		with_player = false
		anim_player.play_backwards("glow")


