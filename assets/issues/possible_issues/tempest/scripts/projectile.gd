class_name Projectile extends Area2D

@export var speed: float = 400.0 ## Movement speed in pixels per second

var start_point: Vector2 # Base of the lane (player's position).
var end_point: Vector2 # Top of the lane.
var progress: float = 0.0 # 0.0 at start_point, 1.0 at end_point.
var lane_idx: int # The lane this projectile is moving on.

# Custom initialization function called by TempestGame.
func init(_start_point: Vector2, _end_point: Vector2, _lane_idx: int):
	start_point = _start_point
	end_point = _end_point
	lane_idx = _lane_idx
	position = start_point

func _physics_process(delta):
	# Check if game is paused
	var parent_game = get_parent().get_parent()
	if parent_game and parent_game.has_method("_is_game_paused") and parent_game._is_game_paused:
		return
	
	var total_distance = start_point.distance_to(end_point)
	progress += (speed / total_distance) * delta
	
	position = start_point.lerp(end_point, progress)
	scale = Vector2(1, 1).lerp(Vector2(0.25, 0.25), progress)
	
	# Despawn if it reaches the top.
	if progress >= 1.0:
		queue_free()
