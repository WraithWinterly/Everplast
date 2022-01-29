extends Node

var ignore_fire := false
var ui_used_up := false
var ui_used_down := false
var ui_used_left := false
var ui_used_right := false

# Control Prompts
var interact_activators: int = 0

var dash_activated: bool = false
var fire_activated: bool = false
var dialogue_activated: bool = false
var powerup_activated: bool = false
var equip_activated: bool = false


func _physics_process(_delta: float) -> void:

	if GlobalUI.menu == GlobalUI.Menus.DIALOGUE:
		dialogue_activated = true

	if Globals.game_state == Globals.GameStates.LEVEL:
		match GlobalSave.get_stat("equipped_item"):
			"none":
				fire_activated = false
			_:
				fire_activated = true
	else:
		fire_activated = false

	if Globals.game_state == Globals.GameStates.LEVEL:
		equip_activated = GlobalSave.get_stat("equippables").size() > 0
		powerup_activated = GlobalSave.get_stat("powerups").size() > 0
	else:
		equip_activated = false
		powerup_activated = false

	# Was engine bug, is fixed now
	check_action("stick_ui_up")
	check_action("stick_ui_down")
	check_action("stick_ui_left")
	check_action("stick_ui_right")


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("stick_ui_up"):
		if not ui_used_up:
			stick_action("ui_up")
			ui_used_up = true
		else:
			release_action("ui_up")

	elif event.is_action_pressed("stick_ui_down"):
		if not ui_used_down:
			stick_action("ui_down")
			ui_used_down = true
		else:
			release_action("ui_down")

	elif event.is_action_pressed("stick_ui_left"):
		if not ui_used_left:
			stick_action("ui_left")
			ui_used_left = true
		else:
			release_action("ui_left")

	elif event.is_action_pressed("stick_ui_right"):
		if not ui_used_right:
			stick_action("ui_right")
			ui_used_right = true
		else:
			release_action("ui_right")

	elif event.is_action_released("fire"):
		ignore_fire = false


func check_action(input_event: String) -> void:
	if not Input.is_action_pressed(input_event):
		match input_event:
			"stick_ui_up":
				ui_used_up = false
			"stick_ui_down":
				ui_used_down = false
			"stick_ui_left":
				ui_used_left = false
			"stick_ui_right":
				ui_used_right = false


func stick_action(action: String) -> void:
	var input_action = InputEventAction.new()
	input_action.action = action
	input_action.pressed = true
	Input.parse_input_event(input_action)


func release_action(action: String) -> void:
	var input_action = InputEventAction.new()
	input_action.action = action
	input_action.pressed = false
	Input.parse_input_event(input_action)


func start_low_vibration() -> void:
	Input.stop_joy_vibration(0)
	Input.start_joy_vibration(get_node(GlobalPaths.SETTINGS).data.controller_index, 0.1, 0, 0.05)


func start_normal_vibration() -> void:
	Input.stop_joy_vibration(0)
	Input.start_joy_vibration(get_node(GlobalPaths.SETTINGS).data.controller_index, 0.15, 0.05, 0.1)


func start_high_vibration() -> void:
	Input.start_joy_vibration(get_node(GlobalPaths.SETTINGS).data.controller_index, 0.4, 0.2, 0.25)


func start_ultra_high_vibration() -> void:
	Input.start_joy_vibration(get_node(GlobalPaths.SETTINGS).data.controller_index, 1, 0.8, 1.5)


func get_action_strength_keyboard() -> float:
	return float(Input.get_axis("move_left", "move_right"))


func get_action_strength_controller() -> float:
	return float(Input.get_axis("ctr_move_left", "ctr_move_right"))


func get_action_strength() -> float:
	if abs(get_action_strength_keyboard()) > 0:
		return get_action_strength_keyboard()
	else:
		return get_action_strength_controller()


func get_controller_right_axis() -> Vector2:
	return Vector2(Input.get_axis("ctr_look_left", "ctr_look_right"),
			Input.get_axis("ctr_look_down", "ctr_look_up"))
