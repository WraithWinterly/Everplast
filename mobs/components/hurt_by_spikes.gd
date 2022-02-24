extends Node2D


export var kinematic_body_path: NodePath

onready var kinematic_body = get_node(kinematic_body_path)

# Spikes
func _physics_process(_delta):
	for i in kinematic_body.get_slide_count():
		var collider = kinematic_body.get_slide_collision(i).collider
		if collider is TileMap:
			if collider.is_in_group("Spikes"):
				get_parent().damage(Globals.HurtTypes.SPIKES)
				return
