extends Node2D

@onready var stars_layer = $Clip/Stars

func _ready() -> void:
	_randomize_star_layers_frame()

func _randomize_star_layers_frame() -> void:
	if stars_layer == null: return
	for star_layer in stars_layer.get_children():
		if star_layer is AnimatedSprite2D:
			star_layer.frame = randi_range(0, star_layer.sprite_frames.get_frame_count(star_layer.animation) - 1)
