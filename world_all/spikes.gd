extends Node2D

var damage: int = 2
var knockback: int = 150
var check_for_player: bool = false

onready var area_2d: Area2D = $Area2D


func _ready() -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 349580734908573498
	rng.randomize()
	$Sprite.frame = rng.randi_range(0, 3)
	$Area2D.connect("body_entered", self, "_on_Area2D_body_entered")
	$Area2D.connect("body_exited", self, "_on_Area2D_body_exited")


func _physics_process(delta: float) -> void:
	if check_for_player and not Globals.death_in_progress:
		var bodies = area_2d.get_overlapping_bodies()
		for body in bodies:
			if body.is_in_group("Player"):
				Signals.emit_signal("player_hurt_from_enemy",
						Globals.EnemyHurtTypes.NORMAL,knockback, damage)


func _on_Area2D_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		Signals.emit_signal("player_hurt_from_enemy",
				Globals.EnemyHurtTypes.NORMAL, knockback, damage)
		check_for_player = true


func _on_Area2D_body_exited(body: Node) -> void:
	if body.is_in_group("Player"):
		check_for_player = false
