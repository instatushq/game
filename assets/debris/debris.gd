extends Node2D

var ship_direction: Vector2 = Vector2.ZERO
@onready var rb: ShipImpacter = $"Ship Impacter"
var game_manager: GameManager = null
var times_hit: int = 0

var SPEED: int = 13

func _ready() -> void:
	ship_direction = Vector2.DOWN * SPEED
	game_manager = get_tree().get_current_scene().get_node("%GameManager")
	
func _physics_process(_delta: float) -> void:
	if game_manager.current_player == GameManager.Player.SHIP:
		rb.linear_velocity = ship_direction * SPEED
		# Rotate to face movement direction with 34 degree offset
	else:
		rb.linear_velocity = Vector2.ZERO

func _on_ship_impacter_on_shot(laser_bullet: Node2D) -> void:
	times_hit += 1
	if times_hit >= 3:
		queue_free()
	
	laser_bullet.queue_free()

func _on_ship_impacter_on_impact_ship(_ship: Node2D, _current_impact_count: int, _max_impact_count: int) -> void:
	queue_free()
