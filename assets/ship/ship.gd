extends Node2D

class_name Ship

@export var movement_speed: float = 300.0
@export var maximum_speed: float = 300.0
@export var base_travelling_speed: float = 100.0

var movement_axis: Vector2 = Vector2.ZERO
var screen_touch_position: Vector2 = Vector2.ZERO
var isTouching: bool = false

const MAX_RADIUS := 100
@onready var rb: ShipRigidBody = $RigidBody2D  # Correctly wait for the node to be ready
@onready var health: ShipHealth = $Health
@onready var game_manager: GameManager = get_node("%GameManager")

var current_velocity: Vector2 = Vector2(0, 0)
var last_recorded_y = position.y;

var can_control: bool = false

func _ready():
	rb.on_impact.connect(_on_impact_with_object)

func _input(event):
	if not game_manager.current_player == game_manager.Player.SHIP: return
	
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

func _draw() -> void:
	if isTouching:
		var viewport_rect = get_viewport_rect()
		var viewport_transform = get_viewport().get_canvas_transform()
		var bottom_left = viewport_transform.affine_inverse() * Vector2(MAX_RADIUS, viewport_rect.size.y - MAX_RADIUS)
		draw_circle(bottom_left, MAX_RADIUS, Color(0.3, 2, 0, 0.4))
		draw_circle(bottom_left + movement_axis, 20, Color(0, 0.5, 1, 0.2))
		
func _process(_delta: float) -> void:
	queue_redraw()

func _handle_movement_score() -> void:
	if -rb.global_position.y > last_recorded_y + 100:
		var score_increase = 1
		game_manager.increaseScore(score_increase)
		last_recorded_y = rb.global_position.y

func _physics_process(_delta: float) -> void:
	_handle_movement_score()
	if isTouching:
		var input_strength := movement_axis.length() / MAX_RADIUS
		var movement_direction := movement_axis.normalized()
		var scaled_force := movement_direction * movement_speed * input_strength
		rb.apply_force(scaled_force)

	# Clamp velocity
	if rb.linear_velocity.length() > maximum_speed:
		rb.linear_velocity = rb.linear_velocity.normalized() * maximum_speed
	elif abs(rb.linear_velocity.y) < game_manager.base_travelling_speed:
		rb.apply_force(Vector2.UP * game_manager.base_travelling_speed * 0.4)

func toggle_control(new_can_control: bool) -> void:
	can_control = new_can_control
	rb.freeze = not new_can_control

func _on_impact_with_object(body: ShipImpacter) -> void:
	health.decrease_health(randf_range(body.min_damage_range, body.max_damage_range))