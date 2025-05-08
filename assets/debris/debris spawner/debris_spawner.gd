extends Node2D

@onready var ship_camera: Camera2D = get_node("%Camera")
@onready var walls: Array[Node] = get_node("%Walls/RigidBody2D/Left Right").get_children()
@export var debris_objects: Array[PackedScene] = []
var spawnPositions: Array[Vector2] = []

var grid_size_draw: Vector2 = Vector2(0, 0)
var grid_position_draw: Vector2 = Vector2(0, 0)
const distance_from_camera_top_to_spawn_batch: float = 0
const DISTANCE_BETWEEN_SEGMENTS: float = 100
var next_spawn_y: float = 0
var last_spawn_y: float = 0
var can_spawn: bool = true

func _spawn_batch(y_level: float = 0) -> void:
	var view_port_y_size = 600
	var area_width = 400
	var grid_size = Vector2(area_width, view_port_y_size)
	
	var center_x_position = 150
	var grid_position = Vector2(center_x_position, y_level - grid_size.y - 150)
	grid_size_draw = grid_size
	grid_position_draw = grid_position
	last_spawn_y = y_level
	
	# Set the next spawn trigger position based on camera distance
	next_spawn_y = y_level - grid_size.y - distance_from_camera_top_to_spawn_batch
	
	var generated_points = PoissonDiscSampling.generate_points(170, grid_size, 50, grid_position)

	for point in generated_points:
		spawnPositions.append(point)
		_spawn_debris(point)

	queue_redraw()

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_W:
			spawn_batch_above_player()

func spawn_batch_above_player():
	var viewport_size = get_viewport_rect().size
	var top_center_screen_pos = Vector2(viewport_size.x / 2, 0)  # Top center of the screen
	var top_center_world_pos = ship_camera.get_global_transform().affine_inverse() * top_center_screen_pos
	_spawn_batch(-top_center_world_pos.y)
	queue_redraw()

func _spawn_debris(spawn_position: Vector2):
	var debris_scene = debris_objects.pick_random()
	var debris_scene_instance = debris_scene.instantiate()
	debris_scene_instance.global_position = spawn_position
	add_child(debris_scene_instance)

func _physics_process(_delta: float) -> void:
	var viewport_size = get_viewport_rect().size
	var top_center_screen_pos = Vector2(viewport_size.x / 2, 0)  # Top center of the screen
	var top_center_world_pos = ship_camera.get_global_transform().affine_inverse() * top_center_screen_pos
	
	if -top_center_world_pos.y < next_spawn_y:
		var new_spawn_y = last_spawn_y - grid_size_draw.y - DISTANCE_BETWEEN_SEGMENTS
		_spawn_batch(new_spawn_y)
		queue_redraw()
		

func _ready() -> void:
	var viewport_size = get_viewport_rect().size
	var top_center_screen_pos = Vector2(viewport_size.x / 2, 0)
	var top_center_world_pos = ship_camera.get_global_transform().affine_inverse() * top_center_screen_pos
	_spawn_batch(-top_center_world_pos.y * -10)
