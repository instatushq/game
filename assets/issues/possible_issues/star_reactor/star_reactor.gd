extends ColorRect

var buttonSequence: Array[int] = []
var correctSequence: Array[int] = []

func _on_button_pressed(button: TextureButton) -> void:
	var button_number = int(button.name)
	buttonSequence.append(button_number)
	print("Button ", button_number, " pressed")
	
	if buttonSequence.size() == correctSequence.size():
		_check_sequence()

func _check_sequence() -> void:
	var is_correct = true
	for i in range(buttonSequence.size()):
		if buttonSequence[i] != correctSequence[i]:
			is_correct = false
			break
	
	if is_correct:
		print("Correct sequence!")
		$result.text = "Correct :)"
		# TODO: Add success handling
	else:
		print("Wrong sequence!")
		$result.text = "Try again :("
		# TODO: Add failure handling
	
	buttonSequence.clear()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	correctSequence = [randi() % 9]
	print("correctSequence", correctSequence)

	# Initialize display panels
	for rect in $DisplayPanel/DisplayPanelGrid.get_children():
		print("rect", rect.name, "ready")
		if rect.name == str(correctSequence[0]):
			await get_tree().create_timer(1.0).timeout
			rect.color = Color(1, 0, 0)
			# wait for 1 second
			await get_tree().create_timer(1.0).timeout
			rect.color = Color(1, 1, 1)
	
	# Connect button signals
	for button in $InputPanel/InputGrid.get_children():
		button.connect("pressed", _on_button_pressed.bind(button))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
