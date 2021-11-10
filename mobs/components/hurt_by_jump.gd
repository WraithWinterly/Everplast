extends Node2D

export var enemy_path: NodePath
export var hurt_area_path: NodePath

onready var enemy: KinematicBody2D = get_node(enemy_path)
onready var hurt_area: Area2D = get_node(hurt_area_path)
onready var enemy_component: EnemyComponentManager = get_parent()


func _ready() -> void:
	hurt_area.connect("area_entered", self, "_hurt_area_area_entered")
	hurt_area.connect("body_entered", self, "_hurt_area_body_entered")
	hurt_area.connect("area_exited", self, "_hurt_area_area_exited")


func _hurt_area_area_entered(area: Area2D) -> void:
	#yield(get_tree(), "physics_frame")
	if enemy_component.dead: return
	if area.is_in_group("PlayerBoots"):
		if not get_node(Globals.player_body_path).is_on_floor() and not enemy_component.hurt_player and not enemy_component.hurt_by_jump:
			enemy_component.hurt_by_jump = true
			enemy_component.damage_self(Globals.HurtTypes.JUMP)


func _hurt_area_body_entered(body: Node) -> void:
	#yield(get_tree(), "physics_frame")
	if get_parent().dead: return
	if body.is_in_group("Player"):
		if body.fsm.current_state == body.fsm.dash and not enemy_component.hurt_by_jump:
			enemy_component.hurt_by_jump = true
			enemy_component.damage_self(Globals.HurtTypes.JUMP)
			

func _hurt_area_area_exited(area: Area2D) -> void:
	if area.is_in_group("PlayerBoots"):
		if not get_tree() == null:
			yield(get_tree(), "physics_frame")
		enemy_component.hurt_by_jump = false


