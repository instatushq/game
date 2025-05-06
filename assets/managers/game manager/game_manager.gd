extends Node2D

class_name GameManager

enum Player {
	SHIP,
	ASTRONAUT
}

@onready var ship: Ship = get_node("%Ship")
@onready var astronaut: Astronaut = get_node("%Astronaut")
@onready var camera: Camera = get_node("%Camera")

@export var current_player: Player = Player.SHIP

signal score_changed(old_value: int, new_value: int)

@export var score: int = 0
@export var score_increment_amount: int = 1

func _on_score_timer_timeout() -> void:
	increaseScore()

func increaseScore(amount: int = score_increment_amount):
	var currentScore: int = score
	score = currentScore + amount
	emit_signal("score_changed", currentScore, score)

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_T:
			switch_controlled_player_to(Player.ASTRONAUT if is_controlling_ship() else Player.SHIP)

func switch_controlled_player_to(player: Player) -> void:
	match player:
		Player.SHIP:
			switch_to_ship()
		Player.ASTRONAUT:
			switch_to_astronaut()

func is_controlling_ship() -> bool:
	return current_player == Player.SHIP

func is_controlling_astronaut() -> bool:
	return current_player == Player.ASTRONAUT

func switch_to_ship() -> void:
	current_player = Player.SHIP
	astronaut.toggle_control(false)
	ship.toggle_control(true)
	camera.focus_ship()

func switch_to_astronaut() -> void:
	current_player = Player.ASTRONAUT
	astronaut.toggle_control(true)
	ship.toggle_control(false)
	camera.focus_astronaut()
