extends Node2D

export var enemy_path: NodePath
export var hurt_area_path: NodePath

onready var hurt_area: Area2D = get_node(hurt_area_path)


func _ready() -> void:
	var __: int
	__ = hurt_area.connect("area_entered", self, "_hurt_area_area_entered")


func _hurt_area_area_entered(area: Area2D) -> void:
	if get_parent().dead: return
	if area.is_in_group("Bullet"):
		get_parent().damage(Globals.HurtTypes.BULLET, area)

