extends Node2D

@export_range(0, 30) var blackhole_rotation_multiplier: float = 30

func _ready() -> void:
	rotation_degrees = randf_range(-blackhole_rotation_multiplier, blackhole_rotation_multiplier)    
