extends Node2D

export var enemy_path: NodePath

onready var enemy: KinematicBody2D = get_node(enemy_path)
onready var hurt_area: Area2D = $HurtArea


func _ready() -> void:
	hurt_area.connect("body_entered", self, "_hurt_area_body_entered")
	hurt_area.connect("body_exited", self, "_hurt_area_body_exited")


func _hurt_area_body_entered(body: Node) -> void:
	yield(get_tree(), "physics_frame")
	if get_parent().dead: return
	if body.is_in_group("Player") and not get_parent().hurt_player:
		get_parent().damage_self(Globals.HurtTypes.JUMP)


func _hurt_area_body_exited(body: Node) -> void:
	get_parent().hurt_player = false


