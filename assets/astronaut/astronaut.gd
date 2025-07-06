class_name Astronaut extends CharacterBody2D

enum MovementDirection { FORWARD, UP, DOWN }

signal movement_began(direction: MovementDirection)
signal movement_ended(direction: MovementDirection)
signal on_movement_vector_changed(movement_vector: Vector2)
signal direction_changed_while_moving(old_direction: MovementDirection, new_direction: MovementDirection)

var frozen: bool = false
var can_control: bool = false
const MAX_RADIUS := 150
@export var movement_speed: float = 300.0
@export var maximum_speed: float = 300.0
@export var damping: float = 0.0
@export var acceleration: float = 2000.0
@export var deceleration: float = 3000.0
@export var rotation_speed: float = 5.0
const MAX_ROTATION: float = deg_to_rad(45)
const ROTATION_CHANGE_THRESHOLD: float = deg_to_rad(80.0)
var last_movement_direction: Vector2 = Vector2.ZERO
@onready var game_manager: GameManager = %GameManager
@onready var internal_ship: InternalShip = %InternalShip
@onready var cockpit_node: Node2D = %InternalShip/Points/Cockpit
@onready var astronaut_sprite: AnimatedSprite2D = $SpriteContainer/AnimatedSprite2D
@onready var sprite_container: Node2D = $SpriteContainer
@onready var idle_timer: Timer =  $SpriteContainer/AnimatedSprite2D/Timer
@onready var astronaut_flashlight: AstronautFlashlight = $SpriteContainer/PointLight2D
@onready var astronaut_local_position: Vector2 = astronaut_sprite.position
@onready var begin_flight_sound: AudioStreamPlayer2D = $FlyBegin
@onready var end_flight_sound: AudioStreamPlayer2D = $FlyEnd
@onready var main_camera: Camera2D = %Camera

var is_solving_puzzle: bool = false
var current_direction: MovementDirection = MovementDirection.FORWARD
const MOVEMENT_DEADZONE_PERCENTAGE: float = 0.5
var joystick_movement_vector: Vector2 = Vector2.ZERO
var _has_movement_begun_already: bool = false

func _ready() -> void:
	idle_timer.start()
	idle_timer.timeout.connect(handle_animation_idle_blink)
	movement_began.connect(handle_movement_began)
	movement_ended.connect(handle_movement_ended)
	direction_changed_while_moving.connect(_handle_direction_changed_while_moving)
	internal_ship.on_ship_revived.connect(func(): astronaut_flashlight.on_ship_revived())
	internal_ship.on_ship_broken.connect(_on_internal_ship_broke)
	game_manager.on_solving_puzzle_changed.connect(func(solving: bool) -> void: visible = not solving)

func _on_internal_ship_broke() -> void:
	astronaut_flashlight.on_ship_broken(_has_movement_begun_already)

func _process(_delta: float) -> void:
	astronaut_sprite.modulate = internal_ship.ship_sprite.modulate

func toggle_control(new_can_control: bool) -> void:
	can_control = new_can_control
	frozen = not new_can_control

func _physics_process(delta: float) -> void:
	if is_solving_puzzle: return
	
	if internal_ship.issues.is_issue_open: return

	if joystick_movement_vector.length() > MOVEMENT_DEADZONE_PERCENTAGE:
		var movement_direction := joystick_movement_vector
		on_movement_vector_changed.emit(movement_direction)
		var target_velocity = movement_direction * movement_speed
		
		var dot_product = velocity.normalized().dot(target_velocity.normalized())
		var current_accel = acceleration if dot_product > 0 else deceleration
		
		velocity = velocity.move_toward(target_velocity, current_accel * delta)
		
		var new_target = atan2(movement_direction.y, abs(movement_direction.x))
		if movement_direction.x < 0:
			new_target = -new_target

		var old_direction = current_direction

		if abs(new_target) > MAX_ROTATION:
			current_direction = MovementDirection.DOWN if joystick_movement_vector.y > 0.05 else MovementDirection.UP
		else:
			current_direction = MovementDirection.FORWARD
			if abs(AngleDifference.angle_difference(sprite_container.rotation, new_target)) > ROTATION_CHANGE_THRESHOLD:
				sprite_container.rotation = new_target
	
		if old_direction != current_direction and _has_movement_begun_already:
			direction_changed_while_moving.emit(old_direction, current_direction)

		if not _has_movement_begun_already:
			_has_movement_begun_already = true
			movement_began.emit(current_direction)
	else:
		if _has_movement_begun_already:
			movement_ended.emit(current_direction)
			_has_movement_begun_already = false

		if damping != 0:
			var damping_factor = 1.0 - (damping * delta)
			velocity *= damping_factor

	if velocity.length() > maximum_speed:
		velocity = velocity.normalized() * maximum_speed
	
	move_and_slide()

func _input(event: InputEvent) -> void:
	if not can_control:
		return

	if event is InputEventKey:
		handle_keyboard_input(event)

	handle_mouse_movement()
	handle_animation(joystick_movement_vector)

func handle_keyboard_input(event: InputEvent) -> bool:
	var keyboard_movement_vector: Vector2 = Vector2.ZERO
	if event is InputEventKey:
		
		var vertical_axis = Input.get_axis("move_up", "move_down")
		var horizontal_axis = Input.get_axis("move_left", "move_right")
		keyboard_movement_vector.x = horizontal_axis
		keyboard_movement_vector.y = vertical_axis
		
		if keyboard_movement_vector.length() > 1:
			keyboard_movement_vector = keyboard_movement_vector.normalized()
	
	joystick_movement_vector = keyboard_movement_vector
	return keyboard_movement_vector != Vector2.ZERO

func handle_mouse_movement() -> void:
	var mouse_global_pos = get_global_mouse_position()
	var distance_to_mouse = global_position.distance_to(mouse_global_pos)
	var max_radius_scaled = MAX_RADIUS / main_camera.zoom.x
	
	if distance_to_mouse > max_radius_scaled:
		var direction_to_mouse = (mouse_global_pos - global_position).normalized()
		joystick_movement_vector = direction_to_mouse
	else:
		joystick_movement_vector = Vector2.ZERO

func handle_animation(movement_vector: Vector2) -> void:
	if movement_vector.length() <= MOVEMENT_DEADZONE_PERCENTAGE:
		if idle_timer.is_stopped():
			idle_timer.start()
		return
	else:
		if not idle_timer.is_stopped():
			idle_timer.stop()

	if movement_vector.x > 0:
		astronaut_sprite.position.x = -astronaut_local_position.x
		astronaut_sprite.flip_h = false
		if current_direction != MovementDirection.UP and current_direction != MovementDirection.DOWN:
			astronaut_flashlight.set_light_facing_direction(AstronautFlashlight.LightDirection.RIGHT)
	elif movement_vector.x < 0:
		astronaut_sprite.position.x = astronaut_local_position.x
		astronaut_sprite.flip_h = true
		if current_direction != MovementDirection.UP and current_direction != MovementDirection.DOWN:
			astronaut_flashlight.set_light_facing_direction(AstronautFlashlight.LightDirection.LEFT)

func handle_animation_idle_blink() -> void:
	astronaut_sprite.play("idle_blink")

func _on_animated_sprite_2d_animation_finished() -> void:
	if astronaut_sprite.animation == "idle_blink":
		astronaut_sprite.play("idle")
	elif astronaut_sprite.animation == "halting" or astronaut_sprite.animation == "halting_up" or astronaut_sprite.animation == "halting_down":
		astronaut_sprite.play("idle")
	elif astronaut_sprite.animation == "begin_flight":
		astronaut_sprite.play("flight")
	elif astronaut_sprite.animation == "begin_up":
		astronaut_sprite.play("up")
	elif astronaut_sprite.animation == "idle":
		astronaut_sprite.play("idle")

func handle_movement_began(_direction: MovementDirection) -> void:
	astronaut_flashlight.flame_on()
	begin_flight_sound.play()
	match _direction:
		MovementDirection.FORWARD:
			astronaut_sprite.play("begin_flight")
			astronaut_flashlight.set_light_facing_direction(AstronautFlashlight.LightDirection.RIGHT if joystick_movement_vector.x > 0 else AstronautFlashlight.LightDirection.LEFT)
		MovementDirection.UP:
			astronaut_sprite.play("begin_up")
			astronaut_flashlight.set_light_facing_direction(AstronautFlashlight.LightDirection.UP)
		MovementDirection.DOWN:
			astronaut_sprite.play("idle")
			astronaut_flashlight.set_light_facing_direction(AstronautFlashlight.LightDirection.DOWN)

func handle_movement_ended(_direction: MovementDirection) -> void:
	astronaut_flashlight.flame_off()
	match _direction:
		MovementDirection.FORWARD:
			astronaut_sprite.play("halting")
		MovementDirection.UP:
			astronaut_sprite.play("halting_up")
		MovementDirection.DOWN:
			astronaut_sprite.play("idle") #halting_down

	# delay the stop sound a little to match animations.
	var timer = Timer.new()
	timer.wait_time = 0.35
	timer.one_shot = true
	timer.timeout.connect(func(): end_flight_sound.play())
	add_child(timer)
	timer.start()

func _handle_direction_changed_while_moving(_old_direction: MovementDirection, new_direction: MovementDirection) -> void:
	match new_direction:
		MovementDirection.FORWARD:
			astronaut_sprite.play("begin_flight")
			astronaut_flashlight.set_light_facing_direction(AstronautFlashlight.LightDirection.RIGHT if joystick_movement_vector.x > 0 else AstronautFlashlight.LightDirection.LEFT)
		MovementDirection.UP:
			astronaut_sprite.play("begin_up")
			astronaut_flashlight.set_light_facing_direction(AstronautFlashlight.LightDirection.UP)
		MovementDirection.DOWN:
			astronaut_sprite.play("idle") #begin_down
			astronaut_flashlight.set_light_facing_direction(AstronautFlashlight.LightDirection.DOWN)
