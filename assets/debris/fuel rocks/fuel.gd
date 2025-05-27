extends Node2D

var ship_direction: Vector2 = Vector2.ZERO
@onready var rb: ShipImpacter = $"Ship Impacter"
@export var max_hits_to_break = 5
var times_hit: int = 0

var SPEED: int = 13
# var MIN_SCALE: float = 8
# var MAX_SCALE: float = 20

func _ready() -> void:
	ship_direction = Vector2.DOWN * SPEED
	# var random_scale = randf_range(MIN_SCALE, MAX_SCALE)
	# global_scale = Vector2(random_scale, random_scale)
	
func _physics_process(_delta: float) -> void:
	rb.linear_velocity = ship_direction * SPEED

func _release_fuel() -> void:
	var ship_fuel: ShipFuel = get_tree().get_current_scene().get_node("%Ship/Fuel")
	ship_fuel.increase_fuel(randf_range(7, 15))

func _on_ship_impacter_on_shot(laser_bullet: Node2D) -> void:
	times_hit += 1
	if times_hit >= max_hits_to_break:
		_release_fuel()
		queue_free()
	
	laser_bullet.queue_free()

func _on_ship_impacter_on_impact_ship(_ship: Node2D, _current_impact_count: int, _max_impact_count: int) -> void:
	_release_fuel()
	queue_free()
