extends Node2D

class_name GameManager

enum Player {
	SHIP,
	ASTRONAUT
}

@onready var ship: Ship = %Ship
@onready var astronaut: Astronaut = %Astronaut
@onready var camera: Camera = %Camera
@onready var timer: Timer = $ScoreTimer

@export var current_player: Player = Player.SHIP

signal score_changed(old_value: int, new_value: int)
signal current_player_changed(new_current_player: Player)

@export var score: int = 0
@export var score_increment_amount: int = 1
var last_mouse_position: Vector2 = Vector2.ZERO
var timepassed: int = 0

var is_solving_puzzle: bool = false

func _on_score_timer_timeout() -> void:
	increaseScore()

func increaseScore(amount: int = score_increment_amount):
	var currentScore: int = score
	score = currentScore + amount
	emit_signal("score_changed", currentScore, score)

func _process(_delta: float) -> void:
	timepassed += 1
	if timepassed == 2:
		switch_player(Player.ASTRONAUT)

# func _input(event):
# 	if event is InputEventKey and event.pressed:
# 		if event.keycode == KEY_T:
# 			var new_player: Player = Player.ASTRONAUT if is_controlling_ship() else Player.SHIP
# 			switch_player(new_player)

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
