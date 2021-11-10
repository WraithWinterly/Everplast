extends Node

var audio_stream_player := AudioStreamPlayer.new()

var loaded_stream_name: String = ""

var level_stream_paths := [
	"res://ui/anttis_intstrumentals_another_day.ogg",
	"res://world1/anttis_instrumentals_feel_the_love.ogg",
	"res://world2/anttis_instrumentals_simple_simplyfied.ogg",
	"res://world3/anttis_instrumentals_rain.ogg",
	"res://world4/anttis_instrumentals_wonderful_lie.ogg",
	"res://world5/lines_of_code.mp3",
]

var stream_paths := [
	"res://ui/anttis_intstrumentals_another_day.ogg",
	"res://world_selector/sie_fragen_beat.mp3"]


var music_database := [
	[1, 1, 1, 1, 1, 1], # debug levels
	[1, 1, 1, 1, 1, 1], # World 1
	[1, 2, 2, 2, 2, 2], # World 2
	[1, 3, 3, 3, 3, 3], # World 3
	[1, 1, 1, 1, 1, 1], # World 4
	[5, 5, 5, 5, 5, 5], # World 5
	[1, 1, 1, 1, 1, 1], # World 6
]

func _ready() -> void:
	pause_mode = PAUSE_MODE_PROCESS
	add_child(audio_stream_player, true)
	audio_stream_player.bus = "Music"
	update_music()


func _physics_process(delta: float) -> void:
	update_music()


func update_music() -> void:
	var new_stream_name: String
	match Globals.game_state:
		Globals.GameStates.WORLD_SELECTOR:
			new_stream_name = stream_paths[1]
		Globals.GameStates.LEVEL:
			if LevelController.current_world == -1:
				return
			new_stream_name = level_stream_paths[music_database[LevelController.current_world][LevelController.current_level]]
		Globals.GameStates.MENU:
			new_stream_name = stream_paths[0]

	if not new_stream_name == loaded_stream_name:
		audio_stream_player.stream = load(new_stream_name)
		loaded_stream_name = new_stream_name
	if not audio_stream_player.playing:
		audio_stream_player.play()


