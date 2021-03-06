extends Node

const DUST := "res://player/dust.tscn"
const WATER_PARTICLES := "res://player/water_particles.tscn"

const ORB := "res://world_all/orbs/orb.tscn"
const COIN := "res://world_all/coins/coin.tscn"
const RANK_PICKUP := "res://world_all/rank_pickup/rank_pickup.tscn"
const WORLD_SELECTOR := "res://world_selector/world_selector.tscn"

const CARROT := "res://world_all/powerups/carrot.tscn"
const CHERRY := "res://world_all/powerups/cherry.tscn"
const COCONUT := "res://world_all/powerups/coconut.tscn"
const BUNNY_EGG := "res://world_all/powerups/bunny_egg.tscn"
const ICE_SPIKE := "res://world_all/powerups/ice_spike.tscn"
const PEAR := "res://world_all/powerups/pear.tscn"
const WATER := "res://world_all/collectables/water.tscn"
const SNOW := "res://world_all/collectables/water.tscn"
const ENERGY := "res://world_all/collectables/energy.tscn"
const GLITCH_ORB := "res://world_all/powerups/glitch_orb.tscn"
const GLITCH_SOUL := "res://world_all/powerups/glitch_soul.tscn"
const NAIL_BULLET := "res://world_all/collectables/nail.tscn"
const SNOWBALL_SNOWMAN := "res://mobs/snowman/snowball/snowball.tscn"
const SNOWBALL_ITEM := "res://world_all/collectables/snowball.tscn"

const ADRENALINE := "res://world_all/adrenaline.png"

const LEVEL_ENTER_SOUND := "res://ui/fade_player/level_enter.ogg"

const VASE_BULLET := "res://world_all/vases/vase_bullet.png"
const GEM_USED := "res://world_all/gems/gem_used.png"

const CREDITS_SCROLL_GRABBER := "res://ui/settings_menu/scroll_grabber.tres"
const CREDITS_SCROLL := "res://ui/settings_menu/scroll.tres"


const MAIN := "/root/Main"
const LEVEL_HOLDER := "/root/Main/LevelHolder"
const PLAYER := "/root/Main/LevelHolder/Level/Player/KinematicBody2D"
const PLAYER_CAMERA := "/root/Main/LevelHolder/Level/Player/Smoothing2D/Camera2D"
const LEVEL := "/root/Main/LevelHolder/Level"
const FADE_PLAYER := "/root/Main/GUI/FadePlayer"
const WORLD_ENVIRONMENT := "/root/Main/WorldEnvironment"
const SETTINGS := "/root/Main/GUI/Control/Settings"

const CLOUDS := ["res://world1/cloud.png",
		"res://world1/cloud_2.png",
		"res://world1/cloud_3.png"]


func get_level(world: int, level: int) -> String:
	return "res://world%s/level%s.tscn" % [world, level]


func get_powerup(powerup_name: String) -> String:
	powerup_name = powerup_name.replace(" ", "_")
	return "res://world_all/powerups/%s.tscn" % powerup_name

func get_powerup_texture(powerup_name: String) -> String:
	powerup_name = powerup_name.replace(" ", "_")
	return "res://world_all/powerups/%s.png" % powerup_name

func get_equippable(equippable_name: String) -> String:
	equippable_name = equippable_name.replace(" ", "_")
	return "res://world_all/equippables/%s.tscn" % equippable_name


func get_bullet(equippable_name: String) -> String:
	equippable_name = equippable_name.replace(" ", "_")
	return "res://world_all/equippables/%s_bullet.tscn" % equippable_name


func get_bullet_texture() -> String:
	return "res://world_all/collectables/%s.png" % GlobalStats.get_ammo()
