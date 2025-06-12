class_name Ship extends Node2D

@export var movement_speed: float = 10
@export var bottom_camera_movement_margin: float = 100.0
var side_movement_padding: float = 48.0

var mouse_world_position: Vector2 = Vector2.ZERO

@export var cannon_one_active: bool = true
@export var cannon_two_active: bool = true
@export var pew_scene: PackedScene = preload("res://assets/ship/projectiles/pew.tscn")
@export var fire_cooldown: float = 0.15

@onready var rb: ShipRigidBody = $RigidBody2D
@onready var sprites_animation_player: AnimationPlayer = $RigidBody2D/SpritesContainer/SpritesAnimations
@onready var cannon_1: Node2D = $RigidBody2D/ShipPoints/Canon
@onready var cannon_2: Node2D = $RigidBody2D/ShipPoints/Canon2
@onready var game_manager: BarrelInvader = get_parent()

var current_velocity: Vector2 = Vector2(0, 0)
var last_recorded_y: float = position.y;

var can_control: bool = false
var can_fire: bool = true
var fire_timer: float = 0.0
var input_buffered: bool = false
var is_firing: bool = false
var current_ship_y_position: float = 300.0

var ship_position: Vector2 = Vector2.ZERO
var is_keyboard_controlled: bool = true
var y_position_synced: bool = false

@export var game_camera: Camera2D

func _ready():
	rb.on_impact.connect(_on_impact_with_object)
	visible = false
	game_manager.game_started.connect(func(): visible = true)
	
func _process(delta: float) -> void:
	if not game_manager.is_playing: return

	if not can_fire:
		fire_timer += delta
		if fire_timer >= fire_cooldown:
			can_fire = true
			fire_timer = 0.0
			if input_buffered or is_firing:
				input_buffered = false
				can_fire = false

func _physics_process(_delta: float) -> void:
	var input_axis = Vector2(Input.get_axis("move_left", "move_right"), Input.get_axis("move_up", "move_down"))

	_handle_ship_movement(input_axis, game_camera)
	
	rb.enforce_global_position(game_camera.global_position + ship_position)

	if Input.is_action_pressed("fire_cannon") and can_fire and game_manager.is_playing:
		_fire_cannons()
		can_fire = false

func _input(event: InputEvent) -> void:
	var input_axis = Vector2.ZERO
	
	if event is InputEventMouseMotion:
		input_axis = Vector2(event.relative.x, event.relative.y).normalized() * 0.5

	_handle_ship_movement(input_axis, game_camera)

func _handle_ship_movement(input_axis: Vector2, camera: Camera2D) -> void:
	var viewport_size = get_viewport_rect().size
	var bottom_edge = ((camera.global_position.y + (viewport_size.y / camera.zoom.y) / 2))
	var right_edge = ((camera.global_position.x + (viewport_size.x / camera.zoom.x) / 2))
	var left_edge = ((camera.global_position.x - viewport_size.x) / camera.zoom.x) / 2
	var final_ship_position_unrestricted = ship_position + (input_axis * movement_speed)
	var final_ship_global_position = camera.global_position + final_ship_position_unrestricted

	var x_position_restricted = clamp(final_ship_global_position.x, left_edge + side_movement_padding, right_edge - side_movement_padding)
	var bottom_edge_to_center = bottom_edge - camera.global_position.y
	var y_position_restricted = clamp(final_ship_position_unrestricted.y, bottom_edge_to_center - bottom_camera_movement_margin, bottom_edge_to_center)
	
	if game_manager.is_playing:
		ship_position = Vector2(x_position_restricted - camera.global_position.x, y_position_restricted)

func toggle_control(new_can_control: bool) -> void:
	can_control = new_can_control
	rb.freeze = not new_can_control

func _on_impact_with_object(_body: ShipImpacter) -> void:
	#health.decrease_health(randf_range(body.min_damage_range, body.max_damage_range))
	pass

func create_pew(cannon: Node2D) -> void:
	var pew: Pew = pew_scene.instantiate()
	game_manager.add_child(pew)
	pew.global_position = cannon.global_position
	pew.linear_velocity = Vector2.UP * pew.speed

func _fire_cannons() -> void:
	sprites_animation_player.play("shoot")
	if cannon_one_active:
		create_pew(cannon_1)
	if cannon_two_active:
		create_pew(cannon_2)
