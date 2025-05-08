extends Camera2D

class_name Camera

@onready var astronaut: Astronaut = %Astronaut
@onready var game_manager: GameManager = %GameManager
@onready var ship: Ship = %Ship
@onready var root_of_scene: Node2D = get_tree().root.get_child(0)
var last_recorded_camera_position: Vector2 = global_position;

var movement_speed: float = 100.0

enum FOCUS_TARGETS {
	SHIP,
	ASTRONAUT,
}

@export var focus_target: FOCUS_TARGETS = FOCUS_TARGETS.SHIP

var timepassed: int = 0;

func _physics_process(_delta: float) -> void:
	if game_manager.current_player == GameManager.Player.SHIP:
		global_position.y -= movement_speed * _delta

func _process(_delta: float) -> void:
	timepassed += 1
	if timepassed == 1:
		focus_ship()

func focus_ship() -> void:
	global_position = last_recorded_camera_position
	reparent(root_of_scene) 
	zoom = Vector2.ONE * 2

func focus_astronaut() -> void:
	last_recorded_camera_position = global_position
	reparent(astronaut)
	position = Vector2.ZERO
	zoom = Vector2.ONE * 5
