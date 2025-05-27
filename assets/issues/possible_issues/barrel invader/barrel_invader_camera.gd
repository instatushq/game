extends Camera2D

@export var movement_speed: float = 100.0

func _physics_process(_delta: float) -> void:
	global_position.y -= movement_speed * _delta
