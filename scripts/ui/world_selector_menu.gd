extends Control

var world = 1
var level = 1

# How many levels are in each world
var level_database = [2, 2, 2, 1]

onready var add_world_button: Button = $Panel/VBoxContainer/HBoxContainer/AddWorld
onready var remove_world_button: Button = $Panel/VBoxContainer/HBoxContainer/RemoveWorld
onready var add_level_button: Button= $Panel/VBoxContainer/HBoxContainer/AddLevel
onready var remove_level_button: Button = $Panel/VBoxContainer/HBoxContainer/RemoveLevel
onready var go_to_level_button: Button = $Panel/VBoxContainer/HBoxContainer2/GoToLevel
onready var back_button: Button = $Panel/VBoxContainer/HBoxContainer2/Back
onready var selected_level_label: Label = $Panel/VBoxContainer/SelectedLevelLabel
onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	hide()
	add_world_button.connect("pressed", self, "_on_add_world_pressed")
	remove_world_button.connect("pressed", self, "_on_remove_world_pressed")
	add_level_button.connect("pressed" , self, "_on_add_level_pressed")
	remove_level_button.connect("pressed", self, "_on_remove_level_pressed")
	go_to_level_button.connect("pressed", self, "_on_go_to_level_pressed")
	back_button.connect("pressed", self, "on_back_pressed")

	update()


func update() -> void:
	selected_level_label.text = "Selected Level: %s - %s" % [world, level]

	add_world_button.disabled = world >= level_database.size()
	add_level_button.disabled = level >= level_database[world - 1]

	remove_world_button.disabled = world <= 1
	remove_level_button.disabled = level <= 1


func _on_add_world_pressed() -> void:
	Signals.emit_signal("ui_button_pressed", false)
	world += 1
	level = 1
	update()


func _on_remove_world_pressed() -> void:
	Signals.emit_signal("ui_button_pressed", false)
	world -= 1
	level = 1
	update()


func _on_add_level_pressed() -> void:
	Signals.emit_signal("ui_button_pressed", false)
	level += 1
	update()


func on_back_pressed() -> void:
	Signals.emit_signal("ui_button_pressed", true)
	Signals.emit_signal("ui_world_selector_back_pressed")


func _on_remove_level_pressed() -> void:
	Signals.emit_signal("ui_button_pressed", false)
	level -= 1
	update()


func _on_go_to_level_pressed() -> void:
	#Signals.emit_signal("ui_button_pressed", false)
	LevelController.current_world = world
	LevelController.current_level = level
#	PlayerStats.data.world = world
#	PlayerStats.data.level = level
	PlayerStats.save_stats()
	Signals.emit_signal("level_change_attempted", LevelController.current_world, LevelController.current_level)


func show_menu() -> void:
	add_world_button.disabled = false
	add_level_button.disabled = false
	remove_world_button.disabled = false
	remove_level_button.disabled = false
	go_to_level_button.disabled = false
	back_button.disabled = false
	animation_player.play("show")
	show()
	add_world_button.grab_focus()
	world = 1
	level = 1
	update()


func hide_menu() -> void:
	Signals.emit_signal("ui_button_pressed")
	animation_player.play_backwards("show")
	disable_buttons()
	if Globals.in_menu:
		Globals.current_menu = Globals.MenuTypes.MAIN_MENU
	else:
		Globals.current_menu = Globals.MenuTypes.PAUSE_MENU


func disable_buttons():
	add_world_button.disabled = true
	add_level_button.disabled = true
	remove_world_button.disabled = true
	remove_level_button.disabled = true
	go_to_level_button.disabled = true
	back_button.disabled = true



func _ui_world_selector_pressed() -> void:
	pass


func _ui_world_selector_back_pressed() -> void:
	hide_menu()
