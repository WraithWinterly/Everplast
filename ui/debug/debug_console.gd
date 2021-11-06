extends Control

var command_history: Array = []
var all_words: Array = []
var command_history_line: int = command_history.size()

var last_world: Vector2

onready var output: TextEdit = $Panel/Output
onready var input: LineEdit = $Input
onready var command_handler: Node = $CommandHandler


func _ready() -> void:
	hide()
	Signals.connect("error_level_changed", self, "_error_level_changed")
	input.connect("text_entered", self, "_text_entered")
	output.text = ""


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_console"):
		if visible:
			hide()
			if UI.current_menu == UI.NONE:
				get_tree().paused = false
		else:
			show()
			input.grab_focus()
			yield(get_tree(), "idle_frame")
			input.clear()
			get_tree().paused = true

	if event is InputEventKey and event.is_pressed() and visible:
		if event.scancode == KEY_UP:
			set_command_history(-1)
		if event.scancode == KEY_DOWN:
			set_command_history(1)


func set_command_history(offset: int) -> void:
	command_history_line += offset
	command_history_line = int(clamp(command_history_line, 0, command_history.size()))
	if command_history_line < command_history.size() and command_history.size() > 0:
		input.text = command_history[command_history_line]
		input.caret_position = input.text.length()
		get_tree().set_input_as_handled()


func process_command(text) -> void:
	all_words = text.split(" ")
	all_words = Array(all_words)

	for _i in range(all_words.count("")):
		all_words.erase("")

	if all_words.size() == 0:
		return

	command_history.append(text)

	var command_word: String = all_words.pop_front()
	var index: int = 0
	for command in command_handler.valid_commands:
		if command[0] == command_word:
			if command.size() > 1:
				if not all_words.size() == command[1].size():
					output_text(str('Failed executing command "', command_word, '", expected ', command[1].size(), ' parameters'))
					return
			for i in range(all_words.size()):
				var sucess: bool = check_type(all_words[i], command[1][i], index)
				index += 1
				if not sucess:
					output_text(str('Failed executing command "', command_word, '", parameter ', (i + 1),
								' ("', all_words[i], '") is the wrong type'))
					return
			if command.size() > 1:
				output_text(command_handler.callv(command_word, all_words))
			else:
				output_text(command_handler.call(command_word))
			return
	output_text(str('Command "', command_word, '" does not exist.'))


func check_type(string: String, type: int, index: int) -> bool:
	match type:
		command_handler.ARG_INT:
			if string.is_valid_integer():
				all_words[index] = int(string)
				return true
		command_handler.ARG_FLOAT:
			if string.is_valid_float():
				all_words[index] = float(string)
				return true
		command_handler.ARG_STRING:
			return true
		command_handler.ARG_BOOL:
			if string == "true" or string == "1":
				all_words[index] = bool(string)
				return true
			elif string == "false" or string == "0":
				all_words[index] = bool(string)
				return true
			return false
	return false


func output_text(text) -> void:
	output.text = str(output.text, "\n", text)
	output.set_v_scroll(INF)


func _text_entered(new_text: String) -> void:
	input.clear()
	process_command(new_text)
	command_history_line = command_history.size()


func _error_level_changed() -> void:
	output_text("Failed changing level! Potentionally to World %s, Level %s" % [last_world.x, last_world.y])
