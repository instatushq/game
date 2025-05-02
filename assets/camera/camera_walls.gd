extends Node2D

@onready var game_manager: GameManager = get_node("%GameManager")
@onready var rb = $RigidBody2D


func _ready() -> void:
	pass
	#var movement_speed = game_manager.base_travelling_speed;
	#rb.add_constant_force(Vector2.UP * movement_speed)
