extends Node2D

var parallax_background_offset: Vector2 = Vector2(0, 0)
@onready var parallax_background:  ParallaxBackgroundController = %ParallaxBackground
@export var vector_offset: Vector2 = Vector2(0, 0)
var init_offset: Vector2 = Vector2(0, 0)

func _ready() -> void:
	var parent: Issue = get_parent()

	if parent != null:
		vector_offset = parent.spawn_position
	
	init_offset = parallax_background.offset

func _process(_delta: float) -> void:
	parallax_background.offset = init_offset + (vector_offset * 2)
