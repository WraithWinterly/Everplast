extends KinematicBody2D

onready var mob_component := $MobComponentManager as MobComponentManager
onready var particles := $Particles2D as Particles2D


func _ready() -> void:
	var __: int
	__ = mob_component.connect("hit_player", self, "_hit_player")


func _hit_player() -> void:
	particles.emitting = true
