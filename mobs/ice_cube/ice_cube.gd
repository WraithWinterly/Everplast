extends KinematicBody2D

onready var mob_component: MobComponentManager = $MobComponentManager
onready var particles: Particles2D = $WaterParticles


func _ready() -> void:
	var __: int
	__ = mob_component.connect("hit", self, "_hit")
	particles.emitting = true


func _hit() -> void:
	particles.emitting = true
