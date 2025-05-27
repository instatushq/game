extends Node2D

class_name Ship

@export var movement_speed: float = 100.0
@export var bottom_camera_movement_margin: float = 100.0
var side_movement_padding: float = 48.0

var mouse_world_position: Vector2 = Vector2.ZERO

@export var canon_one_active: bool = true
@export var canon_two_active: bool = true
@export var pew_scene: PackedScene = preload("res://assets/ship/projectiles/pew.tscn")
@export var fire_cooldown: float = 0.15

@onready var rb: ShipRigidBody = $RigidBody2D
@onready var sprites_animation_player: AnimationPlayer = $RigidBody2D/SpritesContainer/SpritesAnimations
@onready var canon_1: Node2D = $RigidBody2D/ShipPoints/Canon
@onready var canon_2: Node2D = $RigidBody2D/ShipPoints/Canon2
@onready var root_of_scene = get_tree().root.get_child(2)

var current_velocity: Vector2 = Vector2(0, 0)
var last_recorded_y: float = position.y;

var can_control: bool = false
var can_fire: bool = true
var fire_timer: float = 0.0
var input_buffered: bool = false
var is_firing: bool = false
var current_ship_y_position: float = 300.0

var y_position = 0
var is_keyboard_controlled: bool = true

func _ready():
	rb.on_impact.connect(_on_impact_with_object)

func _process(delta: float) -> void:
	if not can_fire:
		fire_timer += delta
		if fire_timer >= fire_cooldown:
			can_fire = true
			fire_timer = 0.0
			if input_buffered or is_firing:
				input_buffered = false
				_fire_canons()
				can_fire = false

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_firing = true
				if can_fire:
					_fire_canons()
					can_fire = false
				else:
					input_buffered = true
			else:
				is_firing = false
	elif event is InputEventMouseMotion:
		is_keyboard_controlled = false
	elif event is InputEventKey:
		is_keyboard_controlled = true

func _physics_process(_delta: float) -> void:
	var viewport_size = get_viewport_rect().size
	var camera = get_viewport().get_camera_2d()
	
	var top_edge = camera.global_position.y - viewport_size.y / 2 * camera.zoom.y
	var bottom_edge = camera.global_position.y + viewport_size.y / 2 * camera.zoom.y
	var right_edge = camera.global_position.x + viewport_size.x / 2 * camera.zoom.x
	var left_edge = camera.global_position.x - viewport_size.x / 2 * camera.zoom.x
	
	
	# mouse movement
	if not is_keyboard_controlled:
		mouse_world_position = get_global_mouse_position()
		const vertical_ship_padding = 50
		var restricted_y = clamp(mouse_world_position.y + vertical_ship_padding, camera.global_position.y, bottom_edge - 1000)
		var restricted_x = clamp(mouse_world_position.x, left_edge + 1400, right_edge - 1400)
		rb.global_position = Vector2(restricted_x, restricted_y)

	# keyboard movement
	if is_keyboard_controlled:
		rb.global_position.y = camera.global_position.y + y_position
		var verticalDirection := Input.get_axis("move_up", "move_down")
		if verticalDirection < 0:
			if camera.global_position.y + y_position > top_edge + 1200:
				y_position -= 12
		elif verticalDirection > 0:
			if camera.global_position.y + y_position < bottom_edge - 1000:
				y_position += 8
		var direction := Input.get_axis("move_left", "move_right")
		if direction < 0:
			if (rb.global_position.x > left_edge + 1500):
				rb.global_position.x -= 10
		elif direction > 0:
			if (rb.global_position.x < right_edge - 1500):
				rb.global_position.x += 10


func toggle_control(new_can_control: bool) -> void:
	can_control = new_can_control
	rb.freeze = not new_can_control

func _on_impact_with_object(_body: ShipImpacter) -> void:
	print("impact")
	#health.decrease_health(randf_range(body.min_damage_range, body.max_damage_range))

func create_pew(canon: Node2D) -> void:
	var pew: Pew = pew_scene.instantiate()
	root_of_scene.add_child(pew)
	pew.global_position = canon.global_position
	pew.linear_velocity = Vector2.UP * pew.speed

func _fire_canons() -> void:
	sprites_animation_player.play("shoot")
	if canon_one_active:
		create_pew(canon_1)
	if canon_two_active:
		create_pew(canon_2)
