extends Control

onready var sprite: Sprite = $CenterContainer/Label/Sprite
onready var anim_player: AnimationPlayer = $AnimationPlayer
onready var audio: AudioStreamPlayer = $AudioStreamPlayer


func _enter_tree() -> void:
	OS.min_window_size = Vector2(1280, 720)


func _ready() -> void:
	sprite.texture = load("res://splash/logo_large_monochrome_dark.png")

	anim_player.play("splash")
	audio.play()

	yield(anim_player, "animation_finished")

	sprite.texture = load("res://splash/wraith_winterly_pfp.png")
	anim_player.play("splash_wraith")


	#audio.stream = load("res://loader/515827__newlocknew__ui-3-1-fhsandal-sinus-sytrus-arpegio-multiprocessing-rsmpl.wav")
	#audio.play()

	yield(anim_player,"animation_finished")

	sprite.texture = load("res://ui/main_menu/main_logo.png")
	sprite.scale = Vector2(20, 20)
	sprite.offset.y = -3
	audio.stream = load("res://ui/411460__inspectorj__power-up-bright-a.wav")
	audio.play()
	anim_player.play("splash_everplast")

	yield(anim_player,"animation_finished")

	while audio.playing:
		yield(get_tree(), "physics_frame")

	go_to_game()


func _input(event: InputEvent) -> void:
	if (event is InputEventKey or event is InputEventJoypadButton or event is InputEventMouseButton) and OS.has_feature("editor"):
		go_to_game()


func go_to_game() -> void:
	var __: int = get_tree().change_scene("res://main.tscn")

