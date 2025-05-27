extends Node2D

@onready var units_container: Control = $CanvasLayer/UnitsContainer
@onready var controls: Array[Control] = []
var fade_timer: Timer = null
var current_tween: Tween = null

var current_control_index: int = -1
var fade_duration: float = 1.0
var is_fading_in: bool = true

func _ready() -> void:
	for unit in units_container.get_children():
		if unit is Control:
			controls.append(unit)
			unit.modulate.a = 0.0
	
	fade_timer = Timer.new()
	add_child(fade_timer)
	fade_timer.one_shot = true
	fade_timer.timeout.connect(_on_fade_timer_timeout)
	
	start_fade_sequence()

func _input(event: InputEvent) -> void:
	if event is InputEventKey or event is InputEventMouseButton or event is InputEventJoypadButton:
		if event.pressed:
			handle_input_press()

func handle_input_press() -> void:
	if current_tween and current_tween.is_valid():
		current_tween.kill()
	
	if is_fading_in:
		# If fading in, complete the fade in and start fade out
		controls[current_control_index].modulate.a = 1.0
		fade_timer.stop()
		fade_out_current_control()
	else:
		# If fading out, complete the fade out and start next fade in
		controls[current_control_index].modulate.a = 0.0
		_on_fade_out_finished()

func start_fade_sequence() -> void:
	current_control_index = 0
	fade_in_current_control()

func fade_in_current_control() -> void:
	if current_control_index >= controls.size():
		get_tree().change_scene_to_file("res://assets/main menu/main menu.tscn")
		return
	
	is_fading_in = true
	current_tween = create_tween()
	current_tween.tween_property(controls[current_control_index], "modulate:a", 1.0, fade_duration)
	fade_timer.start(5.0)

func fade_out_current_control() -> void:
	is_fading_in = false
	current_tween = create_tween()
	current_tween.tween_property(controls[current_control_index], "modulate:a", 0.0, fade_duration)
	current_tween.finished.connect(_on_fade_out_finished)

func _on_fade_out_finished() -> void:
	current_control_index += 1
	fade_in_current_control()

func _on_fade_timer_timeout() -> void:
	if is_fading_in:
		fade_out_current_control()
