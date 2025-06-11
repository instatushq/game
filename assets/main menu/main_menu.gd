extends Node2D

@export var ambience_light_on_hover: float = 42.0
@onready var transitions: TransitionScreen = $"Transition Screen"
@onready var ambience_lights: Light2D = $Ship/Body/Lights/Ambience
@onready var start_game_button: Button = $"Ship/Control/Start Game"
@onready var options_button: Button = $Ship/Control/Node2D/Options
@onready var music_button: Button = $Ship/Control/Node2D/Music
@onready var sfx_button: Button = $Ship/Control/Node2D/SFX
@onready var menu_astronaut: MenuAstronaut = $Astronaut
@onready var menu_hover_sound: AudioStreamPlayer = $MenuHover
@onready var menu_click_sound: AudioStreamPlayer = $MenuClick
@onready var start_game_sound: AudioStreamPlayer = $StartGame
var menu_click_sound_offset: float = 0.05
var original_ambience_light_energy: float = 0.0
var default_ambience_light_position: Vector2 = Vector2(0, -21)
var options_ambience_light_position: Vector2 = Vector2(-64.0, -14.0)
var music_ambience_light_position: Vector2 = Vector2(-64.0, -20.0)
var sfx_ambience_light_position: Vector2 = Vector2(-64.0, -6.0)

var music_bus = AudioServer.get_bus_index("Music")
var sfx_bus = AudioServer.get_bus_index("Sound FX")

func _process(_delta: float) -> void:
	menu_astronaut.stand_away_from_mouse = not options_button.visible

func _ready() -> void:
	transitions.on_transition_finish.connect(_switch_to_game)
	original_ambience_light_energy = ambience_lights.energy
	ambience_lights.position = default_ambience_light_position
	music_button.visible = false
	sfx_button.visible = false
	options_button.visible = true
	# Set up input handling for tab
	set_process_input(true)
	# Connect focus signals
	music_button.focus_entered.connect(_on_music_focus_entered)
	sfx_button.focus_entered.connect(_on_sfx_focus_entered)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_focus_next") and get_viewport().gui_get_focus_owner() == null:
		options_button.grab_focus()
	elif event.is_action_pressed("ui_cancel") or event.is_action_pressed("ui_focus_prev"):
		if get_viewport().gui_get_focus_owner() != null:
			get_viewport().gui_get_focus_owner().release_focus()
			# If we're in options menu, hide it and show options button
			if music_button.visible and sfx_button.visible:
				music_button.visible = false
				sfx_button.visible = false
				options_button.visible = true
				ambience_lights.position = default_ambience_light_position

func _on_click_start_game() -> void:
	transitions.transition(_switch_to_game, TransitionScreen.TransitionPoint.MIDDLE)
	start_game_sound.play()

func _on_click_options() -> void:
	options_button.visible = false
	music_button.visible = true
	sfx_button.visible = true
	music_button.grab_focus()
	ambience_lights.position = music_ambience_light_position
	menu_click_sound.play(menu_click_sound_offset)

func _switch_to_game() -> void:
	get_tree().change_scene_to_file("res://main scene.tscn")

func _on_hover_start_game() -> void:
	menu_hover_sound.play(0.1)
	_set_ambience_light_maximized(true)
	start_game_button.grab_focus()
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
	if music_button.visible and sfx_button.visible:
		music_button.visible = false
		sfx_button.visible = false
		options_button.visible = true
		ambience_lights.position = default_ambience_light_position

func _on_unhover_start_game() -> void:
	_set_ambience_light_maximized(false)
	if get_viewport().gui_get_focus_owner() == start_game_button:
		start_game_button.release_focus()
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)

func _on_hover_options() -> void:
	menu_hover_sound.play(0.1)
	if not music_button.visible and not sfx_button.visible:
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

func _on_music_focus_entered() -> void:
	_set_ambience_light_maximized(true)
	ambience_lights.position = music_ambience_light_position

func _on_sfx_focus_entered() -> void:
	_set_ambience_light_maximized(true)
	ambience_lights.position = sfx_ambience_light_position

func _on_music_pressed() -> void:
	AudioServer.set_bus_mute(music_bus, not AudioServer.is_bus_mute(music_bus))
	music_button.text = "Music: " + ("On" if not AudioServer.is_bus_mute(music_bus) else "Off")
	music_button.grab_focus()
	menu_click_sound.play(menu_click_sound_offset)

func _on_sfx_pressed() -> void:
	AudioServer.set_bus_mute(sfx_bus, not AudioServer.is_bus_mute(sfx_bus))
	sfx_button.text = "SFX: " + ("On" if not AudioServer.is_bus_mute(sfx_bus) else "Off")
	sfx_button.grab_focus()
	menu_click_sound.play(menu_click_sound_offset)