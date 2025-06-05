class_name DialogBox extends Control

@onready var dialog_content: RichTextLabel = $Dialog
@onready var dialog_speaker: Label = $Speaker

signal dialog_finished

var current_typewriter_task: SceneTreeTimer = null
var current_text: String = ""
var target_text: String = ""
var current_index: int = 0
var letter_delay: float = 0.05
var hold_time: float = 0.0

@export var default_name: String = ""
@export var default_text: String = ". . ."

func speak_words(content: String, speaker_name: String, new_letter_delay: float = 0.05, new_hold_time: float = 0.0) -> void:
	dialog_speaker.text = speaker_name
	dialog_content.text = ""
	if current_typewriter_task != null:
		current_typewriter_task.timeout.emit()
		current_typewriter_task = null
	
	target_text = content
	current_text = ""
	current_index = 0
	letter_delay = new_letter_delay
	hold_time = new_hold_time
	
	# Start the typewriter effect
	current_typewriter_task = get_tree().create_timer(letter_delay)
	current_typewriter_task.timeout.connect(_on_typewriter_tick)

func _on_typewriter_tick() -> void:
	if current_index < target_text.length():
		current_text += target_text[current_index]
		dialog_content.text = current_text
		current_index += 1
		current_typewriter_task = get_tree().create_timer(letter_delay)
		current_typewriter_task.timeout.connect(_on_typewriter_tick)
	else:
		current_typewriter_task = null
		if hold_time > 0:
			await get_tree().create_timer(hold_time).timeout
			dialog_speaker.text = default_name
			dialog_content.text = default_text
		dialog_finished.emit()
