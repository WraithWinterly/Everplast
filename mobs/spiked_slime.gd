extends KinematicBody2D

onready var enemy_component: EnemyComponentManager = $EnemyComponentManager
onready var particles: Particles2D = $Particles2D


func _ready() -> void:
	var __: int
	__ = enemy_component.connect("hit_player", self, "_hit_player")


func _hit_player() -> void:
	particles.emitting = true
