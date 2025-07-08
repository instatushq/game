class_name CameraWalls extends Node2D

@onready var left_wall = $"RigidBody2D/Left Right/Left Wall"
@onready var right_wall = $"RigidBody2D/Left Right/Right Wall"

@export var game_camera: Camera2D = null

var x_position: float = 0.0

func _ready() -> void:
	_adjust_walls()

func _adjust_walls() -> void:
	if game_camera == null:
		return

	var camera_size = game_camera.get_viewport_rect().size / game_camera.zoom
	var camera_x = game_camera.global_position.x
	var distance_from_x = camera_size.x / 2

	left_wall.global_position.x = camera_x - distance_from_x
	right_wall.global_position.x = camera_x + distance_from_x
	x_position = distance_from_x