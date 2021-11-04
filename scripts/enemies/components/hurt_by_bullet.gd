extends Node2D

export var enemy_path: NodePath
export var hurt_area_path: NodePath

onready var enemy: KinematicBody2D = get_node(enemy_path)
onready var hurt_area: Area2D = get_node(hurt_area_path)


func _ready() -> void:
	hurt_area.connect("body_entered", self, "_hurt_area_body_entered")


func _hurt_area_body_entered(body: Node) -> void:
	if enemy.dead: return
	yield(get_tree(), "physics_frame")
	if body.is_in_group("Bullet"):
		enemy.damage_self(Globals.HurtTypes.BULLET, body)

