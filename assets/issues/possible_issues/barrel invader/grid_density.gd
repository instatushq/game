class_name GridDensityCalculator extends Node2D

var cell_size := 50.0  # size of grid square
var grid := {}  # Dictionary with keys as Vector2(x, y) and values as array of Vector2 points

func _init(points: Array, cell_size_val: float):
	cell_size = cell_size_val
	grid.clear()

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
