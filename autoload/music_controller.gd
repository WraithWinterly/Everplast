extends Node

var audio_stream_player := AudioStreamPlayer.new()

var loaded_stream_name: String = ""


# Look at line count for index
var level_stream_paths := [
	"res://world1/anttis_instrumentals_feel_the_love.ogg",                      #0
	"res://world1/anttis_instrumentals_beach_walk.mp3",                         #1
	"res://world1/anttis_instrumentals_ET_alone_ET_call_home_instrumental.mp3", #2
	"res://world1/daydream_anatomy_8_bit_heroes_03_nin10day_modified.ogg",      #3
	"res://world2/anttis_instrumentals_simple_simplyfied.ogg",                  #4
	"res://world3/anttis_instrumentals_rain.ogg",
	"res://world4/anttis_instrumentals_wonderful_lie.ogg",
	"res://world5/lines_of_code.mp3",
]

var stream_paths := [
	"res://ui/anttis_intstrumentals_another_day.ogg",
	"res://world_selector/sie_fragen_beat.mp3"]


var music_database := [
#    0  1  2  3  4  5  6  7  8  9
	[0, 0, 0, 0, 0, 0], # debug levels
	[0, 0, 1, 0, 0, 2, 1, 3, 0, 0], # World 1
	[4, 4, 4, 4, 4, 4], # World 2
	[1, 1, 1, 1, 1, 1], # World 3
	[1, 1, 1, 1, 1, 1], # World 4
	[7, 7, 7, 7, 7, 7], # World 5
	[1, 1, 1, 1, 1, 1], # World 6
]

var music_subsection_database := [
#    0  1  2  3  4  5  6  7  8  9
	[0, 0, 0, 0, 0, 0], # debug levels
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 2], # World 1
	[0, 0, 0, 0, 0, 0], # World 2
	[0, 0, 0, 0, 0, 0], # World 3
	[0, 0, 0, 0, 0, 0], # World 4
	[0, 0, 0, 0, 0, 0], # World 5
	[0, 0, 0, 0, 0, 0], # World 6
]


func _ready() -> void:
	pause_mode = PAUSE_MODE_PROCESS
	add_child(audio_stream_player, true)
	audio_stream_player.bus = "Music"
	update_music()


func _physics_process(_delta: float) -> void:
	update_music()


func update_music() -> void:
	var new_stream_name: String
	match Globals.game_state:
		Globals.GameStates.WORLD_SELECTOR:
			new_stream_name = stream_paths[1]
		Globals.GameStates.LEVEL:
			if LevelController.current_world == -1:
				return
			if Globals.in_subsection:
				new_stream_name = level_stream_paths[music_subsection_database[LevelController.current_world][LevelController.current_level]]
			else:
				new_stream_name = level_stream_paths[music_database[LevelController.current_world][LevelController.current_level]]

		Globals.GameStates.MENU:
			new_stream_name = stream_paths[0]

	if Globals.in_evil_mode:
		new_stream_name = level_stream_paths[7]

	if not new_stream_name == loaded_stream_name:
		audio_stream_player.stream = load(new_stream_name)
		loaded_stream_name = new_stream_name
	if not audio_stream_player.playing:
		audio_stream_player.play()
