extends Node2D

class_name GameManager

signal score_changed(old_value: int, new_value: int)

@export var score: int = 0
@export var score_increment_amount: int = 1
@export var base_travelling_speed: float = 100.0

func _on_score_timer_timeout() -> void:
	increaseScore()

func increaseScore(amount: int = score_increment_amount):
	var currentScore: int = score
	score = currentScore + amount
	emit_signal("score_changed", currentScore, score)
