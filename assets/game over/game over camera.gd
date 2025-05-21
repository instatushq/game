extends Camera2D

@export var movement_speed: float = 30.0
@export var moving_direction: Vector2 = Vector2.UP

func _physics_process(delta: float) -> void:
	global_position += moving_direction.normalized() * movement_speed * delta
	
