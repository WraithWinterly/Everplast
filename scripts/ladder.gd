extends StaticBody2D


func _ready() -> void:
	 $Sprite.frame = LevelController.current_world - 1
