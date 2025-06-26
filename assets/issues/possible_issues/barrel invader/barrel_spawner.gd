class_name BarrelSpawner extends Node2D

@export var camera: Camera2D = null
@export var noise_texture: FastNoiseLite = null


var texture: ImageTexture
var points_centroids = []
var density_calculator: GridDensityCalculator = null

func _ready() -> void:
	points_centroids = PointsCenteroids.get_cell_centers(noise_texture, _get_camera_dimensions(), 0.92)
	density_calculator = GridDensityCalculator.new(points_centroids, 1000)

func _get_camera_top_edge_y() -> float:
	var viewport_distance: Vector2 = camera.get_viewport_rect().size / camera.zoom
	var distance_y = viewport_distance.y / 2
	var camera_top_edge_y = camera.global_position.y - distance_y
	return camera_top_edge_y

func _get_camera_dimensions() -> Vector2:
	var viewport_distance: Vector2 = camera.get_viewport_rect().size / camera.zoom
	return viewport_distance

func _process(_delta: float) -> void:
	var top_edge = _get_camera_top_edge_y()
	global_position = Vector2(camera.global_position.x, top_edge)
	queue_redraw()

func _draw() -> void:
	var viewport_distance: Vector2 = _get_camera_dimensions()
	if points_centroids.size() == 0: return
	for point in points_centroids:
		var point_position: Vector2 = Vector2(point.x - (viewport_distance.x / 2), point.y) # relative to the camera center
		var density = density_calculator.get_density_at(point, 125)
		var alpha = density / 6.0
		draw_circle(point_position, 5, Color(1, 1, 1, alpha))
		draw_string(ThemeDB.fallback_font, point_position, str(density), 0, -1, 16, Color.RED)
