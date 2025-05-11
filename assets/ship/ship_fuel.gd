extends Node2D

class_name ShipFuel;

@export var fuel: float = 100
@export var fuel_spending_rate = 1
@onready var game_manager: GameManager = get_tree().get_current_scene().get_node("%GameManager")

func _physics_process(_delta: float) -> void:
	if game_manager.current_player == GameManager.Player.SHIP:
		decrease_fuel(fuel_spending_rate)

signal on_fuel_change(old_fuel: float, new_fuel: float)

func increase_fuel(fuel_amount: float) -> void:
	var new_fuel = clamp(fuel_amount + fuel, 0, 100)
	on_fuel_change.emit(fuel, new_fuel)
	fuel = new_fuel

func decrease_fuel(fuel_amount: float) -> void:
	var new_fuel = clamp(fuel - fuel_amount, 0, 100)
	on_fuel_change.emit(fuel, new_fuel)
	fuel = new_fuel

func set_fuel(fuel_amount: float) -> void:
	var new_fuel = clamp(fuel_amount, 0, 100)
	on_fuel_change.emit(fuel, new_fuel)
	fuel = new_fuel
