extends RigidBody2D

@export var follow_speed: float = 5.0  # Adjust this value to control how fast the astronaut follows the mouse

func _physics_process(delta: float) -> void:
	# Get the mouse position in global coordinates
	var target_position = get_global_mouse_position()
	
	# Calculate the direction to move
	var direction = (target_position - global_position)
	
	# Move towards the target position using interpolation
	global_position = global_position.lerp(target_position, follow_speed * delta)
	
	# Optional: Add some rotation based on movement direction
	if direction.length() > 0:
		var target_rotation = direction.angle()
		rotation = lerp_angle(rotation, target_rotation, follow_speed * delta)
