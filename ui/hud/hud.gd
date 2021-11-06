extends Control

onready var coin_label: Label = $VBoxContainer/HBoxContainer/CoinLabel
onready var health_amount: Label = $VBoxContainer/HBoxContainer/HealthLabel
onready var orb_label: Label = $VBoxContainer/HBoxContainer/OrbLabel
onready var adrenaline_label: Label = $VBoxContainer/HBoxContainer/AdrenalineLabel
onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var ui_slot: TextureRect = $VBoxContainer/UISlot
onready var ui_slot_label: Label = $VBoxContainer/UISlot/Label
onready var ui_slot_texture: TextureRect = $VBoxContainer/UISlot/TextureRect

var previous_item: String = "none"

func _ready():
	UI.connect("changed", self, "_ui_changed")
	PlayerStats.connect("stat_updated", self, "update_counters")
	Signals.connect("level_completed", self, "_level_completed")
	Signals.connect("level_changed", self, "_level_changed")
	Signals.connect("coin_collected", self, "update_coin_counter")
	Signals.connect("orb_collected", self, "update_orb_counter")
	Signals.connect("player_death", self, "_player_death")
	Signals.connect("player_hurt_from_enemy", self, "_player_hurt_from_enemy")
	Signals.connect("adrenaline_updated", self, "update_counters")
	Signals.connect("quick_item_used", self, "_quick_item_used")
	Signals.connect("inventory_changed", self, "_inventory_changed")
	hide()


func show_hud() -> void:
	animation_player.play("show")
	show()


func hide_hud() -> void:
	animation_player.play_backwards("show")
	yield(animation_player, "animation_finished")
	if not animation_player.is_playing():
		hide()


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


func update_coin_counter(amount: int = 0) -> void:
	coin_label.text = str(PlayerStats.get_stat("coins"))


func update_orb_counter(amount: int = 0) -> void:
	orb_label.text = str(PlayerStats.get_stat("orbs"))


func update_health_counter() -> void:
	health_amount.text = "%s | %s " % [
			PlayerStats.get_stat("health"), PlayerStats.get_stat("health_max")]


func update_adrenaline_counter() -> void:
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


func _level_changed(world: int, level: int) -> void:
	hide()
	yield(UI, "faded")
	#update_visibility()
	update_counters()
	yield(UI, "faded")
	yield(get_tree(), "physics_frame")
	show_hud()


func _level_completed() -> void:
	update_counters()
	#yield(UI, "faded")
	hide_hud()


func _player_death() -> void:
	update_counters()
	hide_hud()
	#update_visibility()


func _quick_item_used(item_name: String) -> void:
	yield(get_tree(), "physics_frame")
	update_counters()


func _player_hurt_from_enemy(var _hurt_type: int, var _knockback: int, var _damage: int) -> void:
	update_counters()
