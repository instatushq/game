extends ParallaxBackground

@export var scroll_speed: float = 75.0

func _physics_process(_delta: float) -> void:
	scroll_base_offset.y += scroll_speed * _delta
	scroll_base_offset.y = wrapf(scroll_base_offset.y, -50000, 50000)
