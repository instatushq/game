extends Node2D

class_name ShipHealth;

@export var health: float = 100;

signal on_health_change(old_Health: float, new_health: float)

# func _input(event: InputEvent) -> void:
	# if event is InputEventKey:
	# 	if event.pressed:
	# 		match event.keycode:
	# 			KEY_H:
	# 				set_health(34)
	# 			KEY_J:
	# 				set_health(100)

func increase_health(health_amount: float) -> void:
	var new_health = clamp(health_amount + health, 0, 100)
	on_health_change.emit(health, new_health)
	health = new_health

func decrease_health(health_amount: float) -> void:
	var new_health = clamp(health - health_amount, 0, 100)
	on_health_change.emit(health, new_health)
	health = new_health

func set_health(health_amount: float) -> void:
	var new_health = clamp(health_amount, 0, 100)
	on_health_change.emit(health, new_health)
	health = new_health
