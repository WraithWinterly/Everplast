extends Control

var previous_item: String = "none"
var shown_powerup: String

var health_display: float = 0
var health_display_max: float = 0
var coin_display_prev: float = 0
var coin_display: float = 0
var orb_display: float = 0
var orb_display_prev: float = 0
var adrenaline_display: float = 0
var adrenaline_display_max: float = 0

var toggled := true
var upgrade_notification_showed := false
var ui_slot_visible := false
var powerup_slot_visible := false
var bypass_visibility := false

# Used to turn health counter red
var low_health_rect_active := false

onready var coin_label: Label = $VBoxContainer/HBoxContainer/CoinLabel
onready var health_label: Label = $VBoxContainer/HBoxContainer/HealthLabel
onready var orb_label: Label = $VBoxContainer/HBoxContainer/OrbLabel
onready var adrenaline_texture: TextureRect = $VBoxContainer/HBoxContainer/AdrenalineTexture
onready var adrenaline_label: Label = $VBoxContainer/HBoxContainer/AdrenalineLabel
onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var ui_slot: TextureRect = $VBoxContainer/UISlot
onready var ui_slot_label: Label = $VBoxContainer/UISlot/Label
onready var ui_slot_texture: TextureRect = $VBoxContainer/UISlot/TextureRect
onready var ui_slot_anim_player: AnimationPlayer = $VBoxContainer/UISlot/AnimationPlayer
onready var powerup_slot: TextureRect = $VBoxContainer/QuickPowerupSlot
onready var powerup_slot_texture: TextureRect = $VBoxContainer/QuickPowerupSlot/TextureRect
onready var powerup_slot_label: Label = $VBoxContainer/QuickPowerupSlot/Label
onready var powerup_slot_anim_player: AnimationPlayer = $VBoxContainer/QuickPowerupSlot/AnimationPlayer
onready var powerup_use_anim_player: AnimationPlayer = $VBoxContainer/QuickPowerupSlot/TextureRect/Sprite/AnimationPlayer
onready var gem_textures := [$GenContainer/GemSlot1/Gem, $GenContainer/GemSlot2/Gem, $GenContainer/GemSlot3/Gem]
onready var gem_container: HBoxContainer = $GenContainer
onready var low_health_rect :TextureRect = $LowHealth
onready var noti_delay: Timer = $NotiDelay


func _ready() -> void:
	var __: int
	__ = GlobalEvents.connect("level_changed", self, "_level_changed")
	__ = GlobalEvents.connect("level_completed", self, "_level_completed")
	__ = GlobalEvents.connect("level_world_selector_loaded", self, "_level_world_selector_loaded")
	__ = GlobalEvents.connect("player_died", self, "_player_died")
	__ = GlobalEvents.connect("player_level_increased", self, "_player_level_increased")
	__ = GlobalEvents.connect("player_level_increase_animation_finished", self, "_player_level_increase_animation_finished")
	__ = GlobalEvents.connect("player_collected_coin", self, "_player_collected_coin")
	__ = GlobalEvents.connect("player_collected_orb", self, "_player_collected_orb")
	__ = GlobalEvents.connect("player_collected_gem", self, "_player_collected_gem")
	__ = GlobalEvents.connect("player_hurt_from_enemy", self, "_player_hurt_from_enemy")
	__ = GlobalEvents.connect("player_used_powerup", self, "_player_used_powerup")
	__ = GlobalEvents.connect("save_stat_updated", self, "_save_stat_updated")
	__ = GlobalEvents.connect("ui_pause_menu_return_prompt_yes_pressed", self, "_ui_pause_menu_return_prompt_yes_pressed")

	hide()
	for gem in gem_textures:
		gem.hide()


func _physics_process(_delta: float) -> void:
	if not Globals.game_state == Globals.GameStates.MENU:
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
			low_health_rect_active = false

		if GlobalSave.get_stat("orbs") >= GlobalSave.get_level_up_cost() and not upgrade_notification_showed and not Globals.game_state == Globals.GameStates.MENU:
			if GlobalUI.fade_player_playing:
				upgrade_notification_showed = true

				yield(GlobalEvents, "ui_faded")
				yield(GlobalEvents, "ui_faded")

				if Globals.game_state == Globals.GameStates.MENU:
					return

				if not GlobalSave.get_stat("orbs") >= GlobalSave.get_level_up_cost():
					return
			if noti_delay.is_stopped():
				noti_delay.start(noti_delay.wait_time)
			#GlobalEvents.emit_signal("ui_notification_shown", tr("notification.upgrade_available"))
			upgrade_notification_showed = true

		if not shown_powerup == null and not shown_powerup == "":
			powerup_slot_label.text = "x" + str(GlobalSave.get_item_count(GlobalSave.get_stat("powerups"), shown_powerup))
			if int(powerup_slot_label.text) == 0:
				shown_powerup = ""
				powerup_slot_anim_player.play_backwards("slide")
	else:
		low_health_rect.modulate = lerp(low_health_rect.modulate, Color8(255, 255, 255, 0), 0.1)
		low_health_rect_active = false


	update_counters()

	if GlobalStats.timed_powerup_active:
		if GlobalStats.active_timed_powerup == "ice spike":
			health_label.modulate = Color(0, 1, 0.8125)
			adrenaline_label.modulate = Color(0, 1, 0.8125)

func low_health_modulate(low_health, extreme_health) -> void:
	if Globals.game_state == Globals.GameStates.LEVEL:
		if GlobalSave.get_stat("health") <= low_health and GlobalSave.get_stat("health") > extreme_health:
			low_health_rect.modulate = lerp(low_health_rect.modulate, Color8(255, 255, 255, 70), 0.1)
			low_health_rect_active = true
		elif GlobalSave.get_stat("health") <= extreme_health:
			low_health_rect.modulate = lerp(low_health_rect.modulate, Color8(255, 255, 255, 150), 0.1)
			low_health_rect_active = true
		else:
			low_health_rect.modulate = lerp(low_health_rect.modulate, Color8(255, 255, 255, 0), 0.1)
			low_health_rect_active = false


func show_hud() -> void:
	animation_player.play("show")
	show()


func hide_hud() -> void:
	if not modulate == Color8(255, 255, 255, 0):
		animation_player.play_backwards("show")


func show_ui_slot() -> void:
	if not ui_slot_visible and Globals.game_state == Globals.GameStates.LEVEL:
		ui_slot_anim_player.play("slide")
		ui_slot_visible = true



func hide_ui_slot() -> void:
	if ui_slot_visible:
		ui_slot_anim_player.play_backwards("slide")
		ui_slot_visible = false


func show_powerup_slot() -> void:
	if not powerup_slot_visible and Globals.game_state == Globals.GameStates.LEVEL and not GlobalStats.last_powerup == "":
		powerup_slot.show()
		powerup_slot_anim_player.play("slide")
		powerup_slot_visible = true


func hide_powerup_slot() -> void:
	if powerup_slot_visible:
		powerup_slot_anim_player.play_backwards("slide")
		powerup_slot_visible = false

func update_visibility() -> void:
	yield(get_tree(), "physics_frame")
	if not Globals.game_state == Globals.GameStates.LEVEL:
		#ui_slot.hide()
		if ui_slot_visible:
			ui_slot_anim_player.play_backwards("slide")
			ui_slot_visible = false
		if powerup_slot_visible:
			powerup_slot_anim_player.play_backwards("slide")
			powerup_slot_visible = false


func update_counters() -> void:
	if Globals.game_state == Globals.GameStates.MENU:
		return

	#update_gems()
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

	if int(GlobalSave.get_stat("health")) == int(GlobalSave.get_stat("health_max")):
		health_label.modulate = Color8(40, 255, 60)
	elif low_health_rect_active:
		health_label.modulate = Color8(220, 25, 25)
	else:
		health_label.modulate = Color8(255, 255, 255)

	if GlobalSave.get_stat("equipped_item") == "none":
		hide_ui_slot()
	else:
		show_ui_slot()

	if GlobalStats.last_powerup == "none":
		hide_powerup_slot()
	else:
		show_powerup_slot()

	if ui_slot_visible:
		if not GlobalSave.get_stat("equipped_item") == previous_item:
			if GlobalSave.get_stat("equipped_item") == "ice gun":
				ui_slot_texture.texture = load(GlobalPaths.ADRENALINE)
			else:
				ui_slot_texture.texture = load(GlobalPaths.get_bullet_texture())

		var worker: String = GlobalStats.get_ammo()
		var inv: Array = GlobalSave.get_stat("collectables")

		if GlobalSave.get_stat("equipped_item") == "ice gun":
			ui_slot_label.text = "x%s" % GlobalSave.get_stat("adrenaline")
			ui_slot_label.modulate = Color8(255, 255, 255)
			if is_equal_approx(GlobalSave.get_stat("adrenaline"), 0):
				ui_slot_label.modulate = Color8(220, 25, 25)

		elif GlobalSave.has_item(inv, worker):
			for array in inv:
				if array[0] == worker:
					ui_slot_label.text = "x%s" % array[1]
					ui_slot_label.modulate = Color8(255, 255, 255)
					continue
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
	if event.is_action_pressed("toggle_hud") and not Globals.game_state == Globals.GameStates.MENU:
		if toggled:
			animation_player.stop()
			hide_hud()
			toggled = false
		else:
			animation_player.stop()
			show_hud()
			toggled = true


func update_health_counter() -> void:
	health_display = lerp(health_display, int(GlobalSave.get_stat("health")), 0.05)
	health_display_max = lerp(health_display_max, int(GlobalSave.get_stat("health_max")), 0.05)
	health_label.text = "%s  |  %s " % [
			int(health_display + 0.5), GlobalSave.get_stat("health_max")]


func update_coin_counter(_amount: int = 0) -> void:
	coin_display_prev = coin_display
	coin_display = lerp(coin_display, GlobalSave.get_stat("coins"), 0.09)
	coin_label.text = str(int(coin_display + 0.29))
	# Losing coins
	if (coin_display_prev - 0.04) > coin_display:
		coin_label.modulate = Color8(220, 25, 25, 255)
	else:
		coin_label.modulate = Color8(255, 255, 255, 255)



func update_orb_counter(_amount: int = 0) -> void:
	orb_display_prev = orb_display
	orb_display = lerp(orb_display, int(GlobalSave.get_stat("orbs")), 0.1)
	orb_label.text = str(int(orb_display + 0.49))
	# Losing orbs
	if (orb_display_prev - 0.05) > orb_display:
		orb_label.modulate = Color8(220, 25, 25, 255)
	else:
		orb_label.modulate = Color8(255, 255, 255, 255)


func update_adrenaline_counter() -> void:
	var is_visible: bool = GlobalSave.get_stat("rank") >= GlobalStats.Ranks.GOLD
	adrenaline_label.visible = is_visible
	adrenaline_texture.visible = is_visible
	adrenaline_display = lerp(adrenaline_display, int(GlobalSave.get_stat("adrenaline")), 0.1)
	adrenaline_display_max = lerp(adrenaline_display_max, int(GlobalSave.get_stat("adrenaline_max")), 0.05)
	adrenaline_label.text = "%s  |  %s" % [
			int(adrenaline_display + 0.5), int(adrenaline_display_max + 0.5)]


func reset_hud_displays() -> void:
	# Creates counting up animation on text
	health_display = 0
	health_display_max = 0
	coin_display = 0
	orb_display = 0
	orb_display_prev = 0
	orb_display_prev = 0
	adrenaline_display = 0
	adrenaline_display_max = 0


func _level_changed(_world: int, _level: int) -> void:
	powerup_slot.hide()
	hide()
	yield(GlobalEvents, "ui_faded")
	reset_hud_displays()

	upgrade_notification_showed = false
	update_counters()
	yield(GlobalEvents, "ui_faded")
	yield(get_tree(), "physics_frame")
	update_counters()
	show_hud()
	toggled = true
	show_ui_slot()
	show_powerup_slot()


func _level_completed() -> void:
	update_counters()
	hide_hud()


func _level_world_selector_loaded() -> void:
	show_hud()
	reset_hud_displays()


func _player_died() -> void:
	hide_hud()
	yield(GlobalEvents, "ui_faded")
	update_gems()


func _player_level_increased(_upgrade: String) -> void:
	bypass_visibility = true
	show_hud()


func _player_level_increase_animation_finished() -> void:
	upgrade_notification_showed = false
	yield(get_tree().create_timer(2), "timeout")
	bypass_visibility = false
	update_visibility()


func _player_collected_coin(_amount: int) -> void:
	update_counters()


func _player_collected_orb(_amount: int) -> void:
	update_counters()


func _player_collected_gem(_index: int) -> void:
	update_gems()


func _player_hurt_from_enemy(_hurt_type: int, _knockback: int, _damage: int) -> void:
	update_counters()


func _player_used_powerup(item_name: String) -> void:
	yield(get_tree(), "physics_frame")
								# wtf godot?
	if shown_powerup == null or shown_powerup == "":
		powerup_slot_anim_player.play("slide")
	powerup_slot_texture.texture = load(GlobalPaths.get_powerup_texture(item_name))
	shown_powerup = item_name
	powerup_use_anim_player.play("use")
	update_counters()


func _save_stat_updated() -> void:
	update_gems()


func _ui_pause_menu_return_prompt_yes_pressed() -> void:
	upgrade_notification_showed = true
	hide_hud()
	yield(GlobalEvents, "ui_faded")
	yield(get_tree(), "physics_frame")
	if not Globals.game_state == Globals.GameStates.LEVEL:
		if powerup_slot_visible:
			powerup_use_anim_player.play_backwards("use")
			powerup_slot_visible = false
	if Globals.game_state == Globals.GameStates.WORLD_SELECTOR:
		upgrade_notification_showed = false


func _on_NotiDelay_timeout() -> void:
	GlobalEvents.emit_signal("ui_notification_shown", tr("notification.upgrade_available"))
