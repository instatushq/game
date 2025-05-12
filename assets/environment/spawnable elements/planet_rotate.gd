extends ParallaxLayer

var rotation_direction_movement: bool = false
@export var rotation_speed: float = 0.0003

func _ready() -> void:
	rotation_direction_movement = randi_range(0, 100) > 50

func _physics_process(_delta: float) -> void:
	if rotation_direction_movement:
		rotation += rotation_speed
	else:
		rotation -= rotation_speed
