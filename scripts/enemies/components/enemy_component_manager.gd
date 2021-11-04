extends Node2D
class_name EnemyComponentManager


func _has_component(component: String) -> bool:
	return get_node_or_null("component") == null
