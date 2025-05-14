extends Node2D

class_name planet_script

@onready var visual_container: Node2D = $Container
@onready var ring: Node2D = $Container/Ring
@export var rotation_speed: float = 0.0003
@export var has_ring: bool = false
var rotation_direction_movement: bool = false
var temporary_timer_node: Timer = null

func _ready() -> void:
	ring.visible = has_ring

func randomize_planets_look() -> void:
	rotation_direction_movement = randi_range(0, 100) > 50
	#visual_container.scale = Vector2(1 if randi_range(0, 100) > 50 else -1, 1)

func _on_update_off_screen() -> void:
	randomize_planets_look()

func _physics_process(_delta: float) -> void:
	if rotation_direction_movement:
		visual_container.rotation += rotation_speed
	else:
		visual_container.rotation -= rotation_speed
