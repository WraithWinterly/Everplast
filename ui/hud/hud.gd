extends Control

var previous_item: String = "none"
var toggled: bool = true

onready var coin_label: Label = $VBoxContainer/HBoxContainer/CoinLabel
onready var health_amount: Label = $VBoxContainer/HBoxContainer/HealthLabel
onready var orb_label: Label = $VBoxContainer/HBoxContainer/OrbLabel
onready var adrenaline_texture: TextureRect = $VBoxContainer/HBoxContainer/AdrenalineTexture
onready var adrenaline_label: Label = $VBoxContainer/HBoxContainer/AdrenalineLabel
onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var ui_slot: TextureRect = $VBoxContainer/UISlot
onready var ui_slot_label: Label = $VBoxContainer/UISlot/Label
onready var ui_slot_texture: TextureRect = $VBoxContainer/UISlot/TextureRect
onready var gem_textures := [$GenContainer/GemSlot1/Gem, $GenContainer/GemSlot2/Gem, $GenContainer/GemSlot3/Gem]
onready var gem_container: HBoxContainer = $GenContainer


func _ready() -> void:
	var __: int
	__ = UI.connect("changed", self, "_ui_changed")
	__ = PlayerStats.connect("stat_updated", self, "update_counters")
	__ = Signals.connect("level_completed", self, "_level_completed")
	__ = Signals.connect("level_changed", self, "_level_changed")
	__ = Signals.connect("coin_collected", self, "update_coin_counter")
	__ = Signals.connect("orb_collected", self, "update_orb_counter")
	__ = Signals.connect("player_death", self, "_player_death")
	__ = Signals.connect("player_hurt_from_enemy", self, "_player_hurt_from_enemy")
	__ = Signals.connect("adrenaline_updated", self, "update_counters")
	__ = Signals.connect("powerup_used", self, "_powerup_used")
	__ = Signals.connect("inventory_changed", self, "_inventory_changed")
	__ = Signals.connect("gem_collected", self, "_gem_collected")
	hide()
	for gem in gem_textures:
		gem.hide()


func show_hud() -> void:
	animation_player.play("show")
	show()


func hide_hud() -> void:
	animation_player.play_backwards("show")


func update_visibility() -> void:
	yield(get_tree(), "physics_frame")
	if not Globals.game_state == Globals.GameStates.LEVEL:
		hide_hud()


func update_counters() -> void:
	if Globals.game_state == Globals.GameStates.MENU:
		return

	update_coin_counter()
	update_orb_counter()
	update_health_counter()
	update_adrenaline_counter()
	update_visibility()

	if PlayerStats.get_stat("adrenaline") <= 0:
		adrenaline_label.modulate = Color8(220, 25, 25)
	elif PlayerStats.get_stat("adrenaline") >= PlayerStats.get_stat("adrenaline_max"):
		adrenaline_label.modulate = Color8(40, 255, 60)
	else:
		adrenaline_label.modulate = Color8(255, 255, 255)

	ui_slot.visible = not PlayerStats.get_stat("equipped_item") == "none"

	if ui_slot.visible:
		if not PlayerStats.get_stat("equipped_item") == previous_item:
			ui_slot_texture.texture = load(FileLocations.get_bullet_texture())
		var worker: String = PlayerStats.get_ammo()
		var inv: Array = PlayerStats.get_stat("collectables")
		if PlayerStats.has(inv, worker):
			for array in inv:
				if array[0] == worker:
					ui_slot_label.text = "x%s" % array[1]
					ui_slot_label.modulate = Color8(255, 255, 255)
					return
		else:
			ui_slot_label.text = "x0"
			ui_slot_label.modulate = Color8(220, 25, 25)

	if Globals.game_state == Globals.GameStates.LEVEL:
		gem_container.show()
		var index: int = 0
		var gem_dict = PlayerStats.get_stat("gems")
		for gem in gem_textures:
			if gem_dict.has(str(LevelController.current_world)):
				if gem_dict[str(LevelController.current_world)].has(str(LevelController.current_level)):
					if gem_dict[str(LevelController.current_world)][str(LevelController.current_level)][index]:
						if not gem.visible:
							gem.show()
							gem.get_node("AnimationPlayer").play("show")
					else:
						gem.hide()
				else:
					gem.hide()
			else:
				gem.hide()
			index += 1
	else:
		gem_container.hide()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_hud") and Globals.game_state == Globals.GameStates.LEVEL:
		if toggled:
			animation_player.stop()
			hide_hud()
			toggled = false
		else:
			animation_player.stop()
			show_hud()
			toggled = true


func update_coin_counter(_amount: int = 0) -> void:
	coin_label.text = str(PlayerStats.get_stat("coins"))


func update_orb_counter(_amount: int = 0) -> void:
	orb_label.text = str(PlayerStats.get_stat("orbs"))


func update_health_counter() -> void:
	health_amount.text = "%s | %s " % [
			PlayerStats.get_stat("health"), PlayerStats.get_stat("health_max")]


func update_adrenaline_counter() -> void:
	var is_visibe: bool = PlayerStats.get_stat("rank") >= PlayerStats.Ranks.GOLD
	adrenaline_label.visible = is_visibe
	adrenaline_texture.visible = is_visibe
	adrenaline_label.text = "%s | %s" % [
			PlayerStats.get_stat("adrenaline"), PlayerStats.get_stat("adrenaline_max")]


func _inventory_changed(is_open: bool) -> void:
	if Globals.game_state == Globals.GameStates.WORLD_SELECTOR:
		if is_open:
			show_hud()
		else:
			hide_hud()


func _ui_changed(menu: int) -> void:
	match menu:
		UI.NONE:
			if UI.last_menu == UI.PAUSE_MENU_RETURN_PROMPT:
				yield(UI, "faded")
				hide()
		UI.MAIN_MENU:
			if UI.last_menu == UI.PAUSE_MENU_RETURN_PROMPT:
				yield(UI, "faded")
				hide()


func _level_changed(_world: int, _level: int) -> void:
	hide()
	yield(UI, "faded")
	#update_visibility()
	update_counters()
	yield(UI, "faded")
	yield(get_tree(), "physics_frame")
	update_counters()
	show_hud()
	toggled = true


func _level_completed() -> void:
	update_counters()
	#yield(UI, "faded")
	hide_hud()


func _player_death() -> void:
	hide_hud()
	yield(UI, "faded")
	update_counters()


func _powerup_used(_item_name: String) -> void:
	yield(get_tree(), "physics_frame")
	update_counters()


func _player_hurt_from_enemy(var _hurt_type: int, var _knockback: int, var _damage: int) -> void:
	update_counters()


func _gem_collected(_index: int) -> void:
	update_counters()
