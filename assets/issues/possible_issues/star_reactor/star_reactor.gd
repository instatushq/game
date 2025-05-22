extends ColorRect

var buttonSequence: Array[int] = []
var correctSequence: Array[int] = []
var currentRun: int = 1
var maxRuns: int = 5
var canAcceptInput: bool = false

func _update_progress_dots() -> void:
	for i in range(maxRuns):
		var dot = $ProgressDots.get_node(str(i))
		if dot:
			if i < currentRun:
				dot.modulate = Color(0, 1, 0)  # Green for completed runs
			elif i == currentRun - 1:
				dot.modulate = Color(1, 0, 0)  # Red for current run
			else:
				dot.modulate = Color(0.5, 0.5, 0.5)  # Gray for future runs

func _on_button_pressed(button: TextureButton) -> void:
	if not canAcceptInput:
		return
		
	var button_number = int(button.name)
	buttonSequence.append(button_number)
	print("Button ", button_number, " pressed")
	
	# Check if this button matches the sequence
	if button_number != correctSequence[buttonSequence.size() - 1]:
		_show_mistake()
		return
	
	# Visual feedback for correct button press
	button.modulate = Color(0, 1, 0)  # Green
	await get_tree().create_timer(0.2).timeout
	button.modulate = Color(1, 1, 1)  # White
	
	if buttonSequence.size() == correctSequence.size():
		_check_sequence()

func _show_mistake() -> void:
	canAcceptInput = false
	# Flash all buttons red
	for button in $InputPanel/InputGrid.get_children():
		button.modulate = Color(1, 0, 0)  # Red
	
	await get_tree().create_timer(0.5).timeout
	
	# Reset all buttons to white
	for button in $InputPanel/InputGrid.get_children():
		button.modulate = Color(1, 1, 1)  # White
	
	buttonSequence.clear()
	$result.text = "Try again :("
	
	# Show the sequence again
	await get_tree().create_timer(0.5).timeout
	_show_sequence()

func _check_sequence() -> void:
	print("Correct sequence!")
	$result.text = "Correct :)"
	if currentRun < maxRuns:
		currentRun += 1
		_update_progress_dots()
		await get_tree().create_timer(1.0).timeout
		_generate_new_sequence()
	else:
		$result.text = "You Win! 🎉"
		canAcceptInput = false
		# TODO: Add win handling
	
	buttonSequence.clear()

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
		if button:
			button.modulate = Color(1, 0, 0)  # Red
			await get_tree().create_timer(0.5).timeout
			button.modulate = Color(1, 1, 1)  # White
			await get_tree().create_timer(0.2).timeout
	canAcceptInput = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_update_progress_dots()
	_generate_new_sequence()
	
	# Connect button signals
	for button in $InputPanel/InputGrid.get_children():
		button.connect("pressed", _on_button_pressed.bind(button))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on__gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton: 
		print("mouse clicked")
	
	pass # Replace with function body.
