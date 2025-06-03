class_name CosmeticAsteroid extends RigidBody2D

@onready var particles: CPUParticles2D = $Particles
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
var target_point: Vector2 = Vector2.ZERO
const MINIMUM_DISTANCE_FROM_SHIP: float = 700.0
var movement_speed_min: float = 700.0
var movement_speed_max: float = 700.0
const BOTTOM_THRESHOLD: float = 100.0
const TOP_THRESHOLD: float = 100.0
var current_speed: float = 0.0

func _ready() -> void:
	self.body_entered.connect(_on_body_entered)
	particles.finished.connect(_on_particles_finished)
	var parent = get_parent()
	if parent is Node2D:
		target_point = parent.global_position
	else:
		target_point = get_parent().global_position
	
	_init_location()

func _init_location() -> void:
	var random_angle = randf_range(0, TAU)
	var random_distance = randf_range(MINIMUM_DISTANCE_FROM_SHIP, MINIMUM_DISTANCE_FROM_SHIP * 1.5)
	
	var offset = Vector2(cos(random_angle), sin(random_angle)) * random_distance
	var initial_position = target_point + offset
	
	initial_position.y = clamp(
		initial_position.y,
		target_point.y - TOP_THRESHOLD,
		target_point.y + BOTTOM_THRESHOLD
	)
	
	var distance_after_clamp = initial_position.distance_to(target_point)
	if distance_after_clamp < MINIMUM_DISTANCE_FROM_SHIP:
		var x_offset = sqrt(pow(MINIMUM_DISTANCE_FROM_SHIP, 2) - pow(initial_position.y - target_point.y, 2))
		if randf() > 0.5:
			x_offset = -x_offset
		initial_position.x = target_point.x + x_offset
	
	global_position = initial_position
	current_speed = randf_range(movement_speed_min, movement_speed_max)
	
	look_at(target_point)

func _physics_process(_delta: float) -> void:
	var direction = (target_point - global_position).normalized()
	linear_velocity = direction * current_speed

func _on_body_entered(body: Node2D) -> void:
	if body.name == "ShipExternalCollision":
		animated_sprite.visible = false
		particles.emitting = true

func _on_particles_finished() -> void:
	queue_free()
