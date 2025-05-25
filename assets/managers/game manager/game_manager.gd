extends Node2D

class_name GameManager

enum Player {
	SHIP,
	ASTRONAUT
}

@onready var ship: Ship = %Ship
@onready var ship_health: ShipHealth = %Ship/Health
@onready var astronaut: Astronaut = %Astronaut
@onready var camera: Camera = %Camera
@onready var timer: Timer = $ScoreTimer
@onready var meteor_herd_timer: Timer = $MeteorHerdTimer
@onready var meteor_herd_warning_timer: Timer = $MeteorHerdWarning
@onready var meteor_herd_ending_timer: Timer = $MeteorHerdEnd

@export var current_player: Player = Player.SHIP

signal score_changed(old_value: int, new_value: int)
signal current_player_changed(new_current_player: Player)
signal meteor_herd_triggered
signal meteor_herd_warning
signal meteor_herd_buffered
signal meteor_herd_sequence_started
signal meteor_herd_ended
signal meteor_herd_value_changed(new_value: int)


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

func _ready() -> void:
	meteor_herd_warning.connect(_on_meteor_herd_warning)
	if play_music:
		music.play()

func _physics_process(_delta: float) -> void:
	if not meteor_herd_ending_timer.is_stopped() and not meteor_herd_ending_timer.paused:
		meteor_herd_value_changed.emit(meteor_herd_ending_timer.time_left)

func _on_score_timer_timeout() -> void:
	increaseScore()

func increaseScore(amount: int = score_increment_amount):
	var currentScore: int = score
	score = currentScore + amount
	game_stats.current_score = score
	score_changed.emit(currentScore, score)

func _process(_delta: float) -> void:
	if meteor_herd_buffered_for_puzzle and not is_solving_puzzle:
		meteor_herd_buffered_for_puzzle = false
		meteor_herd_warning.emit()

	timepassed += 1
	if timepassed == 2:
		switch_player(Player.ASTRONAUT)

func _switch_to_ship_view() -> void:
	meteor_herd_sequence_started.emit()
	switch_player(Player.SHIP)

func _switch_to_astronaut_view() -> void:
	switch_player(Player.ASTRONAUT)

func switch_player(player: Player) -> void:
	match player:
		Player.SHIP: _switch_to_ship()
		Player.ASTRONAUT: _switch_to_astronaut()

	current_player_changed.emit(player)
	if player == Player.SHIP:
		timer.start()
	else:
		timer.stop()

func is_controlling_ship() -> bool:
	return current_player == Player.SHIP

func is_controlling_astronaut() -> bool:
	return current_player == Player.ASTRONAUT

func _switch_to_ship() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	Input.warp_mouse(last_mouse_position)
	current_player = Player.SHIP
	astronaut.toggle_control(false)
	ship.toggle_control(true)
	camera.focus_ship()

func _switch_to_astronaut() -> void:
	last_mouse_position = get_viewport().get_mouse_position()
	current_player = Player.ASTRONAUT
	astronaut.toggle_control(true)
	ship.toggle_control(false)
	camera.focus_astronaut()
	var viewport_center = get_viewport_rect().size / 2
	Input.warp_mouse(viewport_center)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_meteor_herd_timer_timeout() -> void:
	if randf_range(0, 100) <= meteor_herd_chance and not is_meteor_herd_active:
		meteor_herd_buffered_for_puzzle = true
		is_meteor_herd_active = true
		meteor_herd_buffered.emit()

func _on_meteor_herd_warning() -> void:
	meteor_herd_warning_timer.start()
	meteor_herd_triggered.emit()

func _on_meteor_herd_warning_timeout() -> void:
	transition_screen.transition(_switch_to_ship_view, TransitionScreen.TransitionPoint.MIDDLE)
	timer.stop()
	meteor_herd_ending_timer.start()

func _on_meteor_herd_end_timeout() -> void:
	timer.start()
	is_meteor_herd_active = false
	transition_screen.transition(_switch_to_astronaut_view, TransitionScreen.TransitionPoint.MIDDLE)
	meteor_herd_ended.emit()

func _on_ship_damage_timer_timeout() -> void:
	if current_player == Player.ASTRONAUT:
		ship_health.decrease_health(randi_range(1, 3))
