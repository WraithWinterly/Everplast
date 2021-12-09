extends ParallaxBackground

# Used by Menus using Level's Canvas and Parallax Backgrounds
func _ready() -> void:
	remove_from_group("CanvasBackground")
	$ParallaxLayer/CanvasModulate.remove_from_group("CanvasModulate")
	$ParallaxLayer2/CanvasModulate.remove_from_group("CanvasModulate")
	$ParallaxLayer3/CanvasModulate.remove_from_group("CanvasModulate")
	$CanvasLayerBack/CanvasModulate.remove_from_group("CanvasModulate")
