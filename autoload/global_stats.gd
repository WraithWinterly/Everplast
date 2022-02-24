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
	CORA,
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

const COMMON_NAMES := {
	"Carrot": "inventory.item.carrot",
	"Cherry": "inventory.item.cherry",
	"Coconut": "inventory.item.coconut",
	"Bunny Egg": "inventory.item.bunny_egg",
	"Glitch Orb": "inventory.item.glitch_orb",
	"Pear": "inventory.item.pear",
	"Glitch Soul": "inventory.item.glitch_soul",
	"Ice Spike": "inventory.item.ice_spike",

	"Energy": "inventory.collectable.energy",
	"Water": "inventory.collectable.water",
	"Nail": "inventory.collectable.nail",
	"Snowball": "inventory.collectable.snowball",

	"Water Gun": "inventory.equippable.water_gun",
	"Nail Gun": "inventory.equippable.nail_gun",
	"Laser Gun": "inventory.equippable.laser_gun",
	"Snow Gun": "inventory.equippable.snow_gun",
	"Ice Gun": "inventory.equippable.ice_gun"
}

const SHOP_NAMES := {
	"Orbs": "Orbs"
}

const VALID_POWERUPS: Array = ["carrot", "cherry", "coconut", "bunny egg", "glitch orb", "pear", "glitch soul", "ice spike"]
const TIMED_POWERUPS: Array = ["glitch orb", "bunny egg", "ice spike", "glitch soul"]

const VALID_EQUIPPABLES: Array = ["water gun", "nail gun", "laser gun", "snow gun", "ice gun"]
const VALID_COLLECTABLES: Array = ["energy", "water", "nail", "snowball"]

const BUNNY_EGG_BOOST := 1.4
const ADRENALINE_TIME_DECREASE_FROM_LEVEL_UP := 0.8

const STAT_INCREASE_FROM_LEVEL_UP: int = 5

const CHERRY_BOOST: int = 5
const CHERRY_BOOST_HEALTH: int = 15
const CARROT_BOOST: int = 2
const COCONUT_BOOST: int = 5
const PEAR_HEALTH_BOOST: int = 10
const PEAR_ADRENALINE_BOOST: int = 5

const BUNNY_EGG_TIME: int = 10
const GLITCH_ORB_TIME: int = 7
const ICE_SPIKE_TIME: int = 6
const GLITCH_SOUL_TIME: int = 6

const PEAR_TIME: int = 5
const PEAR_CONSEQUENCE: int = 5

var active_timed_powerup := ""
var last_powerup_before_death := ""
var last_powerup := ""
var timed_powerup_active := false

var total_gems: int = 0


func _enter_tree() -> void:
	pause_mode = PAUSE_MODE_PROCESS

func _ready() -> void:

	for world in range(GlobalLevel.WORLD_COUNT + 1):
		#print(str(world) + "- World")
		for level in GlobalLevel.LEVEL_DATABASE[world] + 1:
			if int(level) == 0: continue
			#print(str(level) + "-level")
			total_gems += 3

	#print(total_gems)

func _process(_delta: float) -> void:
	pass#(total_gems)


func get_powerup_explanation(powerup_name: String) -> String:
	match powerup_name:
		"carrot":
			return "%s %s" % [tr("powerup_explanations.carrot"), CARROT_BOOST]
		"cherry":
			return "%s %s %s %s" % [tr("powerup_explanations.cherry"), CHERRY_BOOST_HEALTH, tr("powerup_explanations.cherry_2"), CHERRY_BOOST]
		"coconut":
			return "%s %s" % [tr("powerup_explanations.coconut"), COCONUT_BOOST]
		"bunny egg":
			return "%s %s %s" % [tr("powerup_explanations.bunny_egg"), BUNNY_EGG_TIME, tr("powerup_explanations.bunny_egg_2")]
		"glitch orb":
			return "%s %s" % [tr("powerup_explanations.glitch_orb"), GLITCH_ORB_TIME]
		"pear":
			return "%s %s %s %s" % [tr("powerup_explanations.pear"), PEAR_HEALTH_BOOST, tr("powerup_explanations.pear.2"), PEAR_ADRENALINE_BOOST]
		"glitch soul":
			return "%s" % tr("powerup_explanations.glitch_soul")
		"ice spike":
			return "%s %s %s" % [tr("powerup_explanations.ice_spike"), ICE_SPIKE_TIME, tr("powerup_explanations.ice_spike_2")]
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
		"snow gun":
			return "snowball"
	return "GET_AMO NOT SETUP"


func get_firerate(equippable_name: String) -> float:
	match equippable_name:
		"nail gun":
			return 0.05
		"laser gun":
			return 0.25
		"water gun":
			return 0.2
		"snow gun":
			return 0.3
		"ice gun":
			return 0.25
	return 0.2


func get_equippable_damage(equippable_name: String) -> int:
	match equippable_name:
		"nail gun":
			return 20
		"laser gun":
			return 5
		"water gun":
			return 1
		"snow gun":
			return 10
		"ice gun":
			return 15
		_:
			printerr("Equippable damage not set for %s" % equippable_name)
	return 0

func get_equippable_speed(equippable_name: String) -> int:
	match equippable_name:
		"nail gun":
			return 800
		"laser gun":
			return 700
		"water gun":
			return 500
		"snow gun":
			return 350
		"ice gun":
			return 900
		_:
			printerr("Equippable speed not set for %s" % equippable_name)
	return 0

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
