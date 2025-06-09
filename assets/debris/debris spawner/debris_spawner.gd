extends Node2D

var game_manager: BarrelInvader = null
@export var ship_camera: Camera2D = null
@onready var walls: Array[Node] = get_node("%Walls/RigidBody2D/Left Right").get_children()
@export var debris_objects: Array[PackedScene] = []
@export var fuel_rocks: Array[PackedScene] = []
const MAX_DEBRIS_BATCHES_AT_A_TIME: int = 3
var debris_batches: Array = []
var highest_element_in_the_latest_batch: Node2D = null

var grid_size_draw: Vector2 = Vector2(0, 0)
var grid_position_draw: Vector2 = Vector2(0, 0)
const distance_from_camera_top_to_spawn_batch: float = 0
const DISTANCE_BETWEEN_SEGMENTS: float = 100
var can_spawn: bool = true

var asteroid_rocks_chance: int = 92
var fuel_rocks_chance: int = 8

var debris_positions: Array = []
var grid_locations: Array = []

func _spawn_batch(y_level: float = 0) -> void:
	var batch_container: Array[Node2D] = []
	var view_port_y_size = 600
	var view_port_x_size = get_viewport().size.x

	var area_width = (view_port_x_size * 0.25) * 0.9

	var grid_size = Vector2(area_width, view_port_y_size)
	
	var center_x_position = (ship_camera.global_position.x + (view_port_x_size * 0.25 * 0.325))

	var grid_position = Vector2(center_x_position, y_level - grid_size.y)
	grid_size_draw = grid_size
	grid_position_draw = grid_position
	
	var generated_points = PoissonDiscSampling.generate_points(140, grid_size, 50, grid_position)
	grid_locations.append({
		"position": Vector2(center_x_position, y_level),
		"size": Vector2(area_width, 100),
		"color": RandomColor.get_random_color(0.2, 0.5),
		"points_color": RandomColor.get_random_pastel_color()
	})

	highest_element_in_the_latest_batch = null

	for point in generated_points:
		var spawned_element: Node2D
		var random_integer: int = randi_range(0, 100)
		if random_integer < fuel_rocks_chance:
			spawned_element = _spawn_fuel_rock(point)
		elif random_integer < asteroid_rocks_chance:
			spawned_element = _spawn_debris(point)
		else:
			continue
		
		batch_container.append(spawned_element)
		
		if highest_element_in_the_latest_batch == null or not is_instance_valid(highest_element_in_the_latest_batch):
			highest_element_in_the_latest_batch = spawned_element.get_node("Ship Impacter")
		else:
			if spawned_element != null:
				if spawned_element.global_position.y < highest_element_in_the_latest_batch.global_position.y:
					highest_element_in_the_latest_batch = spawned_element.get_node("Ship Impacter")

	debris_batches.append(batch_container)
	if debris_batches.size() >= MAX_DEBRIS_BATCHES_AT_A_TIME:
		var batch_to_remove = debris_batches[0]
		for element in batch_to_remove:
			if is_instance_valid(element):
				element.queue_free()
		debris_batches.remove_at(0)
		
	queue_redraw()

func _input(event):
	if game_manager == null: return
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_R and game_manager.is_playing:
			spawn_batch_above_player()

func spawn_batch_above_player():
	var viewport_size = get_viewport_rect().size
	var camera_position = ship_camera.global_position
	var top_center_world_pos = camera_position.y - (viewport_size.y / 2)
	_spawn_batch(top_center_world_pos)

func _spawn_debris(spawn_position: Vector2) -> Node2D:
	var debris_scene = debris_objects.pick_random()
	var debris_scene_instance = debris_scene.instantiate()
	debris_scene_instance.global_position = spawn_position
	add_child(debris_scene_instance)
	return debris_scene_instance
	
func _spawn_fuel_rock(spawn_position: Vector2) -> Node2D:
	var fuel_rock_scene = fuel_rocks.pick_random()
	var fuel_rock_scene_instance = fuel_rock_scene.instantiate()
	fuel_rock_scene_instance.global_position = spawn_position
	add_child(fuel_rock_scene_instance)
	return fuel_rock_scene_instance

func _physics_process(_delta: float) -> void:
	var viewport_size = get_viewport_rect().size
	var camera_position = ship_camera.global_position
	var top_center_world_pos = camera_position.y - (viewport_size.y / 2)
	
	if not is_instance_valid(highest_element_in_the_latest_batch): return

	if top_center_world_pos <= highest_element_in_the_latest_batch.global_position.y:
		_spawn_batch(highest_element_in_the_latest_batch.global_position.y)
		debris_positions.append([[Vector2(0, top_center_world_pos)]])
		queue_redraw()
		
func _ready() -> void:
	game_manager = get_parent()
	game_manager.game_started.connect(_on_game_started)

func _on_game_started() -> void:
	var viewport_size = get_viewport_rect().size
	var camera_position = ship_camera.global_position
	var top_center_world_pos = camera_position.y - (viewport_size.y / 2)
	_spawn_batch(top_center_world_pos)
