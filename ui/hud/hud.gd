extends Control

var previous_item: String = "none"

var toggled := true
var upgrade_notification_showed := false
var ui_slot_visible := false

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
onready var low_health_rect :TextureRect = $LowHealth
onready var ui_slot_anim_player: AnimationPlayer = $VBoxContainer/UISlot/AnimationPlayer


func _ready() -> void:
	var __: int
	__ = GlobalEvents.connect("level_changed", self, "_level_changed")
	__ = GlobalEvents.connect("level_completed", self, "_level_completed")
	__ = GlobalEvents.connect("player_died", self, "_player_died")
	__ = GlobalEvents.connect("player_level_increased", self, "_player_level_increased")
	__ = GlobalEvents.connect("player_collected_coin", self, "_player_collected_coin")
	__ = GlobalEvents.connect("player_collected_orb", self, "_player_collected_orb")
	__ = GlobalEvents.connect("player_collected_gem", self, "_player_collected_gem")
	__ = GlobalEvents.connect("player_hurt_from_enemy", self, "_player_hurt_from_enemy")
	__ = GlobalEvents.connect("player_used_powerup", self, "_player_used_powerup")
	__ = GlobalEvents.connect("save_stat_updated", self, "_save_stat_updated")
	__ = GlobalEvents.connect("ui_inventory_opened", self, "_ui_inventory_opened")
	__ = GlobalEvents.connect("ui_inventory_closed", self, "_ui_inventory_closed")
	__ = GlobalEvents.connect("ui_pause_menu_return_prompt_yes_pressed", self, "_ui_pause_menu_return_prompt_yes_pressed")

	hide()
	for gem in gem_textures:
		gem.hide()


func _physics_process(_delta: float) -> void:
	if Globals.game_state == Globals.GameStates.LEVEL:
		match int(GlobalSave.get_stat("health_max")):
			5:
				low_health_modulate(2, 1)
			10:
				low_health_modulate(3, 1)
			15:
				low_health_modulate(5, 2)
			20:
				low_health_modulate(5, 2)
			25:
				low_health_modulate(5, 2)
			_:
				low_health_modulate(10, 5)
	else:
		low_health_rect.modulate = lerp(low_health_rect.modulate, Color8(255, 255, 255, 0), 0.1)


func low_health_modulate(low_health, extreme_health) -> void:
	if Globals.game_state == Globals.GameStates.LEVEL:
		if GlobalSave.get_stat("health") <= low_health and GlobalSave.get_stat("health") > extreme_health:
			low_health_rect.modulate = lerp(low_health_rect.modulate, Color8(255, 255, 255, 70), 0.1)
		elif GlobalSave.get_stat("health") <= extreme_health:
			low_health_rect.modulate = lerp(low_health_rect.modulate, Color8(255, 255, 255, 150), 0.1)
		else:
			low_health_rect.modulate = lerp(low_health_rect.modulate, Color8(255, 255, 255, 0), 0.1)
	else:
		low_health_rect.modulate = lerp(low_health_rect.modulate, Color8(255, 255, 255, 0), 0.1)


func show_hud() -> void:
	animation_player.play("show")
	show()


func hide_hud() -> void:
	if not modulate == Color8(255, 255, 255, 0):
		animation_player.play_backwards("show")


func show_ui_slot() -> void:
	if not ui_slot_visible:
		ui_slot_anim_player.play("slide")
		ui_slot_visible = true


func hide_ui_slot() -> void:
	if ui_slot_visible:
		ui_slot_anim_player.play_backwards("slide")
		ui_slot_visible = false


func update_visibility() -> void:
	yield(get_tree(), "physics_frame")
	if not Globals.game_state == Globals.GameStates.LEVEL:
		hide_hud()


func update_counters() -> void:
	if Globals.game_state == Globals.GameStates.MENU:
		return

	update_gems()
	update_coin_counter()
	update_orb_counter()
	update_health_counter()
	update_adrenaline_counter()
	update_visibility()

	if GlobalSave.get_stat("adrenaline") <= 0:
		adrenaline_label.modulate = Color8(220, 25, 25)
	elif GlobalSave.get_stat("adrenaline") >= GlobalSave.get_stat("adrenaline_max"):
		adrenaline_label.modulate = Color8(40, 255, 60)
	else:
		adrenaline_label.modulate = Color8(255, 255, 255)

	if GlobalSave.get_stat("equipped_item") == "none":
		hide_ui_slot()
	else:
		show_ui_slot()

	if ui_slot_visible:
		if not GlobalSave.get_stat("equipped_item") == previous_item:
			ui_slot_texture.texture = load(GlobalPaths.get_bullet_texture())
		var worker: String = GlobalStats.get_ammo()
		var inv: Array = GlobalSave.get_stat("collectables")
		if GlobalSave.has_item(inv, worker):
			for array in inv:
				if array[0] == worker:
					ui_slot_label.text = "x%s" % array[1]
					ui_slot_label.modulate = Color8(255, 255, 255)
					return
		else:
			ui_slot_label.text = "x0"
			ui_slot_label.modulate = Color8(220, 25, 25)


func update_gems() -> void:
	if Globals.game_state == Globals.GameStates.LEVEL:
		gem_container.show()
		var index: int = 0
		var gem_dict = GlobalSave.get_stat("gems")
		for gem in gem_textures:
			if gem_dict.has(str(GlobalLevel.current_world)):
				if gem_dict[str(GlobalLevel.current_world)].has(str(GlobalLevel.current_level)):
					if gem_dict[str(GlobalLevel.current_world)][str(GlobalLevel.current_level)][index]:
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


func update_health_counter() -> void:
	health_amount.text = "%s  |  %s " % [
			GlobalSave.get_stat("health"), GlobalSave.get_stat("health_max")]


func update_coin_counter(_amount: int = 0) -> void:
	coin_label.text = str(GlobalSave.get_stat("coins"))


func update_orb_counter(_amount: int = 0) -> void:
	orb_label.text = str(GlobalSave.get_stat("orbs"))
	if GlobalSave.get_stat("orbs") >= GlobalSave.get_level_up_cost() and not upgrade_notification_showed:
		GlobalEvents.emit_signal("ui_notification_shown", tr("notification.upgrade_available"))
		upgrade_notification_showed = true


func update_adrenaline_counter() -> void:
	var is_visibe: bool = GlobalSave.get_stat("rank") >= GlobalStats.Ranks.GOLD
	adrenaline_label.visible = is_visibe
	adrenaline_texture.visible = is_visibe
	adrenaline_label.text = "%s  |  %s" % [
			GlobalSave.get_stat("adrenaline"), GlobalSave.get_stat("adrenaline_max")]


func _level_changed(_world: int, _level: int) -> void:
	hide()
	yield(GlobalEvents, "ui_faded")
	update_counters()
	yield(GlobalEvents, "ui_faded")
	yield(get_tree(), "physics_frame")
	update_counters()
	show_hud()
	toggled = true


func _level_completed() -> void:
	update_counters()
	hide_hud()


func _player_died() -> void:
	hide_hud()
	yield(GlobalEvents, "ui_faded")
	update_counters()


func _player_level_increased(_upgrade: String) -> void:
	upgrade_notification_showed = false


func _player_collected_coin(_amount: int) -> void:
	update_counters()


func _player_collected_orb(_amount: int) -> void:
	update_counters()


func _player_collected_gem(_index: int) -> void:
	update_counters()

func _player_hurt_from_enemy(var _hurt_type: int, var _knockback: int, var _damage: int) -> void:
	update_counters()


func _player_used_powerup(_item_name: String) -> void:
	yield(get_tree(), "physics_frame")
	update_counters()


func _save_stat_updated() -> void:
	update_counters()


func _ui_inventory_opened() -> void:
	if Globals.game_state == Globals.GameStates.WORLD_SELECTOR:
		show_hud()


func _ui_inventory_closed() -> void:
	if Globals.game_state == Globals.GameStates.WORLD_SELECTOR:
		hide_hud()


func _ui_pause_menu_return_prompt_yes_pressed() -> void:
	hide_hud()
	yield(GlobalEvents, "ui_faded")
	upgrade_notification_showed = false
