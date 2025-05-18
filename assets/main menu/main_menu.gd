extends Node2D

@export var ambience_light_on_hover: float = 42.0
@onready var transitions: TransitionScreen = $"Transition Screen"
@onready var ambience_lights: Light2D = $Ship/Body/Lights/Ambience
@onready var start_game_button: Button = $"Ship/Control/Start Game"
@onready var options_button: Button = $"Ship/Control/Options"
var original_ambience_light_energy: float = 0.0
var default_ambience_light_position: Vector2 = Vector2(0, -21)
var options_ambience_light_position: Vector2 = Vector2(-64.0, -14.0)

func _ready() -> void:
	transitions.on_transition_finish.connect(_switch_to_game)
	original_ambience_light_energy = ambience_lights.energy
	ambience_lights.position = default_ambience_light_position
	# Set up input handling for tab
	set_process_input(true)
	pass

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_focus_next") and get_viewport().gui_get_focus_owner() == null:
		options_button.grab_focus()
	elif event.is_action_pressed("ui_cancel") or event.is_action_pressed("ui_focus_prev"):
		if get_viewport().gui_get_focus_owner() != null:
			get_viewport().gui_get_focus_owner().release_focus()

func _on_click_start_game() -> void:
	transitions.transition(_switch_to_game, TransitionScreen.TransitionPoint.MIDDLE)

func _on_click_options() -> void:
	pass

func _switch_to_game() -> void:
	get_tree().change_scene_to_file("res://main scene.tscn")

func _on_hover_start_game() -> void:
	_set_ambience_light_maximized(true)
	start_game_button.grab_focus()
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
	pass

func _on_unhover_start_game() -> void:
	_set_ambience_light_maximized(false)
	if get_viewport().gui_get_focus_owner() == start_game_button:
		start_game_button.release_focus()
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	pass

func _on_hover_options() -> void:
	_set_ambience_light_maximized(true)
	ambience_lights.position = options_ambience_light_position
	options_button.grab_focus()
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)

func _on_unhover_options() -> void:
	_set_ambience_light_maximized(false)
	ambience_lights.position = default_ambience_light_position
	if get_viewport().gui_get_focus_owner() == options_button:
		options_button.release_focus()
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)

func _set_ambience_light_maximized(maximized: bool) -> void:
	if maximized:
		ambience_lights.energy = ambience_light_on_hover
	else:
		ambience_lights.energy = original_ambience_light_energy
