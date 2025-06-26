class_name PointsCenteroids


static func get_cell_centers(noise_texture: FastNoiseLite, noise_size: Vector2, threshold := 0.9) -> Array:
	var width = roundi(noise_size.x)
	var height = roundi(noise_size.y)
	
	var visited := []
	for x in width:
		visited.append([])
		for y in height:
			visited[x].append(false)

	var centers_with_values := []

	for x in width:
		for y in height:
			if visited[x][y]:
				continue
			var value = noise_texture.get_noise_2d(x, y)
			if value > threshold:
				# BFS for the connected region
				var queue := [Vector2i(x, y)]
				var region := []
				var total_noise := 0.0
				
				while queue.size() > 0:
					var current: Vector2i = queue.pop_front()
					var cx: int = current.x
					var cy: int = current.y

					if cx < 0 or cy < 0 or cx >= width or cy >= height:
						continue
					if visited[cx][cy]:
						continue

					var current_noise = noise_texture.get_noise_2d(cx, cy)
					if current_noise <= threshold:
						continue

					visited[cx][cy] = true
					var pos := Vector2(cx, cy)
					region.append(pos)
					total_noise += current_noise

					queue.append(Vector2i(cx + 1, cy))
					queue.append(Vector2i(cx - 1, cy))
					queue.append(Vector2i(cx, cy + 1))
					queue.append(Vector2i(cx, cy - 1))

				if region.size() > 0:
					var sum := Vector2(0, 0)
					for pos in region:
						sum += pos
					var center := sum / region.size()
					# var avg_noise := total_noise / region.size()
					centers_with_values.append(center)

	return centers_with_values