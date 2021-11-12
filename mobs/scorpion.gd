extends KinematicBody2D

onready var enemy_component: Node2D = $EnemyComponentManager
onready var particles: Particles2D = $Particles2D


func _ready() -> void:
	var __: int
	__ = enemy_component.connect("died", self, "_died")
	__ = enemy_component.connect("hit", self, "_hit")


func _died() -> void:
	pass


func _hit() -> void:
	particles.emitting = true
