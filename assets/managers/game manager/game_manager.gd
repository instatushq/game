extends Node2D

class_name GameManager

signal on_death
var is_dead_already: bool = false

enum Player {
	ASTRONAUT
}

@onready var ship_health: ShipHealth = %InternalShip/Health
@onready var astronaut: Astronaut = %Astronaut
@onready var camera: Camera = %Camera
@onready var timer: Timer = $ScoreTimer
@onready var screen_transition: TransitionScreen = %"Transition Screen"

@export var current_player: Player = Player.ASTRONAUT

signal score_changed(old_value: int, new_value: int)
signal current_player_changed(new_current_player: Player)
signal on_solving_puzzle_changed(is_solving_puzzle: bool)


@export_range(0, 100) var meteor_herd_chance: float = 80.0
var meteor_herd_buffered_for_puzzle: bool = false
var is_meteor_herd_active: bool = false

@export var score: int = 0
@export var score_increment_amount: int = 1
@export var play_music: bool = false
@onready var music: AudioStreamPlayer = Music
@onready var game_stats: GameStats = Stats
@onready var transition_screen: TransitionScreen = %"Transition Screen"
var last_mouse_position: Vector2 = Vector2.ZERO
var timepassed: int = 0
var is_solving_puzzle: bool = false
var last_is_solving_puzzle: bool = is_solving_puzzle

func _ready() -> void:
	ship_health.on_health_change.connect(_on_readings_change)
	on_death.connect(_on_astronaut_death)
	if play_music:
		music.play()
	
func _on_score_timer_timeout() -> void:
	increaseScore()

func increaseScore(amount: int = score_increment_amount):
	var currentScore: int = score
	score = currentScore + amount
	game_stats.current_score = score
	score_changed.emit(currentScore, score)

func _process(_delta: float) -> void:
	if is_solving_puzzle != last_is_solving_puzzle:
		on_solving_puzzle_changed.emit(is_solving_puzzle)
		last_is_solving_puzzle = is_solving_puzzle
		
	timepassed += 1
	if timepassed == 2:
		_switch_to_astronaut()
		current_player_changed.emit(current_player)
		timer.start()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_N:
		on_death.emit()

func _switch_to_astronaut() -> void:
	last_mouse_position = get_viewport().get_mouse_position()
	current_player = Player.ASTRONAUT
	astronaut.toggle_control(true)
	camera.focus_astronaut()
	var viewport_center = get_viewport_rect().size / 2
	Input.warp_mouse(viewport_center)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _on_ship_damage_timer_timeout() -> void:
	ship_health.decrease_health(randi_range(1, 3))

func _on_readings_change(_old_value: float, new_value: float) -> void:
	if new_value <= 0 and not is_dead_already:
		is_dead_already = true
		on_death.emit()

func _switch_to_game_over() -> void:
	screen_transition.transition(func():
		get_tree().change_scene_to_file("res://assets/game over/game over.tscn")
	,TransitionScreen.TransitionPoint.MIDDLE)

func _on_astronaut_death() -> void:
	var death_timer = Timer.new()
	add_child(death_timer)
	death_timer.one_shot = true
	death_timer.wait_time = 1.5
	death_timer.timeout.connect(func(): 
		_switch_to_game_over()
		death_timer.queue_free()
	)
	death_timer.start()
