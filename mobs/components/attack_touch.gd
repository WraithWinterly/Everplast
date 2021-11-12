extends Node

# Attack the player if it is touched by the enemy
export var enemy_path: NodePath
export var hit_area_path: NodePath
export var flying_enemy: bool = false

onready var hit_area: Area2D = get_node(hit_area_path)
onready var enemy: KinematicBody2D = get_node(enemy_path)
onready var enemy_component: EnemyComponentManager = get_parent()
onready var attack_by_jump = enemy_component.get_node_or_null("HurtByJump")


func _ready() -> void:
	var __: int
	__ = Signals.connect("player_invincibility_stopped", self, "_player_invincibility_stopped")
	__ = hit_area.connect("body_entered", self, "_hit_area_body_entered")
	__ = hit_area.connect("body_exited", self, "_hit_area_body_exited")


func _hit_area_body_entered(body: Node) -> void:
	if enemy_component.dead: return
	if body.is_in_group("Player"):
		yield(get_tree(), "physics_frame")
		if enemy_component.hurt_by_jump: return
		if attack_by_jump:
#			if body.player.falling:
#				return
			if body.fsm.current_state == body.fsm.dash:
				return
		if flying_enemy:
			Signals.emit_signal("player_hurt_from_enemy",
					Globals.EnemyHurtTypes.NORMAL_AIR,
					enemy_component.knockback,
					enemy_component.damage)
			enemy_component.hurt_player = true
		else:
			Signals.emit_signal("player_hurt_from_enemy",
					Globals.EnemyHurtTypes.NORMAL,
					enemy_component.knockback,
					enemy_component.damage)
			enemy_component.hurt_player = true


func _hit_area_body_exited(body: Node) -> void:
	if body.is_in_group("Player"):
		enemy_component.hurt_player = false


func _player_invincibility_stopped() -> void:
	if enemy_component.dead: return
	yield(get_tree(), "physics_frame")
	var bodies = hit_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("Player"):
			_hit_area_body_entered(body)
			if flying_enemy:
				Signals.emit_signal("player_hurt_from_enemy", Globals.EnemyHurtTypes.NORMAL_AIR, enemy_component.knockback, enemy_component.damage)
			else:
				Signals.emit_signal("player_hurt_from_enemy", Globals.EnemyHurtTypes.NORMAL, enemy_component.knockback, enemy_component.damage)
