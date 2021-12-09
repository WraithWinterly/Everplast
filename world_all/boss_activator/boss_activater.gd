extends Area2D


enum Bosses {
	World1Boss
}

export(GlobalStats.Bosses) var boss := GlobalStats.Bosses.FERNAND

var used: bool = false


func _on_BossActivator_area_entered(area: Area2D) -> void:
	if used: return
	if area.is_in_group("Player"):
		match boss:
			Bosses.World1Boss:
				GlobalLevel.in_boss = true
				GlobalEvents.emit_signal("story_w1_boss_activated")
				used = true
