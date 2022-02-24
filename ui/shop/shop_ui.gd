extends Control

var loaded_shop: Dictionary
# Used for saving
var bought_something: bool = false

var prev_focus: Button

onready var items_vbox: VBoxContainer = $Panel/BG/Items
onready var prices_vbox: VBoxContainer = $Panel/BG/Price
onready var anim_player: AnimationPlayer = $AnimationPlayer
onready var back_button: Button = $Panel/Back
onready var required_label: Label = $Panel/RequiredLabel
onready var you_have_label: Label = $Panel/YouHaveLabel
onready var shop_label: Label = $Panel/Title
onready var bought_item_anim_player: AnimationPlayer = $BoughtItem/Label/Sprite/AnimationPlayer
onready var bought_item_sprite: Sprite = $BoughtItem/Label/Sprite


func _ready() -> void:
	var __: int
	__ = GlobalEvents.connect("ui_shop_opened", self, "_ui_shop_opened")

	hide()
	pause_mode = PAUSE_MODE_PROCESS

	for button in items_vbox.get_children():
		button.connect("pressed", self, "_button_pressed")


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and GlobalUI.menu == GlobalUI.Menus.SHOP:
		_on_Back_pressed()
		get_tree().set_input_as_handled()


func show_menu() -> void:
	get_tree().paused = true
	GlobalUI.menu = GlobalUI.Menus.SHOP
	show()
	enable_buttons()
	anim_player.play("show")
	back_button.grab_focus()
	bought_something = false


func hide_menu() -> void:
	prev_focus = null
	get_tree().paused = false
	GlobalUI.menu = GlobalUI.Menus.NONE
	GlobalEvents.emit_signal("ui_shop_closed")
	anim_player.play_backwards("show")
	back_button.release_focus()
	for button in items_vbox.get_children():
		if button.has_focus():
			button.release_focus()
	disable_buttons()
	if bought_something:
		GlobalEvents.emit_signal("save_file_saved")
		bought_something = false


func disable_buttons(exclude_back: bool = false) -> void:
	if not exclude_back:
		back_button.disabled = true
	for button in items_vbox.get_children():
		button.disabled = true


func enable_buttons() -> void:
	back_button.disabled = false

	for button in items_vbox.get_children():
		button.disabled = false

		var btn_name: String = button.name.to_lower()
		if btn_name in GlobalStats.VALID_EQUIPPABLES:
			if GlobalSave.has_item(GlobalSave.get_stat("equippables"), btn_name):
				button.disabled = true
				if not "ACQUIRED" in button.text:
					button.text += " | ACQUIRED"


func _ui_shop_opened(items: Dictionary) -> void:
	yield(get_tree(), "idle_frame")
	if get_tree().paused: return
	GlobalUI.menu_locked = true
	GlobalEvents.emit_signal("ui_button_pressed")
	show_menu()
	update_shop(items)
	GlobalUI.menu_locked = false


func update_shop(items: Dictionary) -> void:
	shop_label.text = "Shop"
	shop_label.self_modulate = Color8(255, 255, 255, 255)

	for button in $Panel/BG/Items.get_children():
		if button.has_focus():
			prev_focus = button

	for button in items_vbox.get_children():
		button.hide()
	for label in prices_vbox.get_children():
		label.hide()


	for item in items:
		if item == "gems": continue

		items_vbox.get_node(item.capitalize()).show()
		prices_vbox.get_node(item.capitalize()).show()
		prices_vbox.get_node(item.capitalize()).self_modulate = Color8(255, 255, 255, 255)
		items_vbox.get_node(item.capitalize()).disabled = false

		if items[item][1] == 0 or items[item][0] == false:
			items_vbox.get_node(item.capitalize()).hide()
			prices_vbox.get_node(item.capitalize()).hide()
			continue

		var string: String

		if item in GlobalStats.VALID_POWERUPS or item in GlobalStats.VALID_COLLECTABLES or item in GlobalStats.VALID_EQUIPPABLES:
			string = tr(GlobalStats.COMMON_NAMES[item.capitalize()])
#		elif item in GlobalStats.VALID_COLLECTABLES:
#			string = tr(GlobalStats.COLLECTABLE_NAMES[item.capitalize()])
#		elif item in GlobalStats.VALID_EQUIPPABLES:
#			string = tr(GlobalStats.EQUIPPABLE_NAMES[item.capitalize()])
		else:
			string = tr(GlobalStats.SHOP_NAMES[item.capitalize()])

		if item in GlobalStats.VALID_EQUIPPABLES:
			items_vbox.get_node(item.capitalize()).text = "%s" % [string]
			if GlobalSave.has_item(GlobalSave.get_stat("equippables"), item):
				items_vbox.get_node(item.capitalize()).disabled = true
				items_vbox.get_node(item.capitalize()).text += " | ACQUIRED"
		else:
			items_vbox.get_node(item.capitalize()).text = "%s x%s" % [string, items[item][1]]

		prices_vbox.get_node(item.capitalize()).text = "      x%s" % [items[item][2]]

		if int(GlobalSave.get_stat("coins")) < items[item][2]:
			items_vbox.get_node(item.capitalize()).disabled = true
			prices_vbox.get_node(item.capitalize()).self_modulate = Color8(220, 25, 25, 255)

		if not prev_focus == null:
			prev_focus.grab_focus()

#	# Button focuses
#
#	var button_count: int = items_vbox.get_children().size()
#	var top_button: Button
#	var bottom_button: Button
#
#	#loop through hidden buttons to get button count
#	for item in items_vbox.get_children():
#		if not item.visible:
#			button_count -= 1
#
#	for item in items_vbox.get_children():
#		if item.visible:
#			top_button = item
#			continue
#
#	# find bottom button
#	var idx: int = 0
#	for item in items_vbox.get_children():
#		if item.visible:
#			idx += 1
#			if idx == button_count:
#				bottom_button = item
#				continue
#
#	print(button_count)
#
#	bottom_button.focus_neighbour_bottom = back_button.get_path()
#	back_button.focus_neighbour_top = bottom_button.get_path()
#	top_button.focus_neighbour_top = top_button.get_path()
	loaded_shop = items

	# Gems
	you_have_label.text = "Required: %s gems" % items["gems"]
	required_label.text = "You have: %s gems" % GlobalSave.get_gem_count()

	if GlobalSave.get_gem_count() >= items["gems"]:
		you_have_label.self_modulate = Color8(40, 255, 60, 255)
	else:
		# Shop closed
		you_have_label.self_modulate = Color8(220, 25, 25, 255)
		shop_label.text = "Shop - CLOSED"
		shop_label.self_modulate = Color8(220, 25, 25, 255)
		for item in items:
			if item == "gems": continue
			items_vbox.get_node(item.capitalize()).disabled = true
			prices_vbox.get_node(item.capitalize()).self_modulate = Color8(220, 25, 25, 255)
		return


func _button_pressed() -> void:
	var target_button: Button

	bought_something = true

	$BuySound.play()


	for button in items_vbox.get_children():
		if button.has_focus():
			#We want this button, this was the one clicked
			target_button = button

	var item: String = target_button.name
	item = item.to_lower()

	if item in GlobalStats.VALID_POWERUPS:
		var item_str = item.replace(" ", "_")
		bought_item_sprite.texture = load("res://world_all/powerups/%s.png" % item_str)
	elif item in GlobalStats.VALID_COLLECTABLES:
		var item_str = item.replace(" ", "_")
		bought_item_sprite.texture = load("res://world_all/collectables/%s.png" % item_str)
	elif item in GlobalStats.VALID_EQUIPPABLES:
		var item_str = item.replace(" ", "_")
		bought_item_sprite.texture = load("res://world_all/equippables/%s.png" % item_str)
	elif item == "orbs":
		bought_item_sprite.texture = load("res://world_all/orbs/orb.png")
	bought_item_anim_player.play("show")


	if item in GlobalStats.VALID_POWERUPS:
		for i in loaded_shop[item][1]:
			GlobalEvents.emit_signal("player_collected_powerup", item)
	elif item in GlobalStats.VALID_COLLECTABLES:
		for i in loaded_shop[item][1]:
			GlobalEvents.emit_signal("player_collected_collectable", item)
	elif item in GlobalStats.VALID_EQUIPPABLES:
		GlobalEvents.emit_signal("player_collected_equippable", item)
		GlobalSave.set_stat("equipped_item", item)
	elif item == "orbs":
		GlobalEvents.emit_signal("player_collected_orb", loaded_shop[item][1])


	disable_buttons(true)
	yield(get_tree(), "physics_frame")
	GlobalSave.set_stat("coins", GlobalSave.get_stat("coins") - loaded_shop[item][2])
	yield(get_tree(), "physics_frame")
	#update_shop(loaded_shop)


func _on_Back_pressed() -> void:
	hide_menu()
	GlobalEvents.emit_signal("ui_button_pressed", true)


func _on_AnimationPlayer_animation_finished(_anim_name: String) -> void:
	if GlobalUI.menu == GlobalUI.Menus.SHOP:
		enable_buttons()
		update_shop(loaded_shop)
		#print(prev_focus)
		if not prev_focus == null:
			prev_focus.grab_focus()
