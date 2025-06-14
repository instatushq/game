extends ColorRect

@onready var input_grid: GridContainer = $AnimatedTextureRect/InputGrid
@onready var background: AnimatedTextureRect = $AnimatedTextureRect
@onready var screens_vhs_effect: AnimatedTextureRect = $AnimatedTextureRect/ScreenVHS
@onready var screens_glow: TextureRect = $AnimatedTextureRect/TVGlow
@onready var progress_dots: HBoxContainer = $AnimatedTextureRect/ProgressDots
@onready var result_label: Label = $AnimatedTextureRect/result
@onready var game_title_label: Label = $AnimatedTextureRect/title
@onready var parent: Issue = get_parent()

@export var ButtonFlashTime: float = 0.5
@export var TimeBetweenFlashes: float = 0.2

var buttonSequence: Array[int] = []
var correctSequence: Array[int] = []
var currentRun: int = 1
var maxRuns: int = 5
var canAcceptInput: bool = false
var isShowingSequence: bool = false

const POSITIVE = Color("#17dd92")
const NEGATIVE = Color("#c61b1c")
const NEUTRAL = Color("#18bfcf")

signal on_button_preview(button: SequenceTextureButton)
signal on_button_successful_press(button: SequenceTextureButton)
signal on_button_failed_press(button: SequenceTextureButton)
signal on_complete_sequence

func _resolve_issue() -> void:
	parent.issue_resolved.emit()

func _generate_new_sequence() -> void:
	correctSequence.clear()
	for i in range(currentRun):
		correctSequence.append(randi() % 9)
	_show_sequence()

func _show_sequence() -> void:
	if isShowingSequence:
		return
		
	isShowingSequence = true
	canAcceptInput = false
	
	for i in range(correctSequence.size()):
		var button: SequenceTextureButton = input_grid.get_node(str(correctSequence[i]))
		button.set_sequence_texture(SequenceTextureButton.SequenceState.SHOWING)
		on_button_preview.emit(button)
		await get_tree().create_timer(ButtonFlashTime).timeout
		button.set_sequence_texture(SequenceTextureButton.SequenceState.NEUTRAL)
		await get_tree().create_timer(TimeBetweenFlashes).timeout
	
	isShowingSequence = false
	canAcceptInput = true

func _on_button_pressed(button: SequenceTextureButton) -> void:
	if not canAcceptInput or isShowingSequence:
		return
		
	var button_number = int(button.name)
	buttonSequence.append(button_number)
	
	# to prevent crashes when the sequence is displaying and user spams
	if buttonSequence.size() > correctSequence.size():
		return
	
	if button_number != correctSequence[buttonSequence.size() - 1]:
		on_button_failed_press.emit(button)
		_show_mistake()
		return
		
	if buttonSequence.size() == correctSequence.size():
		_check_sequence()

	button.set_sequence_texture(SequenceTextureButton.SequenceState.CORRECT)
	on_button_successful_press.emit(button)
	await get_tree().create_timer(0.2).timeout
	button.set_sequence_texture(SequenceTextureButton.SequenceState.NEUTRAL)

func _check_sequence() -> void:
	result_label.text = "Correct"
	if currentRun < maxRuns:
		currentRun += 1
		_update_progress_dots()
		await get_tree().create_timer(0.75).timeout
		_generate_new_sequence()
		result_label.text = "Run " + str(currentRun) + " of " + str(maxRuns)
	else:
		on_complete_sequence.emit()
		var dot = progress_dots.get_node("4")
		dot.modulate = POSITIVE
		canAcceptInput = false
		result_label.text = "resolved"
		await get_tree().create_timer(1.5).timeout
		_resolve_issue()
	buttonSequence.clear()

func _set_buttons_sequence_texture(state: SequenceTextureButton.SequenceState) -> void:
	for button in input_grid.get_children():
		button.set_sequence_texture(state)

func _show_mistake() -> void:
	canAcceptInput = false

	_set_buttons_sequence_texture(SequenceTextureButton.SequenceState.INCORRECT)
	await get_tree().create_timer(0.5).timeout
	_set_buttons_sequence_texture(SequenceTextureButton.SequenceState.NEUTRAL)
	
	buttonSequence.clear()
	result_label.text = "Try again"
	
	await get_tree().create_timer(0.5).timeout
	result_label.text = "Run " + str(currentRun) + " of " + str(maxRuns)
	_show_sequence()

func _update_progress_dots() -> void:
	for i in range(maxRuns):
		var dot = progress_dots.get_node(str(i))
		if i == currentRun - 1:
			dot.modulate = NEGATIVE
		elif i < currentRun - 1:
			dot.modulate = POSITIVE
		else:
			dot.modulate = NEUTRAL

func _on_background_animation_ending(animation_name: String) -> void:
	if animation_name == "intro":
		background.play("normal")
		input_grid.visible = true
		screens_vhs_effect.visible = true
		screens_glow.visible = true
		result_label.visible = true
		game_title_label.visible = true
		await get_tree().create_timer(0.6).timeout
		_update_progress_dots()
		_generate_new_sequence()
		for button in input_grid.get_children():
			button.connect("pressed", _on_button_pressed.bind(button))

func _ready() -> void:
	input_grid.visible = false
	screens_vhs_effect.visible = false
	screens_glow.visible = false
	game_title_label.visible = false
	parent.issue_opened.connect(func(): background.play("intro"))
	background.on_animation_ending.connect(_on_background_animation_ending)
	result_label.visible = false
