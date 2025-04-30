extends Node2D

@export var movement_speed: float = 300.0;
@export var maximum_speed: float = 300.0;

var movement_axis: Vector2 = Vector2.ZERO
var screen_touch_position: Vector2 = Vector2.ZERO
var isTouching: bool = false

const MAX_RADIUS := 100.0
@onready var rb := $RigidBody2D  # Correctly wait for the node to be ready

var current_velocity: Vector2 = Vector2(0, 0)

func _input(event):
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
	queue_redraw()

func _draw() -> void:
	if isTouching:
		draw_circle(screen_touch_position, MAX_RADIUS, Color(1, 0, 0, 0.4))
		draw_circle(screen_touch_position + movement_axis, 20, Color(0, 0.5, 1, 0.2))

func _physics_process(delta: float) -> void:
	if isTouching:
		var input_strength := movement_axis.length() / MAX_RADIUS
		var movement_direction := movement_axis.normalized()
		var scaled_force := movement_direction * movement_speed * input_strength
		rb.apply_force(scaled_force)

	# Clamp velocity
	if rb.linear_velocity.length() > maximum_speed:
		rb.linear_velocity = rb.linear_velocity.normalized() * maximum_speed
