extends ParallaxLayer

@onready var visual_container: Node2D = $Container
@onready var ring: Node2D = $Container/Ring
@export var rotation_speed: float = 0.0003
var rotation_direction_movement: bool = false

func _ready() -> void:
	randomize_planets_look()

func randomize_planets_look() -> void:
	rotation_direction_movement = randi_range(0, 100) > 50
	visual_container.scale = Vector2(1 if randi_range(0, 100) > 50 else -1, 1)
	ring.visible = randi_range(0, 100) > 50

func _physics_process(_delta: float) -> void:
	if rotation_direction_movement:
		visual_container.rotation += rotation_speed
	else:
		visual_container.rotation -= rotation_speed
