class_name PoissonDiscSampling

static func generate_points(
		radius: float,
		region_size: Vector2,
		num_samples_before_rejection: int = 30,
		position: Vector2 = Vector2.ZERO
	) -> PackedVector2Array:
	var cell_size: float = radius / sqrt(2.0)
	
	# Calculate the actual sample region size (twice the region_size since it's from center)
	var sample_region_size: Vector2 = region_size * 2.0
	
	var grid_width: int = int(ceil(sample_region_size.x / cell_size))
	var grid_height: int = int(ceil(sample_region_size.y / cell_size))
	var grid: Array = []
	for x in range(grid_width):
		grid.append([])
		for y in range(grid_height):
			grid[x].append(-1)

	var points: PackedVector2Array = PackedVector2Array()
	var spawn_points: Array = []

	# Start from the center of the region
	spawn_points.append(Vector2.ZERO)

	while spawn_points.size() > 0:
		var spawn_index: int = randi_range(0, spawn_points.size() - 1)
		var spawn_center: Vector2 = spawn_points[spawn_index]
		var candidate_accepted: bool = false

		for i in range(num_samples_before_rejection):
			var angle: float = randf() * PI * 2
			var dir: Vector2 = Vector2(sin(angle), cos(angle))
			var candidate: Vector2 = spawn_center + dir * randf_range(radius, 2 * radius)

			if _is_valid(candidate, region_size, cell_size, radius, points, grid):
				points.append(candidate)
				spawn_points.append(candidate)
				var cell_x = int((candidate.x + region_size.x) / cell_size)
				var cell_y = int((candidate.y + region_size.y) / cell_size)
				grid[cell_x][cell_y] = points.size() - 1
				candidate_accepted = true
				break

		if not candidate_accepted:
			spawn_points.remove_at(spawn_index)

	# Offset all points by the position parameter
	for i in range(points.size()):
		points[i] += position

	return points


static func _is_valid(candidate: Vector2, region_size: Vector2, cell_size: float, radius: float, points: Array, grid: Array) -> bool:
	# Check if the point is within the region (centered around origin)
	if candidate.x >= -region_size.x and candidate.x < region_size.x and candidate.y >= -region_size.y and candidate.y < region_size.y:
		var cell_x = int((candidate.x + region_size.x) / cell_size)
		var cell_y = int((candidate.y + region_size.y) / cell_size)

		var search_start_x = max(0, cell_x - 2)
		var search_end_x = min(cell_x + 2, grid.size() - 1)
		var search_start_y = max(0, cell_y - 2)
		var search_end_y = min(cell_y + 2, grid[0].size() - 1)

		for x in range(search_start_x, search_end_x + 1):
			for y in range(search_start_y, search_end_y + 1):
				var point_index = grid[x][y]
				if point_index != -1:
					var sqr_dist = candidate.distance_squared_to(points[point_index])
					if sqr_dist < radius * radius:
						return false
		return true
	return false
