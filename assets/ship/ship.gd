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
