extends Control

var packs := [
	"res://Stream_1.pck",
	"res://Stream_2.pck",
	"res://Stream_3.pck",
	"res://Graphics.pck"
]


func _enter_tree() -> void:
	VisualServer.set_default_clear_color(Color8(0, 0, 0, 0))


func _ready() -> void:
	if OS.has_feature("editor") or not OS.get_name() == "Windows":
		go_to_splash()
		return

	var return_value: bool

	var i: int = 0

	for pck in packs:
		return_value = ProjectSettings.load_resource_pack(pck)
		if not return_value:
			load_failed(packs[i])
			return
		i += 1

	go_to_splash()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		go_to_splash()
		get_tree().set_input_as_handled()


func go_to_splash() -> void:
	var __: int = get_tree().change_scene("res://splash/splash.tscn")


func load_failed(path: String) -> void:
	path = path.replace("res://", "")

	$ErrorLabel.text = \
"""There was an error loading Everplast. If you have removed, changed, or renamed files,
please restore them to their original state. Please do not change any .pck files, or
rename any executables.
Failed loading \"%s\"
	\nLocal to \"%s"
Press escape to try anyways.


Hubo un error cargando Everplast. Si has quitado, cambiado o renombrado un archivo,
por favor ponlos como el valor por defecto. Por favor no cambies ningunos archivos de .pck,
o renombres ningunos ejecutables.
Fallado cargar \"%s\"
	\nLocal a \"%s"
Pulsa escape para intentarlo de todos modos.
""" % [path, OS.get_executable_path(), path, OS.get_executable_path()]
