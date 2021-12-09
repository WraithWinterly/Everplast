extends AudioStreamPlayer

export var play_in_subsection := true


func _physics_process(_delta: float) -> void:
	if not play_in_subsection and GlobalLevel.in_subsection:
		stop()
	else:
		if not playing:
			play()
