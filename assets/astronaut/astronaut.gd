extends CharacterBody2D

class_name Astronaut

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
const MAX_ROTATION: float = deg_to_rad(60.0)
var target_rotation: float = 0.0
var is_starting_rotation: bool = false
const ROTATION_CHANGE_THRESHOLD: float = deg_to_rad(80.0)
var last_movement_direction: Vector2 = Vector2.ZERO
@onready var game_manager: GameManager = %GameManager
@onready var internal_ship: InternalShip = %InternalShip
@onready var cockpit_node: Node2D = %InternalShip/Points/Cockpit
@onready var astronaut_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var idle_timer: Timer = $AnimatedSprite2D/Timer
var is_solving_puzzle: bool = false

func _ready() -> void:
	idle_timer.stop()
	idle_timer.timeout.connect(handle_animation_idle_blink)


func _process(_delta: float) -> void:
	if game_manager.current_player == GameManager.Player.SHIP: return
	astronaut_sprite.modulate = internal_ship.ship_sprite.modulate

func toggle_control(new_can_control: bool) -> void:
	can_control = new_can_control
	frozen = not new_can_control

func _physics_process(delta: float) -> void:
	if frozen or game_manager.is_controlling_ship():
		if game_manager.is_controlling_ship():
			global_position = cockpit_node.global_position
		return

	if isTouching:
		var input_strength := movement_axis.length() / MAX_RADIUS
		var movement_direction := movement_axis.normalized()
		var target_velocity = movement_direction * movement_speed * input_strength
		velocity = velocity.move_toward(target_velocity, acceleration * delta)
		
		var new_target = atan2(movement_direction.y, abs(movement_direction.x))
		if movement_direction.x < 0:
			new_target = -new_target
		
		if abs(new_target) > MAX_ROTATION:
			target_rotation = 0.0
			astronaut_sprite.rotation = 0.0
			is_starting_rotation = false
		else:
			if abs(AngleDifference.angle_difference(astronaut_sprite.rotation, new_target)) > ROTATION_CHANGE_THRESHOLD:
				is_starting_rotation = false
				astronaut_sprite.rotation = new_target

			elif astronaut_sprite.rotation == 0.0 and not is_starting_rotation:
				astronaut_sprite.rotation = new_target
				is_starting_rotation = true
			target_rotation = new_target
	else:
		if damping != 0:
			var damping_factor = 1.0 - (damping * delta)
			velocity *= damping_factor
		target_rotation = 0.0
		is_starting_rotation = false

	if is_starting_rotation:
		astronaut_sprite.rotation = lerp_angle(astronaut_sprite.rotation, target_rotation, rotation_speed * delta)

	if velocity.length() > maximum_speed:
		velocity = velocity.normalized() * maximum_speed
	
	move_and_slide()

func _input(event: InputEvent) -> void:
	if not can_control:
		return
		
	if event is InputEventScreenTouch or event is InputEventMouseButton:
		isTouching = event.pressed
		screen_touch_position = event.position if event.pressed else Vector2.ZERO
		if not isTouching:
			movement_axis = Vector2.ZERO
	elif isTouching and (event is InputEventScreenDrag or event is InputEventMouseMotion):
		var drag_vector: Vector2 = event.position - screen_touch_position
		if drag_vector.length() > MAX_RADIUS:
			drag_vector = drag_vector.normalized() * MAX_RADIUS

		movement_axis = drag_vector
	
	handle_animation(movement_axis)
		

func handle_animation(movement_vector: Vector2) -> void:
	if movement_vector.length() == 0:
		if idle_timer.is_stopped():
			idle_timer.start()
	else:
		if not idle_timer.is_stopped():
			idle_timer.stop()

	if movement_vector.x > 0:
		astronaut_sprite.flip_h = false
	elif movement_vector.x < 0:
		astronaut_sprite.flip_h = true

func handle_animation_idle_blink() -> void:
	astronaut_sprite.play("idle_blink")

func _on_animated_sprite_2d_animation_finished() -> void:
	if astronaut_sprite.animation == "idle_blink":
		astronaut_sprite.play("idle")
