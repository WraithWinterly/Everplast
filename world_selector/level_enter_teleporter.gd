extends Area2D

export var world: int = 0
export var level: int = 0

var with_player := false
var allowed := false

onready var anim_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	var __: int
	__ = connect("body_entered", self, "_body_entered")
	__ = connect("body_exited", self, "_body_exited")

	show()

	if GlobalSave.get_stat("world_max") >= world:
		if GlobalSave.get_stat("world_max") == world:
			if GlobalSave.get_stat("level_max") >= level:
				allowed = true
		else:
				allowed = true
	else:
		allowed = false

	if not allowed:
		$Sprite/Light2D.hide()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and with_player \
			and not GlobalUI.menu_locked:
		GlobalLevel.selected_world = world
		GlobalLevel.selected_level = level
		GlobalUI.menu = GlobalUI.Menus.LEVEL_ENTER
		GlobalEvents.emit_signal("ui_button_pressed_to_prompt")
		GlobalEvents.emit_signal("ui_level_enter_menu_pressed")


func _body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		with_player = true
		anim_player.play("glow")


func _body_exited(body: Node) -> void:
	if body.is_in_group("Player"):
		with_player = false
		anim_player.play_backwards("glow")


