class_name RandomColor

static func get_random_color(brightness: float = 1.0, saturation: float = 1.0) -> Color:
	var hue = randf()
	var color = Color.from_hsv(hue, saturation, brightness)
	return color

static func get_random_color_with_alpha(alpha: float = 1.0) -> Color:
	var color = get_random_color()
	color.a = alpha
	return color

static func get_random_pastel_color() -> Color:
	return get_random_color(0.9, 0.5)
