extends Control

var packs := [
	"res://Phonic_1.pck",
	"res://Phonic_2.pck",
	"res://Phonic_3.pck",
	"res://Drawing.pck"
]

func _enter_tree() -> void:
	GlobalMusic.disabled = true
	VisualServer.set_default_clear_color(Color8(0, 0, 0, 0))


func _ready() -> void:
	if OS.has_feature("editor") or not OS.get_name() == "Windows":
		go_to_loader()
		return

	var return_value: bool

	var i: int =0
	for pck in packs:
		return_value = ProjectSettings.load_resource_pack(pck)
		if not return_value:
			load_failed(packs[i])
			return
		i += 1

	go_to_loader()


func go_to_loader() -> void:
	var __: int = get_tree().change_scene("res://loader/loader.tscn")


func load_failed(path: String) -> void:
	path = path.replace("res://", "")
	$ErrorLabel.text = \
"""There was an error loading Everplast. If you have removed, changed, or rename files,
please restore them to their original state. Please do not change any .pck files, or
rename any executables.

Failed loading \"%s\"""" % path
	$ErrorLabel.text += "\n\nLocal to \"%s\"" % OS.get_executable_path()
