extends Node
class_name Main

enum VersionPrefixes {
	DEV,
	ALPHA,
	BETA,
	RELEASE,
}

enum VersionPosts {
	DEVELOPER_BUILD,
	DISCORD_TESTER,
	KICKSTARTER,
	STEAM,
	SWITCH,
}

export(VersionPrefixes) var version_prefix = VersionPrefixes.DEV
export(VersionPosts) var version_post = VersionPosts.DEVELOPER_BUILD

export var version_numbers: Array = [0, 0, 0]

export var runtime_pos := Vector2()

export var runtime_world: int = 0
export var runtime_level: int = 0

export var runtime_start_level := false
export var demo_version := false


func _ready() -> void:
	VisualServer.set_default_clear_color(Color(0, 0, 0, 0))

	if demo_version:
		Globals.demo_version = true
		Globals.version_string = "Everplast Version %s.%s.%s.%s.demo.%s" % [
				version_numbers[0], version_numbers[1],version_numbers[2],
				VersionPrefixes.keys()[version_prefix].to_lower(), VersionPosts.keys()[version_post].to_lower()]
	else:
		Globals.version_string = "Everplast Version %s.%s.%s.%s.%s" % [
				version_numbers[0], version_numbers[1],version_numbers[2],
				VersionPrefixes.keys()[version_prefix].to_lower(), VersionPosts.keys()[version_post].to_lower()]

# Mute audio on focus loss?
#func _notification(what: int) -> void:
#	match what:
#		NOTIFICATION_WM_FOCUS_OUT:
#			AudioServer.set_bus_mute(0, true)
#			AudioServer.set_bus_mute(1, true)
#		NOTIFICATION_WM_FOCUS_IN:
#			AudioServer.set_bus_mute(0, false)
#			AudioServer.set_bus_mute(1, false)
