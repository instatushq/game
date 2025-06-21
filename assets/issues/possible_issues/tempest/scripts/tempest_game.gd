class_name TempestGame extends Node2D

signal on_issue_resolved
signal enemy_destroyed(score_weight: int)

@export var game_camera: Camera2D

@export_category("Params - Game Logic")
@export var game_duration: float = 120.0 ## Duration of entire minigame in seconds.
@export var arena_count: int = 5 ## Number of arenas to generate during the game.
@export var enemy_spawn_interval: float = 1.5 ## Seconds between enemy spawns.
@export var enemy_score_min: int = 0 ## Score when killing an enemy that just spawned (higher distance to player = lower score).
@export var enemy_score_max: int = 100 ## Score when killing an enemy that almost reached player (lower distance to player = higher score).
@export var health_max: int = 3 ## Health points of player (make sure to update health_progress spritesheet if you change this).
@export var enemy_scene: PackedScene ## Assign Enemy.tscn in Inspector.
@export var projectile_scene: PackedScene ## Assign Projectile.tscn in Inspector.

@export_category("Params - Arena Generation")
@export var lane_count: int = 7 ## Number of lanes.
@export var lane_width: float = 80.0 ## Width of each lane in pixels at the base.
@export var lane_depth: float = 400.0 ## How "deep" the lanes go towards the vanishing point.
@export var lane_base_height: float = 85.0 ## Distance from the bottom of the viewport to the *average* base Y.
@export var max_base_height_deviation: float = 80.0 ## Max random vertical deviation for points on the base contour.
@export var contour_smoothness: int = 1 ## Number of smoothing passes for the base contour (0 for jagged, 1+ for smoother).
@export var top_offset_propagation_factor: float = 0.5 ## How much the base's Y-offset propagates to the top of the lines (0.0=flat top, 1.0=same wiggle as base).
@export var top_scale_factor : float = 0.15 ## Controls convergence of top points towards vanishing point (0.0: vanishing point, 1.0: straight lines).
@export var lanes_y_offset: float = 400.0 ## Offset of the lanes from the bottom of the viewport.

@export_category("Params - Visual")
@export var line_color: Color = Color(1, 1, 1, 0.3) ## Default lane line color (white with alpha 0.3).
@export var line_highlight_color: Color = Color(0.0, 1.0, 0.0, 0.7) ## Highlight color (green with alpha 0.7).
@export var line_thickness: float = 2.0 ## Thickiness of lane lines.
@export var sceen_shake_duration: float = 0.04 ## Duration of shake when player is hit (in seconds).
@export_range(1, 50) var player_elerp_decay: float = 25.0 ## For lerp smoothing using exponential decay (elerp); useful decay range 1 to 25 from slow to fast.

@onready var player: Sprite2D = $Player
@onready var container_vfx: Node2D = $ContainerVFX
@onready var container_enemy: Node2D = $ContainerEnemy
@onready var container_projectile: Node2D = $ContainerProjectile
@onready var container_lane_line: Node2D = $ContainerLaneLine
@onready var timer_enemy_spawn: Timer = $TimerEnemySpawn 
@onready var timer_game: Timer = $TimerGame
@onready var timer_arena_generate: Timer = $TimerArenaGenerate
@onready var health_bar: TextureProgressBar = $CanvasLayer/Control/HealthBar
@onready var screen: Screen = $CanvasLayer/Control/Screen
@onready var screen_shake: ColorRect = $CanvasLayer/Control/ScreenShake

var _is_game_playing: bool = false

var lane_lines: Array[Line2D] = [] # Array to store references to the generated Line2D nodes.
var base_contour_offsets: PackedFloat32Array # Stores the Y-offset for each base point of the lines.

var current_lane_index: int = 0 # The index of the lane the player is currently in (0 to lane_count-1).
var health_current: int = health_max
var player_target_position: Vector2

# Cached viewport dimensions and calculated points for drawing.
var vp_size: Vector2
var vanishing_point_x: float
var base_y_center: float # The central Y-coordinate around which the base contour varies.
var top_y_center: float # The central Y-coordinate around which the top contour varies.
var total_base_width: float
var base_leftmost_x: float # X-coord of the leftmost line at the base.

func _input(event):
	if not _is_game_playing: return
	if event.is_action_pressed("move_left"):
		current_lane_index = max(0, current_lane_index - 1)
		update_player_position_and_rotation(false)
		refresh_line_colors()
		$Sfx/Move.play()
	elif event.is_action_pressed("move_right"):
		current_lane_index = min(lane_count - 1, current_lane_index + 1)
		update_player_position_and_rotation(false)
		refresh_line_colors()
		$Sfx/Move.play()
	elif event.is_action_pressed("fire_cannon"):
		spawn_projectile()
		$Sfx/Shoot.play()

func _ready() -> void:
	# Calculate key drawing points that define the overall perspective relative to camera.
	if game_camera:
		vp_size = game_camera.get_viewport_rect().size
		vanishing_point_x = game_camera.global_position.x
	else:
		vp_size = get_viewport_rect().size
		vanishing_point_x = vp_size.x / 2
	
	base_y_center = game_camera.global_position.y + (vp_size.y / 2) - lane_base_height - lanes_y_offset # Y-coordinate at the *average* bottom of the lanes.
	top_y_center = base_y_center - lane_depth # Y-coordinate at the *average* top (towards vanishing point).
	
	total_base_width = lane_count * lane_width
	base_leftmost_x = vanishing_point_x - (total_base_width / 2)
	
	# Initialize timers.
	timer_enemy_spawn.wait_time = enemy_spawn_interval
	timer_enemy_spawn.timeout.connect(_on_timer_enemy_spawn_timeout)
	timer_game.wait_time = game_duration
	timer_game.timeout.connect(_on_timer_game_timeout)
	timer_arena_generate.wait_time = game_duration / arena_count
	timer_arena_generate.timeout.connect(_on_timer_arena_generate_timeout)
	
	# For testing.
	# start_game()

func update_camera_relative_coordinates():
	# Update coordinates when camera moves
	if game_camera:
		vp_size = game_camera.get_viewport_rect().size
		vanishing_point_x = game_camera.global_position.x
	else:
		vp_size = get_viewport_rect().size
		vanishing_point_x = vp_size.x / 2
	
	base_y_center = game_camera.global_position.y + (vp_size.y / 2) - lane_base_height - lanes_y_offset
	top_y_center = base_y_center - lane_depth
	
	total_base_width = lane_count * lane_width
	base_leftmost_x = vanishing_point_x - (total_base_width / 2)

func elerp(a, b, decay : float, dt : float):
	# Frame-independent lerp smoothing using exponential decay. Useful decay range 1 to 25 from slow to fast.
	return lerp(b, a, exp(-decay * dt))
	
func _physics_process(delta: float) -> void:
	player.position = elerp(player.position, player_target_position, player_elerp_decay, delta)

func start_game() -> void:
	_is_game_playing = true
	randomize()
	screen_shake.hide()
	
	# 3,2,1 countdown.
	process_mode = Node.PROCESS_MODE_DISABLED
	screen.game_start()
	await screen.screen_finished
	process_mode = Node.PROCESS_MODE_INHERIT
	
	# Initialize healthbar.
	health_bar.max_value = health_max
	health_bar.value = health_max
	health_current = health_max
	
	# Initialize arena and player.
	generate_new_arena()
	
	# Start timers.
	timer_game.start()
	timer_arena_generate.start()

func generate_new_arena() -> void:
	# Restart enemy spawn timer.
	timer_enemy_spawn.start()
	
	# Clear any existing enemies and projectiles.
	for child in container_enemy.get_children():
		child.queue_free()
	for child in container_projectile.get_children():
		child.queue_free()
	for child in container_vfx.get_children():
		child.queue_free()
	
	generate_lane_lines()
	
	# Initialize player.
	# We won't reset current_lane_index because we're assuming lane_count will remain the same throughout the game.
	#current_lane_index = 0
	update_player_position_and_rotation(true)
	refresh_line_colors()

#
# Lane Generation Functions.
#
func generate_base_contour_offsets():
	# Generates a smoothed random Y-offset for each point on the base contour.
	
	# Generate raw random offsets.
	base_contour_offsets.resize(lane_count + 1)
	var raw_offsets: PackedFloat32Array
	raw_offsets.resize(lane_count + 1)
	for i in range(lane_count + 1):
		raw_offsets[i] = randf_range(-max_base_height_deviation, max_base_height_deviation)
	
	# Apply smoothing passes.
	for s_pass in range(contour_smoothness):
		var smoothed_offsets: PackedFloat32Array
		smoothed_offsets.resize(lane_count + 1)
		for i in range(lane_count + 1):
			var sum_offsets = raw_offsets[i]
			var count = 1.0
			
			if i > 0:
				sum_offsets += raw_offsets[i-1]
				count += 1.0
			if i < lane_count: # (lane_count + 1 lines, so index goes up to lane_count).
				sum_offsets += raw_offsets[i+1]
				count += 1.0
			
			smoothed_offsets[i] = sum_offsets / count
		raw_offsets = smoothed_offsets # Use smoothed offsets for next pass.
	
	base_contour_offsets = raw_offsets

func generate_lane_lines():
	# Creates and configures Line2D nodes based on the generated base contour.
	update_camera_relative_coordinates()
	generate_base_contour_offsets()
	
	# Clear any existing lines before regenerating.
	for child in container_lane_line.get_children():
		child.queue_free()
	lane_lines.clear()
	
	for i in range(lane_count + 1): # lane_count + 1 lines.
		var line_node = Line2D.new()
		line_node.name = "LaneLine_" + str(i)
		container_lane_line.call_deferred("add_child", line_node)
		
		# Set base properties for the line.
		line_node.width = line_thickness 
		line_node.default_color = line_color # Will be updated by refresh_line_colors.
		
		lane_lines.append(line_node)
		
		var base_x = base_leftmost_x + (i * lane_width)
		var base_y_with_offset = base_y_center + base_contour_offsets[i]
		
		# Calculate top X based on convergence towards the vanishing point.
		# Using top_scale_factor for finer control of perspective convergence.
		var top_x = vanishing_point_x + (base_x - vanishing_point_x) * top_scale_factor
		
		# Calculate the Y-coordinate for the top of the line, propagating the base offset.
		var top_y_with_offset = top_y_center + (base_contour_offsets[i] * top_offset_propagation_factor)
		
		var p1 = Vector2(base_x, base_y_with_offset) # Base point of the line.
		var p2 = Vector2(top_x, top_y_with_offset)   # Top (vanishing) point of the line.
		
		line_node.points = PackedVector2Array([p1, p2])
	
	# Generate bottom and top lines to improve visuals.
	for i in range(lane_lines.size() - 1):
		var line_0 = lane_lines[i]
		var line_1 = lane_lines[i + 1]
		
		var line_bottom = Line2D.new()
		line_bottom.width = line_thickness
		line_bottom.default_color = line_color
		line_bottom.points = PackedVector2Array([line_0.points[0], line_1.points[0]])
		
		var line_top = Line2D.new()
		line_top.width = line_thickness
		line_top.default_color = line_color
		line_top.points = PackedVector2Array([line_0.points[1], line_1.points[1]])
		
		container_lane_line.call_deferred("add_child", line_bottom)
		container_lane_line.call_deferred("add_child", line_top)


#
# Player & Visual Update Functions.
#
func update_player_position_and_rotation(snap_position: bool):
	# Ensure nodes are valid and lines are generated before trying to position player.
	if lane_lines.is_empty() or lane_lines.size() <= current_lane_index + 1:
		return
	
	var left_line_base_point = lane_lines[current_lane_index].points[0]
	var right_line_base_point = lane_lines[current_lane_index + 1].points[0]
	
	# Calculate player's position: horizontally/vertically centered in the current lane at the base.
	player_target_position = (left_line_base_point + right_line_base_point) / 2
	if snap_position:
		player.position = player_target_position
	
	# Update player rotation.
	var left_line_top_point = lane_lines[current_lane_index].points[1]
	var right_line_top_point = lane_lines[current_lane_index + 1].points[1]
	var end_point = (left_line_top_point + right_line_top_point) / 2
	player.rotation = (end_point - player_target_position).angle() + PI/2.0
	#player.look_at(end_point)
	#player.rotation += PI/2.0

func refresh_line_colors():
	# Iterates through all Line2D nodes and sets their colors and width based on highlight status.
	if lane_lines.is_empty(): return
	
	for i in range(lane_lines.size()):
		var line_node = lane_lines[i]
		var target_color = line_color
		var target_width = line_thickness
		
		# Highlight lines for the current lane.
		# The player is 'in' lane `current_lane_index`.
		# So, we highlight lines `current_lane_index` and `current_lane_index + 1`.
		if i == current_lane_index or i == current_lane_index + 1:
			target_color = line_highlight_color
			target_width = line_thickness * 1.5
		
		line_node.default_color = target_color
		line_node.width = target_width

#
# Enemy & Projectile Management Functions.
#
func spawn_enemy(lane_idx: int, special: bool = false, progress: float = 0.0):
	if not enemy_scene:
		printerr("Enemy scene (PackedScene) not assigned in TempestGame!")
		return
	if lane_lines.is_empty() or lane_count == 0:
		printerr("Cannot spawn enemy: lanes not generated or lane_count is 0.")
		return
	
	var left_line_top_point = lane_lines[lane_idx].points[1] # .points[1] is the top point
	var right_line_top_point = lane_lines[lane_idx + 1].points[1]
	var enemy_start_pos = (left_line_top_point + right_line_top_point) / 2
	
	var left_line_base_point = lane_lines[lane_idx].points[0] # .points[0] is the base point
	var right_line_base_point = lane_lines[lane_idx + 1].points[0]
	var enemy_end_pos = (left_line_base_point + right_line_base_point) / 2
	
	var enemy_instance : Enemy = enemy_scene.instantiate()
	enemy_instance.init(enemy_start_pos, enemy_end_pos, lane_idx, self, special, progress)
	container_enemy.call_deferred("add_child", enemy_instance)

func spawn_projectile():
	if not projectile_scene:
		printerr("Projectile scene (PackedScene) not assigned in TempestGame!")
		return
	if lane_lines.is_empty() or lane_count == 0:
		printerr("Cannot spawn projectile: lanes not generated or lane_count is 0.")
		return
	
	# Projectile starts at player's current position and moves up its lane.
	var projectile_start_pos = player.position + (player.scale / 2.0)
	
	var left_line_top_point = lane_lines[current_lane_index].points[1]
	var right_line_top_point = lane_lines[current_lane_index + 1].points[1]
	var projectile_end_pos = (left_line_top_point + right_line_top_point) / 2
	
	var projectile_instance = projectile_scene.instantiate()
	projectile_instance.init(projectile_start_pos, projectile_end_pos, current_lane_index)
	container_projectile.call_deferred("add_child", projectile_instance)

func enemy_reached_base(lane_idx: int):
	# Function called by an Enemy when it reaches the base without being destroyed.
	print("Enemy in lane ", lane_idx, " reached the base! Player took damage.")
	health_current -= 1
	health_bar.value = health_current
	$Sfx/HealthDecreased.play()
	if health_current <= 0:
		print("You lose!")
		$Sfx/Lose.play()
		process_mode = Node.PROCESS_MODE_DISABLED
		screen.game_lose()
		await screen.screen_finished
		start_game()
		return
	
	# Briefly show screen shake.
	screen_shake.show()
	await get_tree().create_timer(sceen_shake_duration).timeout
	screen_shake.hide()
	
	# Briefly show a redline indicating where enemy hit us.
	var left_base_point = lane_lines[lane_idx].points[0]
	var right_base_point = lane_lines[lane_idx + 1].points[0]
	var line_hit = Line2D.new()
	line_hit.width = line_thickness
	line_hit.default_color = Color(0.8, 0.25, 0.25) * 5.0
	line_hit.points = PackedVector2Array([left_base_point, right_base_point])
	container_lane_line.call_deferred("add_child", line_hit)
	await get_tree().create_timer(0.5).timeout
	if is_instance_valid(line_hit):
		line_hit.queue_free()

func enemy_killed(progress: float, special: bool) -> void:
	var score : float = enemy_score_min + enemy_score_max * progress
	score = clamp(score, enemy_score_min, enemy_score_max)
	enemy_destroyed.emit(int(score))
	$Sfx/EnemyDestroyed.pitch_scale = 1.7 if special else 1.0
	$Sfx/EnemyDestroyed.play()

#
# Signals
#
func _on_timer_enemy_spawn_timeout():
	if timer_arena_generate.get_time_left() <= 0.3:
		# Don't spawn this enemy if we're about to generate a new arena.
		return
	var special = true if randf() < 0.5 else false
	var random_lane_idx = randi_range(0, lane_count - 1)
	spawn_enemy(random_lane_idx, special, 0.0)

func _on_timer_game_timeout() -> void:
	print("You win!")
	$Sfx/Win.play()
	process_mode = Node.PROCESS_MODE_DISABLED
	screen.game_win()
	await screen.screen_finished
	on_issue_resolved.emit()

func _on_timer_arena_generate_timeout() -> void:
	$Sfx/NewArena.play()
	generate_new_arena()

func on_camera_moved():
	# Call this when the camera moves to update all coordinates and regenerate lane lines
	if _is_game_playing:
		generate_lane_lines()
		update_player_position_and_rotation(false)
		refresh_line_colors()
