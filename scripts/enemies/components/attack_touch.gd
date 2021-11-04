extends Node

# Attack the player if it is touched by the enemy

export var enemy_path: NodePath
export var hit_area_path: NodePath

var check_for_player: bool = false

onready var hit_area: Area2D = get_node(hit_area_path)
onready var enemy: KinematicBody2D = get_node(enemy_path)
onready var enemy_component: EnemyComponentManager = get_parent()
onready var attack_by_jump = enemy_component.get_node_or_null("HurtByJump")


func _ready() -> void:
	hit_area.connect("body_entered", self, "on_hit_area_body_entered")
	hit_area.connect("body_exited", self, "_on_hit_area_body_exited")


func _physics_process(delta: float) -> void:
	if enemy.dead: return
	if check_for_player:
		var bodies = hit_area.get_overlapping_bodies()
		for body in bodies:
			if body.is_in_group("Player"):
				on_hit_area_body_entered(body)
				Signals.emit_signal("player_hurt_from_enemy", Globals.EnemyHurtTypes.NORMAL, enemy.knockback, enemy.damage)



func on_hit_area_body_entered(body: Node) -> void:
	if enemy.dead: return
	if body.is_in_group("Player"):
		if attack_by_jump:
			if body.player.falling:
				return
		enemy.hurt_player = true
		check_for_player = true
		Signals.emit_signal("player_hurt_from_enemy", Globals.EnemyHurtTypes.NORMAL, enemy.knockback, enemy.damage)


func _on_hit_area_body_exited(body: Node) -> void:
	enemy.hurt_player = false
