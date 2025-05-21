class_name AngleDifference

static func angle_difference(from: float, to: float) -> float:
	var diff = fmod(to - from + PI, TAU) - PI
	return diff if diff >= -PI else diff + TAU