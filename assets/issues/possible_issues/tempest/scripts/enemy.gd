class_name Enemy extends Area2D

@export var speed: float = 100.0 ## Movement speed in pixels per second.
@export var vfx_explode_scene: PackedScene ## Particles for when enemy is destroyed. We'll instantiate and add it to TempestGame; freeing is handled outside (you can use AnimationPlayer to make self-freeing particles).

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var particles_track: CPUParticles2D = $ParticlesTrack

var start_point: Vector2 # Top of the lane.
var end_point: Vector2 # Base of the lane.
var progress: float = 0.0 # 0.0 at start_point, 1.0 at end_point.
var lane_idx: int # The lane this enemy is moving on.
var special: bool = false # Is this a special enemy or not.

# Reference to TempestGame to call methods on it.
var game_ref: TempestGame

# Called by TempestGame after instantiation.
func init(_start_point: Vector2, _end_point: Vector2, _lane_idx: int, _game: TempestGame, _special: bool = false, _progress: float = 0.0) -> void:
	start_point = _start_point
	end_point = _end_point
	lane_idx = _lane_idx
	game_ref = _game
	special = _special
	progress = _progress
	position = start_point
	if special:
		modulate *= 1.5

func _ready() -> void:
	randomize()
	scale = Vector2(0.25, 0.25)
	if special:
		anim.play("asteroid_special_1")
	else:
		anim.play("asteroid_" + str(randi_range(1, 5)))
	
	# Init particles.
	particles_track.amount = randi_range(8, 24)

func _process(delta) -> void:
	# Calculate progress along the lane based on time and total distance.
	var total_distance = start_point.distance_to(end_point)
	progress += (speed / total_distance) * delta
	
	# Update position and scale using linear interpolation.
	position = start_point.lerp(end_point, progress)
	scale = Vector2(0.25, 0.25).lerp(Vector2(1, 1), progress)
	
	# Update particles.
	particles_track.direction = (position - end_point).normalized()
	
	# Check if enemy reached the end of the lane.
	if progress >= 1.0 and !collision_shape.disabled:
		if game_ref and game_ref.has_method("enemy_reached_base"):
			game_ref.enemy_reached_base(lane_idx) # Notify TempestGame.
		queue_free() # Despawn the enemy.

func _on_area_entered(area: Area2D) -> void:
	# Assuming Projectiles are in the "projectiles" group.
	if area.is_in_group("projectiles"):
		if special:
			# Special enemy spawns two normal enemies upon death.
			if lane_idx == 0 || lane_idx == (game_ref.lane_count - 1):
				# This enemy is on edge.
				game_ref.spawn_enemy(lane_idx, false, progress - 0.05)
				game_ref.spawn_enemy(lane_idx, false, progress + 0.05)
			else:
				game_ref.spawn_enemy(lane_idx - 1, false, progress)
				game_ref.spawn_enemy(lane_idx + 1, false, progress)
		
		if game_ref and game_ref.has_method("enemy_killed"):
			game_ref.enemy_killed(progress, special)
		
		# Destroy projectile and enemy.
		area.queue_free()
		particles_track.hide()
		if vfx_explode_scene:
			var instance = vfx_explode_scene.instantiate()
			instance.position = position
			instance.modulate = modulate
			game_ref.container_vfx.add_child(instance)
		if special:
			queue_free()
		else:
			anim.play("asteroid_break")
			collision_shape.call_deferred("set_disabled", true) 
			await anim.animation_finished
			queue_free()
