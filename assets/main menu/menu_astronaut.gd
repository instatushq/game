extends RigidBody2D

@export var follow_speed: float = 10.0 
@export var protective_radius: float = 50.0
@export var max_velocity: float = 300.0  # Maximum velocity to maintain consistent speed
@export var damping: float = 0.95  # Damping factor to prevent excessive sliding
@onready var astronaut_sprite = $SpriteContainer/Sprite
@onready var idle_timer: Timer = $SpriteContainer/Sprite/Timer
@onready var astronaut_local_position: Vector2 = astronaut_sprite.position
@onready var astronaut_light: Light2D = $SpriteContainer/PointLight2D

var is_moving: bool = false

signal movement_began
signal movement_ended

func _ready() -> void:
	idle_timer.stop()
	idle_timer.timeout.connect(handle_animation_idle_blink)
	movement_began.connect(handle_movement_began)
	movement_ended.connect(handle_movement_ended)
	
	# Configure RigidBody2D properties
	linear_damp = 0.0  # We'll handle damping manually
	angular_damp = 10.0  # Prevent excessive rotation
	freeze = false
	gravity_scale = 0.0  # No gravity in menu

func _physics_process(_delta: float) -> void:
	var target_position = get_global_mouse_position()
	
	var distance_to_target = global_position.distance_to(target_position)
	if distance_to_target < protective_radius:
		if is_moving:
			movement_ended.emit()
			is_moving = false
		# Apply damping when not moving
		linear_velocity *= damping
		return

	if not is_moving:
		movement_began.emit()
		is_moving = true

	var direction = (target_position - global_position).normalized()
	
	# Apply force in the direction of movement
	var force = direction * follow_speed * 1000.0  # Scale up force for better control
	apply_central_force(force)
	
	# Limit maximum velocity
	if linear_velocity.length() > max_velocity:
		linear_velocity = linear_velocity.normalized() * max_velocity
	
	# Handle sprite flipping and rotation based on direction
	if direction.x > 0:
		astronaut_sprite.position.x = -astronaut_local_position.x
		astronaut_sprite.flip_h = false
		rotation = direction.angle()
		astronaut_light.scale = Vector2.ONE
	elif direction.x < 0:
		astronaut_sprite.position.x = astronaut_local_position.x
		astronaut_sprite.flip_h = true
		rotation = direction.angle() + PI  # Add 180 degrees (PI radians) when facing left
		astronaut_light.scale = Vector2.ONE * -1


func handle_animation_idle_blink() -> void:
	astronaut_sprite.play("idle_blink")

func _on_sprite_animation_finished() -> void:
	if astronaut_sprite.animation == "idle_blink":
		astronaut_sprite.play("idle")
	elif astronaut_sprite.animation == "halting":
		astronaut_sprite.play("idle")
	elif astronaut_sprite.animation == "begin_flight":
		astronaut_sprite.play("flight")

func handle_movement_began() -> void:
	astronaut_sprite.play("begin_flight")

func handle_movement_ended() -> void:
	astronaut_sprite.play("halting")
