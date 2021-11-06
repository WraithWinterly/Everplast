extends Node

# Attack the player if it is touched by the enemy

export var damage: int = 1
export var knockback: int = 150
export var enemy_path: NodePath

onready var hit_area: Area2D = $HitArea
onready var enemy: KinematicBody2D = get_node(enemy_path)
onready var enemy_component: EnemyComponentManager = get_parent()
onready var attack_by_jump = enemy_component.get_node_or_null("HurtByJump")


func _ready() -> void:
	Signals.connect("player_invincibility_stopped", self, "_player_invincibility_stopped")
	hit_area.connect("body_entered", self, "_hit_area_body_entered")
	hit_area.connect("body_exited", self, "_hit_area_body_exited")


func _hit_area_body_entered(body: Node) -> void:
	if enemy_component.dead: return
	if body.is_in_group("Player"):
		if attack_by_jump:
			if body.player.falling:
				return
		enemy_component.hurt_player = true
		Signals.emit_signal("player_hurt_from_enemy", Globals.EnemyHurtTypes.NORMAL, enemy_component.knockback, enemy_component.damage)


func _hit_area_body_exited(body: Node) -> void:
	enemy_component.hurt_player = false


func _player_invincibility_stopped() -> void:
	yield(get_tree(), "physics_frame")
	var bodies = hit_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("Player"):
			_hit_area_body_entered(body)
			Signals.emit_signal("player_hurt_from_enemy", Globals.EnemyHurtTypes.NORMAL, enemy_component.knockback, enemy_component.damage)
