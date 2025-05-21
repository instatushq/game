extends Camera2D

@export var margin: Vector2 = Vector2(100, 100)  # X and Y margins for camera movement
@export var smoothing_speed: float = 5.0  # Camera movement smoothing speed

var initial_position: Vector2
var target_position: Vector2

func _ready() -> void:
	initial_position = position
	target_position = initial_position

func _process(delta: float) -> void:
	var viewport_size = get_viewport_rect().size
	var mouse_pos = get_viewport().get_mouse_position()
	
	var normalized_x = (mouse_pos.x / viewport_size.x) * 2 - 1
	var normalized_y = (mouse_pos.y / viewport_size.y) * 2 - 1
	
	target_position = initial_position + Vector2(
		normalized_x * margin.x,
		normalized_y * margin.y
	)
	
	position = position.lerp(target_position, delta * smoothing_speed)
