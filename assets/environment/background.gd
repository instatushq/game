extends ParallaxBackground

class_name ParallaxBackgroundController

@onready var celestial_items_containers: ParallaxLayer = $Celestials
@export var noise: FastNoiseLite
@export var big_planet: PackedScene = null
@export var small_planet: PackedScene = null
@export var medium_planet: PackedScene = null
@export var average_planet: PackedScene = null
@export var black_hole: PackedScene = null

# Base scales for each celestial body type
@export var big_planet_base_scale: float = 1.0
@export var small_planet_base_scale: float = 0.5
@export var medium_planet_base_scale: float = 0.75
@export var average_planet_base_scale: float = 0.6
@export var black_hole_base_scale: float = 1.2

# Scale range for celestial bodies (will be added to base scale)
@export_range(0.0, 1.0) var min_scale_offset: float = 0.0
@export_range(0.0, 1.0) var max_scale_offset: float = 1.0

# Spawn rate controls (0.0 to 1.0)
@export_range(0.0, 1.0) var big_planet_spawn_rate: float = 0.1
@export_range(0.0, 1.0) var small_planet_spawn_rate: float = 0.2
@export_range(0.0, 1.0) var medium_planet_spawn_rate: float = 0.15
@export_range(0.0, 1.0) var average_planet_spawn_rate: float = 0.25
@export_range(0.0, 1.0) var black_hole_spawn_rate: float = 0.05

# Maximum total number of objects to spawn
@export_range(1, 100) var max_total_objects: int = 30

@export_range(100.0, 400.0) var min_distance_between_bodies: float = 250.0

# Step size for generation grid (smaller = more dense generation attempts)
@export_range(20.0, 200.0) var generation_step_size: float = 100.0

# Noise thresholds for different celestial bodies
const GALAXY_ARM_THRESHOLD: float = -0.3  # Darker areas (galaxy arms)
const BLACK_HOLE_THRESHOLD: float = 0.0   # Medium areas (black holes)
const CELESTIAL_THRESHOLD: float = 0.3    # Lighter areas (stars and planets)

const CELESTIAL_GROUP = "generated_celestial"

func is_position_valid(new_pos: Vector2, scale_param: float, spawned_positions: Array[Vector2]) -> bool:
	for existing_pos in spawned_positions:
		if new_pos.distance_to(existing_pos) < min_distance_between_bodies * scale_param:
			return false
	return true

func generate_background_segment(bottom_border_y: float, center_x: float, height: float, width: float = 1000.0) -> Array[Node2D]:
	var spawned_instances: Array[Node2D] = []
	var spawned_positions: Array[Vector2] = []
	
	# Calculate total spawn rate for normalization
	var total_spawn_rate = big_planet_spawn_rate + small_planet_spawn_rate + medium_planet_spawn_rate + average_planet_spawn_rate + black_hole_spawn_rate
	
	# Determine random target count for total objects
	var target_total_objects = randi_range(1, max_total_objects)
	var current_total_objects = 0
	
	# Calculate the bounds based on width and center_x
	var left_bound = center_x - (width / 2)
	var right_bound = center_x + (width / 2)
	
	# First, collect all valid potential positions
	var potential_positions: Array[Vector2] = []
	
	for x in range(left_bound, right_bound, generation_step_size):
		for y in range(bottom_border_y - height, bottom_border_y, generation_step_size):
			var noise_value = noise.get_noise_2d(x, y)
			
			# Skip if in galaxy arm (dark area)
			if noise_value < GALAXY_ARM_THRESHOLD:
				continue
				
			# Add position to potential positions
			var global_pos = celestial_items_containers.to_global(Vector2(x, y))
			global_pos += Vector2(
				randf_range(-generation_step_size/2, generation_step_size/2),
				randf_range(-generation_step_size/2, generation_step_size/2)
			)
			
			# Ensure the position is within the width bounds
			if global_pos.x >= left_bound and global_pos.x <= right_bound:
				potential_positions.append(global_pos)
	
	# Shuffle the potential positions to randomize selection
	potential_positions.shuffle()
	
	# Now try to spawn objects at random positions
	for global_pos in potential_positions:
		if current_total_objects >= target_total_objects:
			break
			
		var noise_value = noise.get_noise_2d(global_pos.x, global_pos.y)
		
		# Determine which celestial body to spawn based on noise value and spawn rates
		var spawn_chance = randf() * total_spawn_rate
		var celestial_body: PackedScene = null
		
		if noise_value > CELESTIAL_THRESHOLD:
			# Lighter areas - more likely to spawn planets
			if spawn_chance < big_planet_spawn_rate:
				celestial_body = big_planet
			elif spawn_chance < big_planet_spawn_rate + small_planet_spawn_rate:
				celestial_body = small_planet
			elif spawn_chance < big_planet_spawn_rate + small_planet_spawn_rate + medium_planet_spawn_rate:
				celestial_body = medium_planet
			elif spawn_chance < big_planet_spawn_rate + small_planet_spawn_rate + medium_planet_spawn_rate + average_planet_spawn_rate:
				celestial_body = average_planet
		elif noise_value > BLACK_HOLE_THRESHOLD:
			# Medium areas - chance for black holes
			if spawn_chance < black_hole_spawn_rate:
				celestial_body = black_hole
		
		# Spawn the celestial body if one was selected
		if celestial_body != null:
			# Calculate base scale for this celestial body type
			var base_scale = get_base_scale_for_celestial(celestial_body)
			
			# Calculate random scale using base scale and offset
			var random_scale = base_scale + randf_range(min_scale_offset, max_scale_offset)
			
			# Check if position is valid (no overlap)
			if is_position_valid(global_pos, random_scale, spawned_positions):
				var instance = celestial_body.instantiate()
				instance.add_to_group(CELESTIAL_GROUP)  # Add to group for tracking
				celestial_items_containers.add_child(instance)
				
				# Set position and scale
				instance.global_position = global_pos
				instance.scale = Vector2.ONE * random_scale
				
				# Add position to spawned positions
				spawned_positions.append(global_pos)
				
				# Add to spawned instances and increment total count
				spawned_instances.append(instance)
				current_total_objects += 1

	return spawned_instances

func get_base_scale_for_celestial(celestial_body: PackedScene) -> float:
	if celestial_body == big_planet:
		return big_planet_base_scale
	elif celestial_body == small_planet:
		return small_planet_base_scale
	elif celestial_body == medium_planet:
		return medium_planet_base_scale
	elif celestial_body == average_planet:
		return average_planet_base_scale
	elif celestial_body == black_hole:
		return black_hole_base_scale
	return 1.0  # Default fallback
