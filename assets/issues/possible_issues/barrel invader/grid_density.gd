class_name GridDensityCalculator extends Node2D

var cell_size := 50.0  # size of grid square
var grid := {}  # Dictionary with keys as Vector2(x, y) and values as array of Vector2 points
var points: Array[Vector2] = []  # Array of all points for easy access

func _init(points_array: Array[Vector2], cell_size_val: float):
	cell_size = cell_size_val
	grid.clear()
	points = points_array.duplicate()  # Store a copy of the points array

	for point in points:
		var cell := get_cell(point)
		if not grid.has(cell):
			grid[cell] = []
		grid[cell].append(point)

func get_cell(pos: Vector2) -> Vector2:
	return Vector2(floor(pos.x / cell_size), floor(pos.y / cell_size))

func get_density_at(pos: Vector2, radius: float) -> int:
	var radius_squared := radius * radius
	var cell_min := get_cell(pos - Vector2(radius, radius))
	var cell_max := get_cell(pos + Vector2(radius, radius))

	var count := 0

	for x in range(cell_min.x, cell_max.x + 1):
		for y in range(cell_min.y, cell_max.y + 1):
			var cell := Vector2(x, y)
			if grid.has(cell):
				for point in grid[cell]:
					if pos.distance_squared_to(point) <= radius_squared:
						count += 1

	return count

func delete_point(point: Vector2) -> bool:
	# Remove from points array
	var index = points.find(point)
	if index != -1:
		points.remove_at(index)
		
		# Remove from grid
		var cell := get_cell(point)
		if grid.has(cell):
			var cell_points = grid[cell]
			var cell_index = cell_points.find(point)
			if cell_index != -1:
				cell_points.remove_at(cell_index)
				# Remove empty cells from grid
				if cell_points.is_empty():
					grid.erase(cell)
				return true
	return false

func get_sorted_points_by_density_and_x(radius: float) -> Array[Vector3]:
	var sorted_points: Array[Vector3] = []
	for point in points:
		var density = get_density_at(point, radius)
		sorted_points.append(Vector3(point.x, point.y, density))
	sorted_points.sort_custom(func(a, b): return a.z < b.z or (a.z == b.z and a.x < b.x))
	return sorted_points
