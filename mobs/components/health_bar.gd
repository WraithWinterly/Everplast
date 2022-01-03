extends ProgressBar

var text_lerp_value: float = 1
var actual_value: float = 1

onready var enemy_base: MobComponentManager = get_parent().get_parent()
onready var label: Label = $Label


func _ready() -> void:
	if int(GlobalSave.get_stat("rank")) >= GlobalStats.Ranks.DIAMOND:
		show()
	else:
		hide()
	actual_value = enemy_base.max_health


func _physics_process(_delta: float) -> void:
	var health: int
	var max_health: int

	if int(enemy_base.max_health) == 0:
		max_health = 1
	else:
		max_health = enemy_base.max_health

	if int(enemy_base.health) == 0:
		health = 1
	else:
		health = enemy_base.health

	var val: float = float(max_health) / float(health)

	if not val == 0:
		actual_value = 100 / val
	else:
		actual_value = 0

	value = lerp(value, actual_value, 0.1)

	text_lerp_value = lerp(float(text_lerp_value), enemy_base.health + 0.1, 0.1)
	label.text = str(int(text_lerp_value))
