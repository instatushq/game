extends Node2D

@export var asteroids_scenes: Array[PackedScene] = []
@onready var asteroids_container = $Asteriods

func _spawn_asteroid() -> void:
	var random_asteroid: PackedScene = asteroids_scenes.pick_random()
	var asteroid_instance = random_asteroid.instantiate()
	asteroids_container.add_child(asteroid_instance)

func _on_spawn_timer_timeout() -> void:
	_spawn_asteroid()
