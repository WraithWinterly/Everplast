extends Node

enum Ranks {
	NONE,
	SILVER,
	GOLD,
	DIAMOND,
	GLITCH,
}

enum Bosses {
	FERNAND,
	OSTRICH,
}

enum Guns {
	WATER_GUN,
	NAIL_GUN,
	LASER_GUN,
}

enum Collectables {
	WATER,
	NAIL,
	ENERGY
}

const equippable_items: Array = ["none", "water gun", "nail gun", "laser gun"]

const bunny_egg_boost := 1.4
const adrenaline_time_decrease_from_level_up := 0.95

const stat_increase_from_level_up: int = 5

const cherry_boost: int = 5
const carrot_boost: int = 2
const coconut_boost: int = 5
const pear_health_boost: int = 10
const pear_adrenaline_boost: int = 5

const bunny_egg_time: int = 10
const glitch_orb_time: int = 7

const pear_time: int = 5
const pear_consequence: int = 5

const RANK_EXPLANATIONS := {
	"none": "rank_explanations.none",
	"silver": "rank_explanations.silver",
	"gold": "rank_explanations.gold",
	"diamond": "rank_explanations.diamond",
	"glitch": "rank_explanations.glitch",
}

const RANK_NAMES := {
	"None": "rank_names.none",
	"Silver": "rank_names.silver",
	"Gold": "rank_names.gold",
	"Diamond": "rank_names.diamond",
	"Glitch": "rank_names.glitch",
}

const POWERUP_NAMES := {
	"Carrot": "inventory.item.carrot",
	"Cherry": "inventory.item.cherry",
	"Coconut": "inventory.item.coconut",
	"Bunny Egg": "inventory.item.bunny_egg",
	"Glitch Orb": "inventory.item.glitch_orb",
	"Pear": "inventory.item.pear",
	"Glitch Soul": "inventory.item.glitch_soul",

	"Energy": "inventory.collectable.energy",
	"Water": "inventory.collectable.water",
	"Nail": "inventory.collectable.nail",

	"Water Gun": "inventory.equippable.water_gun",
	"Nail Gun": "inventory.equippable.nail_gun",
	"Laser Gun": "inventory.equippable.laser_gun"
}

const COLLECTABLE_NAMES := {
	"Water": "Water",
	"Energy": "Energy",
	"Nail": "Nail",
}

const EQUIPPABLE_NAMES := {
	"Water Gun": "Water Gun",
	"Laser Gun": "Laser Gun",
	"Nail Gun": "Nail Gun",
}

const SHOP_NAMES := {
	"Orbs": "Orbs"
}

const valid_powerups: Array = ["carrot", "cherry", "coconut", "bunny egg", "glitch orb", "pear", "glitch soul"]
const timed_powerups: Array = ["glitch orb", "bunny egg"]

const valid_equippables: Array = ["water gun", "nail gun", "laser gun"]
const valid_collectables: Array = ["energy", "water", "nail"]

#var powerup_explanations := {
#	"carrot": "%s %s" % [tr("powerup_explanations.carrot"), carrot_boost],
#	"cherry": "%s %s" % [tr("powerup_explanations.cherry"), cherry_boost],
#	"coconut": "%s %s" % [tr("powerup_explanations.coconut"), coconut_boost],
#	"bunny egg": "%s %s %s" % [tr("powerup_explanations.bunny_egg"), bunny_egg_time, tr("powerup_explanations.bunny_egg.2")],
#	"glitch orb": "%s %s" % [tr("powerup_explanations.glitch_orb"), glitch_orb_time],
#	"pear": "%s %s %s %s" % [tr("powerup_explanations.pear"), pear_health_boost, tr("powerup_explanations.pear.2"), pear_adrenaline_boost],
#	"glitch soul": "%s" % tr("powerup_explanations.glitch_soul"),
#}

var timed_powerup_active := false
var active_timed_powerup = ""


func get_powerup_explanation(powerup_name: String) -> String:
	match powerup_name:
		"carrot":
			return "%s %s." % [tr("powerup_explanations.carrot"), carrot_boost]
		"cherry":
			return "%s %s." % [tr("powerup_explanations.cherry"), cherry_boost]
		"coconut":
			return "%s %s." % [tr("powerup_explanations.coconut"), coconut_boost]
		"bunny egg":
			return "%s %s %s." % [tr("powerup_explanations.bunny_egg"), bunny_egg_time, tr("powerup_explanations.bunny_egg.2")]
		"glitch orb":
			return "%s %s" % [tr("powerup_explanations.glitch_orb"), glitch_orb_time]
		"pear":
			return "%s %s %s %s" % [tr("powerup_explanations.pear"), pear_health_boost, tr("powerup_explanations.pear.2"), pear_adrenaline_boost]
		"glitch soul":
			return "%s" % tr("powerup_explanations.glitch_soul")
		_:
			return "Not complete"


func get_ammo() -> String:
	match GlobalSave.get_stat("equipped_item"):
		"nail gun":
			return "nail"
		"laser gun":
			return "energy"
		"water gun":
			return "water"
	return ""


func get_firerate(gun: int) -> float:
	match gun:
		Guns.WATER_GUN:
			return 0.2
		Guns.NAIL_GUN:
			return 0.05
		Guns.LASER_GUN:
			return 0.3
		_:
			return 0.2


func get_spike_damage(tile_id: int) -> int:
	match tile_id:
		0, 1:
			return 4
		2:
			return 2
		_:
			return 2


func get_player_jump_damage() -> int:
	var rank := int(GlobalSave.get_stat("rank"))

	if rank == Ranks.SILVER:
		return 1
	elif rank == Ranks.GOLD:
		return 3
	elif rank == Ranks.DIAMOND:
		return 5
	elif rank == Ranks.GLITCH:
		return 5

	return 1
