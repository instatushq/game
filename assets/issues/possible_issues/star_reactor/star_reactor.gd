extends ColorRect

@export var ButtonFlashTime: float = 0.5
@export var TimeBetweenFlashes: float = 0.2

var buttonSequence: Array[int] = []
var correctSequence: Array[int] = []
var currentRun: int = 1
var maxRuns: int = 5
var canAcceptInput: bool = false

const GREEN = Color(0, 1, 0)
const RED = Color(1, 0, 0)
const GREY = Color(0.5, 0.5, 0.5)
const WHITE = Color(1, 1, 1)


func _generate_new_sequence() -> void:
	correctSequence.clear()
	for i in range(currentRun):
		correctSequence.append(randi() % 9)
	print("Run ", currentRun, " - correctSequence: ", correctSequence)
	_show_sequence()

func _show_sequence() -> void:
	canAcceptInput = false
	for i in range(correctSequence.size()):
		var button = $InputPanel/InputGrid.get_node(str(correctSequence[i]))
		button.modulate = RED
		await get_tree().create_timer(ButtonFlashTime).timeout
		button.modulate = WHITE
		await get_tree().create_timer(TimeBetweenFlashes).timeout
	canAcceptInput = true

func _on_button_pressed(button: TextureButton) -> void:
	if not canAcceptInput:
		return
		
	var button_number = int(button.name)
	buttonSequence.append(button_number)
	if button_number != correctSequence[buttonSequence.size() - 1]:
		_show_mistake()
		return
	button.modulate = GREEN
	await get_tree().create_timer(0.2).timeout
	button.modulate = WHITE
	
	if buttonSequence.size() == correctSequence.size():
		_check_sequence()

func _check_sequence() -> void:
	$result.text = "Correct incident response"
	if currentRun < maxRuns:
		currentRun += 1
		_update_progress_dots()
		await get_tree().create_timer(0.75).timeout
		_generate_new_sequence()
		$result.text = "Run " + str(currentRun) + " of " + str(maxRuns)
	else:
		var dot = $ProgressDots.get_node("4")
		dot.modulate = GREEN
		$result.text = "Issue resolved!! ⚡️"
		canAcceptInput = false
		# TODO: win
	buttonSequence.clear()

func _set_button_colors(newColor: Color) -> void:
	for button in $InputPanel/InputGrid.get_children():
		button.modulate = newColor

func _show_mistake() -> void:
	canAcceptInput = false

	_set_button_colors(RED)
	await get_tree().create_timer(0.5).timeout
	_set_button_colors(WHITE)
	
	buttonSequence.clear()
	$result.text = "Try again :("
	
	await get_tree().create_timer(0.5).timeout
	$result.text = "Run " + str(currentRun) + " of " + str(maxRuns)
	_show_sequence()

func _update_progress_dots() -> void:
	for i in range(maxRuns):
		var dot = $ProgressDots.get_node(str(i))
		if i == currentRun - 1:
			dot.modulate = RED
		elif i < currentRun - 1:
			dot.modulate = GREEN
		else:
			dot.modulate = GREY

func _ready() -> void:
	_update_progress_dots()
	_generate_new_sequence()
	
	for button in $InputPanel/InputGrid.get_children():
		button.connect("pressed", _on_button_pressed.bind(button))
