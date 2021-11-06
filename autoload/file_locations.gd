extends Node

var dust: String = "res://player/dust.tscn"
var orb: String = "res://world_all/orb.tscn"
var coin: String = "res://world_all/coin.tscn"
var level_enter_sound: String = "res://misc/go_to_level.wav"
var world_selector: String = "res://world_selector/world_selector.tscn"

var clouds := ["res://world1/cloud.png",
		"res://world1/cloud_2.png",
		"res://world1/cloud_3.png"]


func get_level(world: int, level: int) -> String:
	return "res://world%s/level%s.tscn" % [world, level]


func get_powerup(powerup_name: String) -> String:
	return "res://powerups/%s.tscn" % powerup_name


func get_equipable(equipable_name: String) -> String:
	equipable_name = equipable_name.replace(" ", "_")
	return "res://equipables/%s.tscn" % equipable_name


func get_bullet(equipable_name: String) -> String:
	equipable_name = equipable_name.replace(" ", "_")
	return "res://equipables/%s_bullet.tscn" % equipable_name


func get_bullet_texture() -> String:
	return "res://collectables/%s.png" % PlayerStats.get_ammo()
