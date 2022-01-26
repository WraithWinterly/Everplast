extends Control

var listening_action: String

var listening_secondary := false
var listening := false

onready var scroll_container: ScrollContainer = $Panel/BG/ScrollContainer
onready var anim_player: AnimationPlayer = $AnimationPlayer

onready var return_button: Button = $Panel/Return

onready var assignments_1: VBoxContainer = $Panel/BG/ScrollContainer/Collumns/Assignments1
onready var ability: Button = $Panel/BG/ScrollContainer/Collumns/Assignments1/Ability
onready var walk_left: Button = $"Panel/BG/ScrollContainer/Collumns/Assignments1/Move Left"
onready var walk_right: Button = $"Panel/BG/ScrollContainer/Collumns/Assignments1/Move Right"
onready var move_down: Button = $"Panel/BG/ScrollContainer/Collumns/Assignments1/Move Down"
onready var jump: Button = $"Panel/BG/ScrollContainer/Collumns/Assignments1/Move Jump"
onready var sprint: Button = $"Panel/BG/ScrollContainer/Collumns/Assignments1/Move Sprint"
onready var interact: Button = $Panel/BG/ScrollContainer/Collumns/Assignments1/Interact
onready var inventory: Button = $Panel/BG/ScrollContainer/Collumns/Assignments1/Inventory
onready var fire: Button = $Panel/BG/ScrollContainer/Collumns/Assignments1/Fire
onready var equip: Button = $Panel/BG/ScrollContainer/Collumns/Assignments1/Equip
onready var powerup: Button = $Panel/BG/ScrollContainer/Collumns/Assignments1/Powerup

onready var assignments_2: VBoxContainer = $Panel/BG/ScrollContainer/Collumns/Assignments2
onready var ability_2: Button = $Panel/BG/ScrollContainer/Collumns/Assignments2/Ability
onready var walk_left_2: Button = $"Panel/BG/ScrollContainer/Collumns/Assignments2/Move Left"
onready var walk_right_2: Button = $"Panel/BG/ScrollContainer/Collumns/Assignments2/Move Right"
onready var move_down_2: Button = $"Panel/BG/ScrollContainer/Collumns/Assignments2/Move Down"
onready var jump_2: Button = $"Panel/BG/ScrollContainer/Collumns/Assignments2/Move Jump"
onready var sprint_2: Button = $"Panel/BG/ScrollContainer/Collumns/Assignments2/Move Sprint"
onready var interact_2: Button = $Panel/BG/ScrollContainer/Collumns/Assignments2/Interact
onready var inventory_2: Button = $Panel/BG/ScrollContainer/Collumns/Assignments2/Inventory
onready var fire_2: Button = $Panel/BG/ScrollContainer/Collumns/Assignments2/Fire
onready var equip_2: Button = $Panel/BG/ScrollContainer/Collumns/Assignments2/Equip
onready var powerup_2: Button = $Panel/BG/ScrollContainer/Collumns/Assignments2/Powerup


func _ready() -> void:
	var __: int
	__ = GlobalEvents.connect("ui_settings_controls_customize_pressed", self, "_ui_settings_controls_customize_pressed")
	__ = GlobalEvents.connect("ui_settings_reset_settings_prompt_yes_pressed", self, "_ui_settings_reset_settings_prompt_yes_pressed")
	__ = return_button.connect("pressed", self, "_return_pressed")
	__ = return_button.connect("focus_entered", self, "_button_hovered")
	__ = return_button.connect("mouse_entered", self, "_button_hovered")

	for button in assignments_1.get_children():
		if button is Button:
			__ = button.connect("focus_entered", self, "_button_hovered")
			__ = button.connect("mouse_entered", self, "_button_hovered")

	for button in assignments_2.get_children():
		if button is Button:
			__ = button.connect("focus_entered", self, "_button_hovered")
			__ = button.connect("mouse_entered", self, "_button_hovered")

	for button in $Panel/BG/ScrollContainer/Collumns/Reset.get_children():
		if button is Button:
			__ = button.connect("focus_entered", self, "_button_hovered")
			__ = button.connect("mouse_entered", self, "_button_hovered")

	scroll_container.get_child(0).set("custom_styles/scroll", load(GlobalPaths.CREDITS_SCROLL))
	scroll_container.get_child(0).set("custom_styles/scroll_focus", load(GlobalPaths.CREDITS_SCROLL))
	scroll_container.get_child(0).set("custom_styles/grabber", load(GlobalPaths.CREDITS_SCROLL_GRABBER))
	scroll_container.get_child(0).set("custom_styles/grabber_highlight", load(GlobalPaths.CREDITS_SCROLL_GRABBER))
	scroll_container.get_child(0).set("custom_styles/grabber_pressed", load(GlobalPaths.CREDITS_SCROLL_GRABBER))

	scroll_container.get_child(1).set("custom_styles/scroll", load(GlobalPaths.CREDITS_SCROLL))
	scroll_container.get_child(1).set("custom_styles/scroll_focus", load(GlobalPaths.CREDITS_SCROLL))
	scroll_container.get_child(1).set("custom_styles/grabber", load(GlobalPaths.CREDITS_SCROLL_GRABBER))
	scroll_container.get_child(1).set("custom_styles/grabber_highlight", load(GlobalPaths.CREDITS_SCROLL_GRABBER))
	scroll_container.get_child(1).set("custom_styles/grabber_pressed", load(GlobalPaths.CREDITS_SCROLL_GRABBER))

	ability.focus_neighbour_right = ability_2.get_path()
	walk_left.focus_neighbour_right = walk_left_2.get_path()
	walk_right.focus_neighbour_right = walk_right_2.get_path()
	move_down.focus_neighbour_right = move_down_2.get_path()
	jump.focus_neighbour_right = jump_2.get_path()
	sprint.focus_neighbour_right = sprint_2.get_path()
	interact.focus_neighbour_right = interact_2.get_path()
	inventory.focus_neighbour_right = inventory_2.get_path()
	fire.focus_neighbour_right = fire_2.get_path()
	equip.focus_neighbour_right = equip_2.get_path()
	powerup.focus_neighbour_right = powerup_2.get_path()

	ability_2.focus_neighbour_left = ability.get_path()
	walk_left_2.focus_neighbour_left = walk_left.get_path()
	walk_right_2.focus_neighbour_left = walk_right.get_path()
	move_down_2.focus_neighbour_left = move_down.get_path()
	jump_2.focus_neighbour_left = jump.get_path()
	sprint_2.focus_neighbour_left = sprint.get_path()
	interact_2.focus_neighbour_left = interact.get_path()
	inventory_2.focus_neighbour_left = inventory.get_path()
	fire_2.focus_neighbour_left = fire.get_path()
	equip_2.focus_neighbour_left = equip.get_path()
	powerup_2.focus_neighbour_left = powerup.get_path()

	powerup.focus_neighbour_bottom = powerup.get_path()
	powerup_2.focus_neighbour_bottom = powerup_2.get_path()
	var res_button_top = $Panel/BG/ScrollContainer/Collumns/Reset/Ability
	var res_button_bottom = $Panel/BG/ScrollContainer/Collumns/Reset/Powerup
	res_button_top.focus_neighbour_top = return_button.get_path()
	res_button_bottom.focus_neighbour_bottom = res_button_bottom.get_path()

	var last_button = powerup
	var last_button_2 = powerup_2
	var first_button = ability
	var first_button_2 = ability_2


	var idx: int = 0
	for button in assignments_1.get_children():
		if button is Button:
			if not button == last_button and not button == last_button_2:
				button.focus_neighbour_bottom = assignments_1.get_child(idx + 1).get_path()
			if not button == first_button and not button == first_button_2:
				button.focus_neighbour_top = assignments_1.get_child(idx - 1).get_path()
		idx += 1

	var idx_2: int = 0
	for button in assignments_2.get_children():
		if button is Button:
			if not button == last_button and not button == last_button_2:
				button.focus_neighbour_bottom = assignments_2.get_child(idx_2 + 1).get_path()
			if not button == first_button and not button == first_button_2:
				button.focus_neighbour_top = assignments_2.get_child(idx_2 - 1).get_path()
		idx_2 += 1

	var res_buttons = $Panel/BG/ScrollContainer/Collumns/Reset
	var idx_3: int = 0

	for button in res_buttons.get_children():
		if button is Button:
			if not button == res_button_bottom:
				button.focus_neighbour_bottom = res_buttons.get_child(idx_3 + 1).get_path()
			if not button == res_button_top:
				button.focus_neighbour_top = res_buttons.get_child(idx_3 - 1).get_path()
		idx_3 += 1

	for button in res_buttons.get_children():
		if button is Button:
			button.focus_neighbour_right = button.get_path()

	yield(get_tree(), "physics_frame")
	yield(get_tree(), "physics_frame")
	update_button_map_and_texts()

	rect_position = Vector2(999, 999)


func _physics_process(_delta: float) -> void:
	if Input.is_action_pressed("ui_up") and scroll_container.scroll_vertical <= 70:
		scroll_container.scroll_vertical = 0


func _input(event: InputEvent) -> void:
	if listening and not event is InputEventKey:
		if event.is_action_pressed("ui_cancel"):
			GlobalEvents.emit_signal("ui_button_pressed", true)
			cancel_listening_event()
			get_tree().set_input_as_handled()
	elif listening and event is InputEventKey:
		if event.scancode == KEY_ESCAPE:
			GlobalEvents.emit_signal("ui_button_pressed", true)
			cancel_listening_event()
			get_tree().set_input_as_handled()
		else:
			GlobalEvents.emit_signal("ui_button_pressed")
			listening = false
			var simulated_action := InputEventKey.new()
			if listening_secondary:
				if not get_settings_controls_2()[listening_action] == null:
					simulated_action.scancode = get_settings_controls_2()[listening_action]
					InputMap.action_erase_event(listening_action, simulated_action)
				InputMap.action_erase_event(listening_action, simulated_action)
				get_settings_controls_2()[listening_action] = event.scancode
				update_button_map_and_texts()
				get_tree().set_input_as_handled()
			else:
				if not get_settings_controls()[listening_action] == null:
					simulated_action.scancode = get_settings_controls()[listening_action]
					InputMap.action_erase_event(listening_action, simulated_action)
				get_settings_controls()[listening_action] = event.scancode
				update_button_map_and_texts()
				get_tree().set_input_as_handled()

		save_settings()
		get_tree().set_input_as_handled()

	elif Input.is_action_pressed("ui_cancel") and GlobalUI.menu == GlobalUI.Menus.SETTINGS_CONTROLS_CUSTOMIZE and not GlobalUI.menu_locked and not listening:
		_return_pressed()
		get_tree().set_input_as_handled()


func cancel_listening_event() -> void:
	var artificial_input := InputEventKey.new()

	if listening_secondary:
		if not get_settings_controls_2()[listening_action] == null:
			artificial_input.scancode = get_settings_controls_2()[listening_action]
			InputMap.action_erase_event(listening_action, artificial_input)
			get_settings_controls_2()[listening_action] = null
		listening = false
		update_button_map_and_texts()
	else:
		if not get_settings_controls()[listening_action] == null:
			artificial_input.scancode = get_settings_controls()[listening_action]
			InputMap.action_erase_event(listening_action, artificial_input)
			get_settings_controls()[listening_action] = null

		listening = false
		update_button_map_and_texts()

	save_settings()


func start_change_key(action: String, secondary := false) -> void:
	listening_action = action
	listening_secondary = secondary

	listening = true

	if secondary:
		assignments_2.get_node(action.capitalize()).text = "..."
	else:
		assignments_1.get_node(action.capitalize()).text = "..."


func reset_keybind(action: String) -> void:
	var simulated_action: InputEventKey

	# Erase keybinds if exist
	if not action == "fire":
		if not get_settings_controls()[action] == null:
			simulated_action = InputEventKey.new()
			simulated_action.scancode = get_settings_controls()[action]
			InputMap.action_erase_event(action, simulated_action)

	if not get_settings_controls_2()[action] == null:
		simulated_action = InputEventKey.new()
		simulated_action.scancode = get_settings_controls_2()[action]
		InputMap.action_erase_event(action, simulated_action)

	# Add default keybind if exists
	if not action == "fire":
		simulated_action = InputEventKey.new()
		simulated_action.scancode = get_node(GlobalPaths.SETTINGS).DEFAULT_DATA["controls"][action]
		get_settings_controls()[action] = simulated_action.scancode

	if not get_node(GlobalPaths.SETTINGS).DEFAULT_DATA["controls_2"][action] == null:
		var simulated_action_2 := InputEventKey.new()
		simulated_action_2.scancode = get_node(GlobalPaths.SETTINGS).DEFAULT_DATA["controls_2"][action]
		get_settings_controls_2()[action] = simulated_action_2.scancode
	else:
		get_settings_controls_2()[action] = null

	update_button_map_and_texts()
	save_settings()


func update_button_map_and_texts() -> void:
	for key in get_settings_controls().keys():
		var value = get_settings_controls()[key]
		if key == "fire":
			assignments_1.get_node(key.capitalize()).text = tr("controls.left_click")
			continue

		if not value == null:
			var simulated_action := InputEventKey.new()

			simulated_action.scancode = value
			InputMap.action_add_event(key, simulated_action)

			assignments_1.get_node(key.capitalize()).text = OS.get_scancode_string(value)


		else:
			assignments_1.get_node(key.capitalize()).text = tr("controls.unassigned")

	for key in get_settings_controls_2().keys():
		var value = get_settings_controls_2()[key]

		if not value == null:
			var event := InputEventKey.new()

			event.scancode = value
			InputMap.action_add_event(key, event)

			assignments_2.get_node(key.capitalize()).text = OS.get_scancode_string(value)
		else:
			assignments_2.get_node(key.capitalize()).text = tr("controls.unassigned")


func update_settings(new_value: int) -> void:
	if listening_secondary:
		get_settings_controls_2()[listening_action] = new_value
	else:
		get_settings_controls()[listening_action] = new_value


func save_settings() -> void:
	get_node(GlobalPaths.SETTINGS).save_settings()


func get_settings_controls() -> Dictionary:
	return get_node(GlobalPaths.SETTINGS).data["controls"]


func get_settings_controls_2() -> Dictionary:
	return get_node(GlobalPaths.SETTINGS).data["controls_2"]


func show_menu() -> void:
	rect_position = Vector2(0, 0)
	return_button.set_focus_mode(true)
	return_button.grab_focus()
	show()
	enable_buttons()
	update_button_map_and_texts()
	anim_player.play("show")
	assignments_1.get_node("Label").text = "%s 1" % tr("controls.assignments")
	assignments_2.get_node("Label").text = "%s 2" % tr("controls.assignments")


func hide_menu() -> void:
	return_button.set_focus_mode(false)
	disable_buttons()
	anim_player.play_backwards("show")
	yield(anim_player, "animation_finished")
	if not GlobalUI.menu == GlobalUI.Menus.SETTINGS_CONTROLS_CUSTOMIZE:
		$BGBlur.hide()
		hide()
		rect_position = Vector2(999, 999)


func disable_buttons() -> void:
	return_button.disabled = true


func enable_buttons() -> void:
	return_button.disabled = false


func _ui_settings_controls_customize_pressed() -> void:
	show_menu()


# Forget old controls in InputMap before the new ones are applied
func _ui_settings_reset_settings_prompt_yes_pressed() -> void:
	for action in get_settings_controls().keys():
		if not get_settings_controls()[action] == null:
			var simulated_action := InputEventKey.new()
			simulated_action.scancode = get_settings_controls()[action]
			InputMap.action_erase_event(action, simulated_action)

	for action in get_settings_controls_2().keys():
		if not get_settings_controls_2()[action] == null:
			var simulated_action := InputEventKey.new()
			simulated_action.scancode = get_settings_controls_2()[action]
			InputMap.action_erase_event(action, simulated_action)


func _return_pressed() -> void:
	if listening:
		cancel_listening_event()
	GlobalEvents.emit_signal("ui_button_pressed", true)
	GlobalEvents.emit_signal("ui_settings_controls_customize_back_pressed")
	GlobalUI.menu = GlobalUI.Menus.SETTINGS_CONTROLS
	hide_menu()


func _on_Ability_pressed() -> void:
	GlobalEvents.emit_signal("ui_button_pressed")
	start_change_key("ability")


func _on_Move_Left_pressed() -> void:
	GlobalEvents.emit_signal("ui_button_pressed")
	start_change_key("move_left")


func _on_Move_Right_pressed() -> void:
	GlobalEvents.emit_signal("ui_button_pressed")
	start_change_key("move_right")


func _on_Move_Down_pressed() -> void:
	GlobalEvents.emit_signal("ui_button_pressed")
	start_change_key("move_down")


func _on_Move_Jump_pressed() -> void:
	GlobalEvents.emit_signal("ui_button_pressed")
	start_change_key("move_jump")


func _on_Move_Sprint_pressed() -> void:
	GlobalEvents.emit_signal("ui_button_pressed")
	start_change_key("move_sprint")


func _on_Interact_pressed() -> void:
	GlobalEvents.emit_signal("ui_button_pressed")
	start_change_key("interact")


func _on_Inventory_pressed() -> void:
	GlobalEvents.emit_signal("ui_button_pressed")
	start_change_key("inventory")


func _on_Fire_pressed() -> void:
	GlobalEvents.emit_signal("ui_button_pressed")
	start_change_key("fire")


func _on_Equip_pressed() -> void:
	GlobalEvents.emit_signal("ui_button_pressed")
	start_change_key("equip")


func _on_Powerup_pressed() -> void:
	GlobalEvents.emit_signal("ui_button_pressed")
	start_change_key("powerup")


func _on_Ability_2_pressed() -> void:
	GlobalEvents.emit_signal("ui_button_pressed")
	start_change_key("ability", true)


func _on_Move_Left_2_pressed() -> void:
	GlobalEvents.emit_signal("ui_button_pressed")
	start_change_key("move_left", true)


func _on_Move_Right_2_pressed() -> void:
	GlobalEvents.emit_signal("ui_button_pressed")
	start_change_key("move_right", true)


func _on_Move_Down_2_pressed() -> void:
	GlobalEvents.emit_signal("ui_button_pressed")
	start_change_key("move_down", true)


func _on_Move_Jump_2_pressed() -> void:
	GlobalEvents.emit_signal("ui_button_pressed")
	start_change_key("move_jump", true)


func _on_Move_Sprint_2_pressed() -> void:
	GlobalEvents.emit_signal("ui_button_pressed")
	start_change_key("move_sprint", true)


func _on_Interact_2_pressed() -> void:
	GlobalEvents.emit_signal("ui_button_pressed")
	start_change_key("interact", true)


func _on_Inventory_2_pressed() -> void:
	GlobalEvents.emit_signal("ui_button_pressed")
	start_change_key("inventory", true)


func _on_Fire_2_pressed() -> void:
	GlobalEvents.emit_signal("ui_button_pressed")
	start_change_key("fire", true)


func _on_Equip_2_pressed() -> void:
	GlobalEvents.emit_signal("ui_button_pressed")
	start_change_key("equip", true)


func _on_Powerup_2_pressed() -> void:
	GlobalEvents.emit_signal("ui_button_pressed")
	start_change_key("powerup", true)


func _on_Ability_Reset_pressed() -> void:
	GlobalEvents.emit_signal("ui_button_pressed")
	reset_keybind("ability")


func _on_Move_Left_Reset_pressed() -> void:
	GlobalEvents.emit_signal("ui_button_pressed")
	reset_keybind("move_left")


func _on_Move_Right_Reset_pressed() -> void:
	GlobalEvents.emit_signal("ui_button_pressed")
	reset_keybind("move_right")


func _on_Move_Down_Reset_pressed() -> void:
	GlobalEvents.emit_signal("ui_button_pressed")
	reset_keybind("move_down")


func _on_Move_Jump_Reset_pressed() -> void:
	GlobalEvents.emit_signal("ui_button_pressed")
	reset_keybind("move_jump")


func _on_Move_Sprint_Reset_pressed() -> void:
	GlobalEvents.emit_signal("ui_button_pressed")
	reset_keybind("move_sprint")


func _on_Interact_Reset_pressed() -> void:
	GlobalEvents.emit_signal("ui_button_pressed")
	reset_keybind("interact")


func _on_Inventory_Reset_pressed() -> void:
	GlobalEvents.emit_signal("ui_button_pressed")
	reset_keybind("inventory")


func _on_Fire_Reset_pressed() -> void:
	GlobalEvents.emit_signal("ui_button_pressed")
	reset_keybind("fire")


func _on_Equip_Reset_pressed() -> void:
	GlobalEvents.emit_signal("ui_button_pressed")
	reset_keybind("equip")


func _on_Powerup_Reset_pressed() -> void:
	GlobalEvents.emit_signal("ui_button_pressed")
	reset_keybind("powerup")


func _button_hovered() -> void:
	GlobalEvents.emit_signal("ui_button_hovered")
