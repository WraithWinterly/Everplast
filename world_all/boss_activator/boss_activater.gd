extends Area2D


export(GlobalStats.Bosses) var boss := GlobalStats.Bosses.FERNAND

var used: bool = false


func _on_BossActivator_area_entered(area: Area2D) -> void:
	if used: return

	if area.is_in_group("Player"):
		GlobalLevel.in_boss = true
		used = true
		GlobalEvents.emit_signal("story_boss_activated", boss)
