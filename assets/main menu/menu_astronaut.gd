extends RigidBody2D

@export var follow_speed: float = 10.0 
@export var protective_radius: float = 50.0
@export var max_velocity: float = 300.0  
@export var damping: float = 0.95  
@export var light_transition_duration: float = 0.5

@onready var astronaut_sprite = $SpriteContainer/Sprite
@onready var idle_timer: Timer = $SpriteContainer/Sprite/Timer
@onready var astronaut_local_position: Vector2 = astronaut_sprite.position
@onready var astronaut_light: Light2D = $SpriteContainer/PointLight2D
@onready var astronaught_light_scale: Vector2 = astronaut_light.scale
@onready var astronaut_light_energy: float = astronaut_light.energy

var is_moving: bool = false
var current_light_tween: Tween = null
var target_light_energy: float = 0.0

signal movement_began
signal movement_ended

func _ready() -> void:
	astronaut_light.energy = 0
	target_light_energy = 0.0
	idle_timer.stop()
	idle_timer.timeout.connect(handle_animation_idle_blink)
	movement_began.connect(handle_movement_began)
	movement_ended.connect(handle_movement_ended)
	
	linear_damp = 0.0
	angular_damp = 10.0
	freeze = false
	gravity_scale = 0.0

func _physics_process(_delta: float) -> void:
	var target_position = get_global_mouse_position()
	
	var distance_to_target = global_position.distance_to(target_position)
	if distance_to_target < protective_radius:
		if is_moving:
			movement_ended.emit()
			is_moving = false

		linear_velocity *= damping
		return

	if not is_moving:
		movement_began.emit()
		is_moving = true

	var direction = (target_position - global_position).normalized()
	
	var force = direction * follow_speed * 1000.0
	apply_central_force(force)
	
	if linear_velocity.length() > max_velocity:
		linear_velocity = linear_velocity.normalized() * max_velocity
	
	if direction.x > 0:
		astronaut_sprite.position.x = -astronaut_local_position.x
		astronaut_sprite.flip_h = false
		rotation = direction.angle()
		astronaut_light.scale = astronaught_light_scale
	elif direction.x < 0:
		astronaut_sprite.position.x = astronaut_local_position.x
		astronaut_sprite.flip_h = true
		rotation = direction.angle() + PI
		astronaut_light.scale = astronaught_light_scale * -1

func interpolate_light_energy(target: float) -> void:
	if current_light_tween:
		current_light_tween.kill()
	
	current_light_tween = create_tween()
	current_light_tween.tween_property(astronaut_light, "energy", target, light_transition_duration)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)
	target_light_energy = target

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
	interpolate_light_energy(astronaut_light_energy)

func handle_movement_ended() -> void:
	astronaut_sprite.play("halting")
	interpolate_light_energy(0.0)
