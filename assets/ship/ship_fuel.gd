class_name ShipFuel extends Node2D

@export var fuel: float = 100
@export var fuel_spending_rate = 0.015

func _physics_process(_delta: float) -> void:
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
