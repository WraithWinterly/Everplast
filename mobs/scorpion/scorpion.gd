extends KinematicBody2D

onready var mob_component: Node2D = $MobComponentManager
onready var particles: Particles2D = $Particles2D


func _ready() -> void:
	var __: int
	__ = mob_component.connect("hit", self, "_hit")


func _hit() -> void:
	particles.emitting = true



