extends Node2D

class_name Ship

@export var movement_speed: float = 100.0
@export var bottom_camera_movement_margin: float = 200.0

var mouse_world_position: Vector2 = Vector2.ZERO

@export var canon_one_active: bool = true
@export var canon_two_active: bool = true
@export var pew_scene: PackedScene = preload("res://assets/ship/projectiles/pew.tscn")

@onready var rb: ShipRigidBody = $RigidBody2D
@onready var health: ShipHealth = $Health
@onready var game_manager: GameManager = %GameManager
@onready var canon_1: Node2D = $RigidBody2D/ShipPoints/Canon
@onready var canon_2: Node2D = $RigidBody2D/ShipPoints/Canon2
@onready var root_of_scene: Node2D = get_tree().root.get_child(0)

var current_velocity: Vector2 = Vector2(0, 0)
var last_recorded_y: float = position.y;

var can_control: bool = false

func _ready():
	rb.on_impact.connect(_on_impact_with_object)

func _input(event: InputEvent) -> void:
	if game_manager.current_player != GameManager.Player.SHIP: return
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if canon_one_active:
					create_pew(canon_1)
				if canon_two_active:
					create_pew(canon_2)
	elif event is InputEventMouseMotion:
		var viewport_size = get_viewport_rect().size
		var mouse_pos = get_viewport().get_mouse_position()
		
		# Only apply restriction if mouse is within viewport bounds
		if mouse_pos.x >= 0 and mouse_pos.x <= viewport_size.x and mouse_pos.y >= 0 and mouse_pos.y <= viewport_size.y:
			if event.relative.y > 0:
				mouse_world_position = get_global_mouse_position()
				var camera = get_viewport().get_camera_2d()
				var bottom_world_pos = camera.global_position + Vector2(0, viewport_size.y / (2 * camera.zoom.y))
				var restricted_y = clamp(mouse_world_position.y, bottom_world_pos.y - bottom_camera_movement_margin, bottom_world_pos.y)
				
				if mouse_world_position.y < restricted_y:
					var current_mouse_pos = get_viewport().get_mouse_position()
					Input.warp_mouse(Vector2(current_mouse_pos.x, viewport_size.y - (bottom_camera_movement_margin * 2)))

func _handle_movement_score() -> void:
	if -rb.global_position.y > last_recorded_y + 100:
		var score_increase = 1
		last_recorded_y = rb.global_position.y
		if game_manager.current_player == GameManager.Player.SHIP:
			game_manager.increaseScore(score_increase)


func _physics_process(_delta: float) -> void:
	_handle_movement_score()
	if game_manager.current_player == GameManager.Player.SHIP:
		mouse_world_position = get_global_mouse_position()
		rb.global_position = mouse_world_position
		var viewport_size = get_viewport_rect().size
		var camera = get_viewport().get_camera_2d()
		var bottom_world_pos = camera.global_position + Vector2(0, viewport_size.y / (2 * camera.zoom.y))
		var restricterd_y = clamp(mouse_world_position.y, bottom_world_pos.y - bottom_camera_movement_margin, bottom_world_pos.y)
		rb.global_position.y = restricterd_y

func toggle_control(new_can_control: bool) -> void:
	can_control = new_can_control
	rb.freeze = not new_can_control

func _on_impact_with_object(body: ShipImpacter) -> void:
	health.decrease_health(randf_range(body.min_damage_range, body.max_damage_range))

func create_pew(canon: Node2D) -> void:
	var pew: Pew = pew_scene.instantiate()
	root_of_scene.add_child(pew)
	pew.global_position = canon.global_position
	pew.linear_velocity = Vector2.UP * pew.speed
