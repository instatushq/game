extends Node2D

@onready var ship_camera: Camera2D = get_node("%Ship/RigidBody2D/Camera2D")
@onready var walls: Array[Node] = get_node("%Walls/RigidBody2D/Left Right").get_children()
@export var debris_objects: Array[PackedScene] = []

func _spawn_batch() -> void:
	var viewport_size = get_viewport().get_visible_rect().size
	var width = abs(walls[0].global_position.x - walls[1].global_position.x)
	var generated_points = PoissonDiscSampling.generate_points(160, Vector2(width, 1000), 30)

	for generated_point in generated_points:
		_spawn_debris(generated_point + Vector2(-820, 0))

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_W:
			#var viewport_size = get_viewport_rect().size
			#var top_center_screen_pos = Vector2(viewport_size.x / 2, 0)  # Top center of the screen
			#var top_center_world_pos = ship_camera.get_global_transform().affine_inverse() * top_center_screen_pos

			_spawn_batch()
			queue_redraw()

func _spawn_debris(spawn_position: Vector2):
	var debris_scene = debris_objects.pick_random()
	var debris_scene_instance = debris_scene.instantiate()
	debris_scene_instance.global_position = spawn_position
	add_child(debris_scene_instance)
