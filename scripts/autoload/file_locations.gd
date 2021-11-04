extends Node

var dust: String = "res://scenes/player/dust.tscn"
var orb: String = "res://scenes/orb.tscn"
var coin: String = "res://scenes/coin.tscn"
var level_enter_sound: String = "res://assets/world_selector/go_to_level.wav"
var world_selector: String = "res://scenes/world_selector/world_selector.tscn"

var clouds := ["res://assets/world1/cloud.png",
		"res://assets/world1/cloud_2.png",
		"res://assets/world1/cloud_3.png"]


func get_level(world: int, level: int) -> String:
	return "res://scenes/world%s/level%s.tscn" % [world, level]


func get_powerup(powerup_name: String) -> String:
	return "res://scenes/powerups/%s.tscn" % powerup_name


func get_equipable(equipable_name: String) -> String:
	equipable_name = equipable_name.replace(" ", "_")
	return "res://scenes/equipables/%s.tscn" % equipable_name


func get_bullet(equipable_name: String) -> String:
	equipable_name = equipable_name.replace(" ", "_")
	return "res://scenes/equipables/%s_bullet.tscn" % equipable_name
