class_name EnvironmentManager

extends Node2D

@onready var background_controller: ParallaxBackgroundController = %ParallaxBackground
var list_of_celestials: Array = []
@export var max_background_segments: int = 3
var camera: Camera2D
var last_recorded_y: float = 0
const SEGMENT_DISTANCE: float = 400.0

func _ready() -> void:
	camera = get_viewport().get_camera_2d()
	_spawn_and_save_celestial_objects()

func _spawn_and_save_celestial_objects() -> void:
	last_recorded_y = camera.global_position.y
	var viewport_size = get_viewport_rect().size
	list_of_celestials.append(background_controller.generate_background_segment(camera.global_position.y, camera.global_position.x + (viewport_size.x / 4), viewport_size.y, viewport_size.x))
	if list_of_celestials.size() == 3:
		var oldest_list = list_of_celestials[0]
		for node in oldest_list:
			node.queue_free()

		list_of_celestials.remove_at(0)
	
	queue_redraw()

func _physics_process(_delta: float) -> void:
	var viewport_size = get_viewport_rect().size
	var camera_top_border_y = camera.global_position.y - (viewport_size.y / 4)
	if camera_top_border_y < last_recorded_y - viewport_size.y - SEGMENT_DISTANCE:
		_spawn_and_save_celestial_objects()
