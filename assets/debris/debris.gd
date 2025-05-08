extends Node2D

var ship_direction: Vector2 = Vector2.ZERO
@onready var rb: ShipImpacter = $"Ship Impacter"
var game_manager: GameManager = null

var SPEED: int = 15

func _ready() -> void:
	var ship: Ship = get_tree().get_current_scene().get_node("%Ship")
	var ship_rb: RigidBody2D = ship.get_node("RigidBody2D")
	var angle = rb.global_position.angle_to_point(ship_rb.global_position)
	var new_velocity = Vector2.from_angle(angle) * SPEED
	rb.linear_velocity = new_velocity
	ship_direction = new_velocity
	game_manager = get_tree().get_current_scene().get_node("%GameManager")
	var distance_to_ship = rb.global_position.distance_to(ship_rb.global_position)
	if distance_to_ship > 500:
		SPEED = 20
	
func _physics_process(_delta: float) -> void:
	if game_manager.current_player == GameManager.Player.SHIP:
		rb.linear_velocity = ship_direction * SPEED
		# Rotate to face movement direction with 34 degree offset
		rotation = ship_direction.angle()
	else:
		rb.linear_velocity = Vector2.ZERO

func _on_ship_impacter_on_shot(laser_bullet: Node2D) -> void:
	queue_free()
	laser_bullet.queue_free()

func _on_ship_impacter_on_impact_ship(_ship: Node2D, _current_impact_count: int, _max_impact_count: int) -> void:
	queue_free()
