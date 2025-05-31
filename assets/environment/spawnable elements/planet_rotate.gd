extends Node2D

class_name planet_script

@onready var visual_container: Node2D = $Container
@onready var ring: Node2D = $Container/Ring

func _ready() -> void:
	ring.visible = has_ring
