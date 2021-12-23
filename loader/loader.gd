extends Control


func _enter_tree() -> void:
	OS.min_window_size = Vector2(1280, 720)
	GlobalMusic.disabled = true


func _ready() -> void:
	$CenterContainer/Label/Sprite.texture = load("res://loader/logo_large_monochrome_dark.png")
	$AnimationPlayer.play("splash")
	$AudioStreamPlayer.play()
	yield($AnimationPlayer, "animation_finished")
	$CenterContainer/Label/Sprite.texture = load("res://loader/wraith_winterly_pfp.png")
	#$AudioStreamPlayer.stream = load("res://ui/loader/220162__gameaudio__teleport-high.wav")
	$AnimationPlayer.play("splash_wraith")
	#$AudioStreamPlayer.play()
	yield($AnimationPlayer,"animation_finished")
	$AudioStreamPlayer.stream = load("res://loader/515827__newlocknew__ui-3-1-fhsandal-sinus-sytrus-arpegio-multiprocessing-rsmpl.wav")
	$AudioStreamPlayer.play()
	while $AudioStreamPlayer.playing:
		yield(get_tree(), "physics_frame")
	go_to_game()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and OS.has_feature("editor"):
		go_to_game()

func go_to_game() -> void:
	GlobalMusic.disabled = false

	var __ = get_tree().change_scene("res://main.tscn")

