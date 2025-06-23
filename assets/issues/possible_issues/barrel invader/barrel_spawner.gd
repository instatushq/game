class_name BarrelSpawner extends Node2D

@export var camera: Camera2D = null

func _get_camera_top_edge_y() -> float:
	var viewport_distance: Vector2 = camera.get_viewport_rect().size / camera.zoom
	var distance_y = viewport_distance.y / 2
	var camera_top_edge_y = camera.global_position.y - distance_y
	return camera_top_edge_y

func _process(_delta: float) -> void:
	var top_edge = _get_camera_top_edge_y()
	global_position = Vector2(camera.global_position.x, top_edge)
	queue_redraw()

func _draw() -> void:
	var viewport_distance: Vector2 = Vector2(0, 0)
	draw_circle(viewport_distance, 50, Color.RED)
