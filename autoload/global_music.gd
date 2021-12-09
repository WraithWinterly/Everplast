extends Node

var audio_stream_player := AudioStreamPlayer.new()

var loaded_stream_name: String = ""


# Look at line count for index
const LEVEL_STREAM_PATHS := [
	"res://world1/anttis_instrumentals_feel_the_love.ogg",                      #0
	"res://world1/anttis_instrumentals_beach_walk.mp3",                         #1
	"res://world1/anttis_instrumentals_ET_alone_ET_call_home_instrumental.mp3", #2
	"res://world1/daydream_anatomy_8_bit_heroes_03_nin10day_modified.ogg",      #3
	"res://world2/anttis_instrumentals_simple_simplyfied.ogg",                  #4
	"res://world3/anttis_instrumentals_rain.ogg",
	"res://world4/anttis_instrumentals_wonderful_lie.ogg",
	"res://world4/lines_of_code.mp3",
]

const STREAM_PATHS := [
	"res://ui/anttis_instrumentals_some_kind_of_music.mp3",
	"res://world_selector/anttis_instrumentals_blue_arpeggio.mp3"]

const BOSS_PATHS := [
	"res://mobs/fernand/piratos_beta.mp3"
]

const MUSIC_DATABASE := [
#    0  1  2  3  4  5  6  7  8  9
	[0, 0, 0, 0, 0, 0], # debug levels
	[0, 0, 1, 0, 0, 2, 1, 3, 0, 0], # World 1
	[4, 4, 4, 4, 4, 4], # World 2
	[1, 1, 1, 1, 1, 1], # World 3
	[6, 6, 6, 6, 6, 6], # World 4
]

const MUSIC_SUBSECTION_DATABASE := [
#    0  1  2  3  4  5  6  7  8  9
	[0, 0, 0, 0, 0, 0], # debug levels
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 2], # World 1
	[0, 0, 0, 0, 0, 0], # World 2
	[0, 0, 0, 0, 0, 0], # World 3
	[0, 0, 0, 0, 0, 0], # World 4
]


func _ready() -> void:
	pause_mode = PAUSE_MODE_PROCESS

	# Give time for Settings to apply
	yield(get_tree(), "physics_frame")
	add_child(audio_stream_player, true)
	audio_stream_player.bus = "Music"
	update_music()


func _physics_process(_delta: float) -> void:
	update_music()


func update_music() -> void:
	if GlobalUI.menu_locked: return

	var new_stream_name: String

	match Globals.game_state:
		Globals.GameStates.WORLD_SELECTOR:
			new_stream_name = STREAM_PATHS[1]
		Globals.GameStates.LEVEL:
			if GlobalLevel.current_world == -1:
				return
			if GlobalLevel.in_subsection:
				new_stream_name = LEVEL_STREAM_PATHS[MUSIC_SUBSECTION_DATABASE[GlobalLevel.current_world][GlobalLevel.current_level]]
			else:
				new_stream_name = LEVEL_STREAM_PATHS[MUSIC_DATABASE[GlobalLevel.current_world][GlobalLevel.current_level]]

		Globals.GameStates.MENU:
			new_stream_name = STREAM_PATHS[0]

	if GlobalLevel.in_boss:
		new_stream_name = BOSS_PATHS[GlobalLevel.current_world - 1]

	if not new_stream_name == loaded_stream_name:
		audio_stream_player.stream = load(new_stream_name)
		loaded_stream_name = new_stream_name

	if not audio_stream_player.playing:
		audio_stream_player.play()
