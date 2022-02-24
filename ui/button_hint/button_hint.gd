extends Control

enum InputTypes {
	KB,
	CTR,
}

var last_input: int = InputTypes.KB

onready var vbox_other: VBoxContainer = $VBoxContainerOther
onready var vbox_kb: VBoxContainer = $VBoxContainerKB
onready var vbox_ps4: VBoxContainer = $VBoxContainerPS4

onready var inv_label_kb: Label = $VBoxContainerKB/Inventory/Label
onready var sprint_label_kb: Label = $VBoxContainerKB/Sprint/Label
onready var powerup_label_kb: Label = $VBoxContainerKB/Powerup/Label
onready var equip_label_kb: Label = $VBoxContainerKB/Equip/Label
onready var interact_label_kb: Label = $VBoxContainerKB/Interact/Label
onready var dash_label_kb: Label = $VBoxContainerKB/Dash/Label
onready var fire_label_kb: Label = $VBoxContainerKB/Fire/Label
onready var inv_kb: TextureRect = $VBoxContainerKB/Inventory
onready var sprint_kb: TextureRect = $VBoxContainerKB/Sprint
onready var powerup_kb: TextureRect = $VBoxContainerKB/Powerup
onready var equip_kb: TextureRect = $VBoxContainerKB/Equip
onready var interact_kb: TextureRect = $VBoxContainerKB/Interact
onready var dash_kb: TextureRect = $VBoxContainerKB/Dash
onready var fire_kb: TextureRect = $VBoxContainerKB/Fire

onready var inv_ps4: TextureRect = $VBoxContainerPS4/Inventory
onready var sprint_ps4: TextureRect = $VBoxContainerPS4/Sprint
onready var powerup_ps4: TextureRect = $VBoxContainerPS4/Powerup
onready var equip_ps4: TextureRect = $VBoxContainerPS4/Equip
onready var interact_ps4: TextureRect = $VBoxContainerPS4/Interact
onready var dash_ps4: TextureRect = $VBoxContainerPS4/Dash
onready var fire_ps4: TextureRect = $VBoxContainerPS4/Fire

onready var inv_other: TextureRect = $VBoxContainerOther/Inventory
onready var sprint_other: TextureRect = $VBoxContainerOther/Sprint
onready var powerup_other: TextureRect = $VBoxContainerOther/Powerup
onready var equip_other: TextureRect = $VBoxContainerOther/Equip
onready var interact_other: TextureRect = $VBoxContainerOther/Interact
onready var dash_other: TextureRect = $VBoxContainerOther/Dash
onready var fire_other: TextureRect = $VBoxContainerOther/Fire


func _input(event: InputEvent) -> void:
	if event is InputEventJoypadMotion:
		if abs(GlobalInput.get_action_strength_controller()) > 0.5:
			last_input = InputTypes.CTR
	elif event is InputEventJoypadButton:
		last_input = InputTypes.CTR
	elif event is InputEventMouseButton:
		last_input = InputTypes.KB
	elif event is InputEventKey:
		last_input = InputTypes.KB


func _physics_process(_delta: float) -> void:
	visible = (not Globals.game_state == Globals.GameStates.MENU) and (get_node(GlobalPaths.SETTINGS).data.button_hint) and not GlobalUI.menu_locked

	if not visible: return

	match last_input:
		InputTypes.CTR:
			var joy_name: String = Input.get_joy_name(get_node(GlobalPaths.SETTINGS).data.controller_index)
			if joy_name == "PS4 Controller":
				vbox_kb.hide()
				vbox_other.hide()
				vbox_ps4.show()
			else:
				vbox_ps4.hide()
				vbox_kb.hide()
				vbox_other.show()

			powerup_other.visible = GlobalInput.powerup_activated
			powerup_ps4.visible = GlobalInput.powerup_activated

			equip_other.visible = GlobalInput.equip_activated
			equip_ps4.visible = GlobalInput.equip_activated

			interact_other.visible = GlobalInput.interact_activators > 0
			interact_ps4.visible = GlobalInput.interact_activators > 0

			dash_other.visible = GlobalInput.dash_activated
			dash_ps4.visible = GlobalInput.dash_activated

			fire_other.visible = GlobalInput.fire_activated
			fire_ps4.visible = GlobalInput.fire_activated

		InputTypes.KB:
			vbox_ps4.hide()
			vbox_other.hide()
			vbox_kb.show()

#			var input_event := InputEventKey.new()
#			input_event.scancode =
			inv_label_kb.text = "%s | %s" % [OS.get_scancode_string(get_settings_controls().inventory), tr("controls.inventory")]
			sprint_label_kb.text = "%s | %s" % [OS.get_scancode_string(get_settings_controls().move_sprint), tr("controls.sprint")]

			if GlobalInput.powerup_activated:
				powerup_label_kb.text = "%s | %s" % [OS.get_scancode_string(get_settings_controls().powerup), tr("controls.powerup")]
				powerup_kb.show()
			else:
				powerup_kb.hide()

			if GlobalInput.equip_activated:
				equip_label_kb.text = "%s | %s" % [OS.get_scancode_string(get_settings_controls().interact), tr("controls.equip")]
				equip_kb.show()
			else:
				equip_kb.hide()


			if GlobalInput.interact_activators > 0:
				interact_label_kb.text = "%s | %s" % [OS.get_scancode_string(get_settings_controls().interact), tr("controls.interact")]
				interact_kb.show()
			else:
				interact_kb.hide()

			if GlobalInput.dash_activated:
				dash_label_kb.text = "%s | %s" % [OS.get_scancode_string(get_settings_controls().ability), tr("controls.dash")]
				dash_kb.show()
			else:
				dash_kb.hide()

			if GlobalInput.fire_activated:
				fire_label_kb.text = "%s | %s" % [tr("controls.left_click"), tr("controls.fire")]
				fire_kb.show()
			else:
				fire_kb.hide()



func get_settings_controls() -> Dictionary:
	return get_node(GlobalPaths.SETTINGS).data["controls"]
