extends Control

onready var progress_bar: ProgressBar = $ProgressBar


func _ready() -> void:
	Signals.connect("level_changed", self, "_level_changed")


func _physics_process(delta: float) -> void:
	if not Globals.in_level: return
	if progress_bar.value > PlayerStats.data.health:
		progress_bar.value -= 5
		yield(get_tree(), "physics_frame")
		return
	else: if progress_bar.value < PlayerStats.data.health:
		progress_bar.value += 1
		yield(get_tree(), "physics_frame")
		return
	progress_bar.max_value = PlayerStats.data.max_health


func _level_changed(_world: int, _level: int, _from_start: bool) -> void:
	progress_bar.value = PlayerStats.data.health
