extends Node2D

@export var score: int = 0;
@export var score_increment_amount: int = 1;


func _physics_process(delta: float) -> void:
	score += 1;


func _on_score_timer_timeout() -> void:
	var currentScore: int = score;
	score = currentScore + score_increment_amount;

signal score_change(old_value: int, new_value: int)
