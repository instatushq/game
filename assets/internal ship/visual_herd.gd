class_name VisualHerd extends Node2D

@export var asteroids_scenes: Array[PackedScene] = []
@onready var asteroids_container = $Asteriods

signal on_asteroid_impacted

func _spawn_asteroid() -> void:
	var random_asteroid = asteroids_scenes.pick_random()
	var asteroid_instance: CosmeticAsteroid = random_asteroid.instantiate()
	asteroid_instance.impacted_ship.connect(func(): on_asteroid_impacted.emit())
	asteroids_container.add_child(asteroid_instance)

func _on_spawn_timer_timeout() -> void:
	_spawn_asteroid()
