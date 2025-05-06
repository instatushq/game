extends Node2D

class_name Ship

@export var movement_speed: float = 100.0

var screen_touch_position: Vector2 = Vector2.ZERO
var mouse_world_position: Vector2 = Vector2.ZERO

@export var canon_one_active: bool = true
@export var canon_two_active: bool = true
@export var pew_scene: PackedScene = preload("res://assets/ship/projectiles/pew.tscn")

@onready var rb: ShipRigidBody = $RigidBody2D
@onready var health: ShipHealth = $Health
@onready var game_manager: GameManager = %GameManager
@onready var canon_1: Node2D = $RigidBody2D/ShipPoints/Canon
@onready var canon_2: Node2D = $RigidBody2D/ShipPoints/Canon2

var current_velocity: Vector2 = Vector2(0, 0)
var last_recorded_y = position.y;

var can_control: bool = false

func _ready():
	rb.on_impact.connect(_on_impact_with_object)

func _input(event: InputEvent) -> void:
	if game_manager.current_player != GameManager.Player.SHIP: return
	
	mouse_world_position = get_global_mouse_position()
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if canon_one_active:
					create_pew(canon_1)
				if canon_two_active:
					create_pew(canon_2)

func _handle_movement_score() -> void:
	if -rb.global_position.y > last_recorded_y + 100:
		var score_increase = 1
		game_manager.increaseScore(score_increase)
		last_recorded_y = rb.global_position.y

func _physics_process(_delta: float) -> void:
	_handle_movement_score()
	rb.linear_velocity = Vector2(0, -movement_speed)

func toggle_control(new_can_control: bool) -> void:
	can_control = new_can_control
	rb.freeze = not new_can_control

func _on_impact_with_object(body: ShipImpacter) -> void:
	health.decrease_health(randf_range(body.min_damage_range, body.max_damage_range))

func create_pew(canon: Node2D) -> void:
	var pew: Pew = pew_scene.instantiate()
	canon.add_child(pew)
	var center_point_of_all_canons = (canon_1.global_position + canon_2.global_position) / 2
	pew.global_position = canon.global_position
	pew.linear_velocity = (mouse_world_position - canon.global_position).normalized() * pew.speed
	pew.movement_direction = (mouse_world_position - canon.global_position).normalized()
