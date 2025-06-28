class_name BarrelSpawner extends Node2D

const MAX_DENSITY: int = 5

@export_category("ASSIGNABLES")
@export var camera: Camera2D = null
@export var noise_texture: FastNoiseLite = null
@export var normal_barrel_scene: PackedScene = null
@export var tnt_barrel_scene: PackedScene = null
@export var nuke_barrel_scene: PackedScene = null
@export var slot_barrel_scene: PackedScene = null
@export var barrels_container: Node2D = null

var rng = RandomNumberGenerator.new()
var texture: ImageTexture
var points_centroids: Array[Vector2] = []
var density_calculator: GridDensityCalculator = null
var next_y_to_spawn: float = 0

func _spawn_batch(center: Vector2, radius: float) -> void:
	var cells_centroids = PointsCenteroids.get_cell_centers(noise_texture, _get_camera_dimensions(), 0.92)
	var density_calculator_grid = GridDensityCalculator.new(cells_centroids, 50)
	var sorted_points: Array[Vector3] = density_calculator_grid.get_sorted_points_by_density_and_x(radius)
	for point in sorted_points:
		var point_position: Vector2 = Vector2(point.x, point.y)
		var point_density = point.z

		var barrel_type = _get_barrel_spawn(point_density)
		var barrel_scene: PackedScene = null
		match barrel_type:
			BARREL_TYPE.NORMAL:
				barrel_scene = normal_barrel_scene
			BARREL_TYPE.TNT:
				barrel_scene = tnt_barrel_scene
			BARREL_TYPE.NUKE:
				barrel_scene = nuke_barrel_scene
			BARREL_TYPE.SLOT:
				barrel_scene = slot_barrel_scene
				
		if barrel_scene == null: continue

		var barrel = barrel_scene.instantiate()
		var spawn_position = point_position + center
		barrel.global_position = spawn_position
		barrels_container.add_child(barrel)
		density_calculator_grid.delete_point(point_position)

	# shift the texture y to get different spawn points
	noise_texture.offset.y += 1000

enum BARREL_TYPE {
	NORMAL,
	TNT,
	NUKE,
	SLOT
}

func _get_barrel_spawn(density: int) -> BARREL_TYPE:
	const density_one_weights = [1, 0.1, 0.15, 0.05]
	const density_two_weights = [1, 0.1, 0.15, 0.05]
	const density_three_weights = [1, 0.1, 0.15, 0.05]
	const density_four_weights = [1, 0.1, 0.15, 0.05]
	const max_density_weights = [1, 0.1, 0.15, 0.05]

	var used_weights = [1, 1, 1, 1]

	if density >= MAX_DENSITY:
		used_weights = max_density_weights
	elif density == 4:
		used_weights = density_four_weights
	elif density == 3:
		used_weights = density_three_weights
	elif density == 2:
		used_weights = density_two_weights
	elif density == 1:
		used_weights = density_one_weights
	
	var random_index = rng.rand_weighted(used_weights)
	return BARREL_TYPE.values()[random_index]

func _ready() -> void:
	var camera_dimensions = _get_camera_dimensions()
	_spawn_batch(Vector2(camera.global_position.x - camera_dimensions.x / 2, _get_camera_top_edge_y() - _get_camera_dimensions().y), 125)
	next_y_to_spawn = _get_camera_top_edge_y() - _get_camera_dimensions().y

func _get_camera_top_edge_y() -> float:
	var viewport_distance: Vector2 = camera.get_viewport_rect().size / camera.zoom
	var distance_y = viewport_distance.y / 2
	var camera_top_edge_y = camera.global_position.y - distance_y
	return camera_top_edge_y

func _get_camera_dimensions() -> Vector2:
	var viewport_distance: Vector2 = camera.get_viewport_rect().size / camera.zoom
	return viewport_distance

func _physics_process(_delta: float) -> void:
	var top_edge = _get_camera_top_edge_y()
	global_position = Vector2(camera.global_position.x, top_edge)
	if top_edge <= next_y_to_spawn:
		next_y_to_spawn = _get_camera_top_edge_y() - _get_camera_dimensions().y
		var camera_dimensions = _get_camera_dimensions()
		_spawn_batch(Vector2(camera.global_position.x - camera_dimensions.x / 2, _get_camera_top_edge_y() - _get_camera_dimensions().y), 125)
