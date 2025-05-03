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
@onready var game_manager: GameManager = get_node("%GameManager")
@onready var ship: Ship = get_node("%Ship")
@onready var cockpit_node: Node2D = ship.get_node("RigidBody2D/ShipPoints/Cockpit")

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
	else:
		if damping != 0:
			var damping_factor = 1.0 - (damping * delta)
			velocity *= damping_factor

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
		var drag_vector = event.position - screen_touch_position
		if drag_vector.length() > MAX_RADIUS:
			drag_vector = drag_vector.normalized() * MAX_RADIUS
		movement_axis = drag_vector
