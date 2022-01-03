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
		Globals.version_string = "Everplast Version %s.%s.%s.%s.demo" % [
				version_numbers[0], version_numbers[1],version_numbers[2],
				VersionPrefixes.keys()[version_prefix].to_lower()]
	else:
		Globals.version_string = "Everplast Version %s.%s.%s.%s" % [
				version_numbers[0], version_numbers[1],version_numbers[2],
				VersionPrefixes.keys()[version_prefix].to_lower()]

	OS.window_borderless = false
	OS.window_position.x -= 10
	OS.window_position.y -= 28

	# Give time for Settings to apply
	yield(get_tree(), "physics_frame")
	GlobalMusic.disabled = false
# Mute audio on focus loss?
#func _notification(what: int) -> void:
#	match what:
#		NOTIFICATION_WM_FOCUS_OUT:
#			AudioServer.set_bus_mute(0, true)
#			AudioServer.set_bus_mute(1, true)
#		NOTIFICATION_WM_FOCUS_IN:
#			AudioServer.set_bus_mute(0, false)
#			AudioServer.set_bus_mute(1, false)
func _input(event: InputEvent) -> void:
	if Input.is_key_pressed(KEY_0):
		OS.window_borderless = true
		OS.window_size = Vector2(1920, 1080)
		OS.window_position = Vector2(0, 0)
	if Input.is_key_pressed(KEY_9):
		OS.window_borderless = false
		OS.window_size = Vector2(1600, 900)
		OS.window_position = Vector2(160, 300)
