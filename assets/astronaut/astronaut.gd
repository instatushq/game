class_name Astronaut extends CharacterBody2D

enum MovementDirection { FORWARD, UP, DOWN }

signal movement_began(direction: MovementDirection)
signal movement_ended(direction: MovementDirection)
signal on_movement_vector_changed(movement_vector: Vector2)
signal direction_changed_while_moving(old_direction: MovementDirection, new_direction: MovementDirection)

var frozen: bool = false
var can_control: bool = false
var movement_axis: Vector2 = Vector2.ZERO
var screen_touch_position: Vector2 = Vector2.ZERO
var isTouching: bool = false
const MAX_RADIUS := 100
@export var movement_speed: float = 300.0
@export var maximum_speed: float = 300.0
@export var damping: float = 0.0
@export var acceleration: float = 2000.0
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
var is_solving_puzzle: bool = false
@onready var astronaut_local_position: Vector2 = astronaut_sprite.position
var current_direction: MovementDirection = MovementDirection.FORWARD
const MOVEMENT_DEADZONE_PERCENTAGE: float = 0.5
var joystick_movement_vector: Vector2 = Vector2.ZERO
var _has_movement_begun_already: bool = false
var keyboard_movement_vector: Vector2 = Vector2.ZERO
var key_states: Dictionary = {
	KEY_W: false,
	KEY_S: false,
	KEY_A: false,
	KEY_D: false
}

func _ready() -> void:
	idle_timer.stop()
	idle_timer.timeout.connect(handle_animation_idle_blink)
	movement_began.connect(handle_movement_began)
	movement_ended.connect(handle_movement_ended)
	direction_changed_while_moving.connect(_handle_direction_changed_while_moving)
	internal_ship.on_ship_revived.connect(func(): astronaut_flashlight.on_ship_revived())
	internal_ship.on_ship_broken.connect(_on_internal_ship_broke)

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
		velocity = velocity.move_toward(target_velocity, acceleration * delta)
		
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

	if (event is InputEventMouseButton or event is InputEventScreenTouch) or (isTouching and (event is InputEventScreenDrag or event is InputEventMouseMotion)):
		handle_mouse_input(event)

	if event is InputEventKey:
		handle_keyboard_input(event)

	handle_animation(joystick_movement_vector)
	

func handle_keyboard_input(event: InputEvent) -> bool:
	if event is InputEventKey:
		if event.keycode in key_states:
			key_states[event.keycode] = event.pressed
			
			keyboard_movement_vector.x = 0
			keyboard_movement_vector.y = 0
			
			if key_states[KEY_W]: keyboard_movement_vector.y -= 1
			if key_states[KEY_S]: keyboard_movement_vector.y += 1
			if key_states[KEY_A]: keyboard_movement_vector.x -= 1
			if key_states[KEY_D]: keyboard_movement_vector.x += 1
			
			if keyboard_movement_vector.length() > 1:
				keyboard_movement_vector = keyboard_movement_vector.normalized()
	
	joystick_movement_vector = keyboard_movement_vector
	return keyboard_movement_vector != Vector2.ZERO

func handle_mouse_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch or event is InputEventMouseButton:
		var was_touching = isTouching
		isTouching = event.pressed
		screen_touch_position = event.position if event.pressed else Vector2.ZERO
		
		if event.pressed and not was_touching:
			var movement_direction := movement_axis.normalized()
			joystick_movement_vector = movement_direction
		elif not event.pressed and was_touching and _has_movement_begun_already:
			movement_axis = Vector2.ZERO
			joystick_movement_vector = Vector2.ZERO
	
	elif isTouching and (event is InputEventScreenDrag or event is InputEventMouseMotion):
		var drag_vector: Vector2 = event.position - screen_touch_position
		if drag_vector.length() > MAX_RADIUS:
			drag_vector = drag_vector.normalized() * MAX_RADIUS

		movement_axis = drag_vector
		var normalized_joystick = drag_vector / MAX_RADIUS
		joystick_movement_vector = normalized_joystick

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
	elif astronaut_sprite.animation == "idle": # begin_down
		astronaut_sprite.play("idle") #down

func handle_movement_began(_direction: MovementDirection) -> void:
	astronaut_flashlight.flame_on()
	match _direction:
		MovementDirection.FORWARD:
			astronaut_sprite.play("begin_flight")
		MovementDirection.UP:
			astronaut_sprite.play("begin_up")
			astronaut_flashlight.set_light_facing_direction(AstronautFlashlight.LightDirection.UP)
		MovementDirection.DOWN:
			astronaut_sprite.play("idle") # begin_down
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

func _handle_direction_changed_while_moving(_old_direction: MovementDirection, new_direction: MovementDirection) -> void:
	match new_direction:
		MovementDirection.FORWARD:
			astronaut_sprite.play("begin_flight")
		MovementDirection.UP:
			astronaut_sprite.play("begin_up")
			astronaut_flashlight.set_light_facing_direction(AstronautFlashlight.LightDirection.UP)
		MovementDirection.DOWN:
			astronaut_sprite.play("idle") #begin_down
			astronaut_flashlight.set_light_facing_direction(AstronautFlashlight.LightDirection.DOWN)
