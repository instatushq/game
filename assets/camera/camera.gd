extends Camera2D

class_name Camera

@onready var astronaut: Astronaut = %Astronaut
@onready var game_manager: GameManager = %GameManager
#@onready var ship: Ship = %Ship
@onready var root_of_scene = get_tree().root.get_child(0)
var last_recorded_camera_position: Vector2 = global_position;
@export var camera_offset_margin: float = 50.0
@export var camera_interpolation_speed: float = 0.005  # Controls how fast the camera moves to its target position


enum FOCUS_TARGETS {
	SHIP,
	ASTRONAUT,
}

func focus_ship() -> void:
	global_position = last_recorded_camera_position
	reparent(root_of_scene) 
	zoom = Vector2.ONE * 2

func focus_astronaut() -> void:
	last_recorded_camera_position = global_position
	reparent(astronaut)
	position = Vector2.ZERO
	zoom = Vector2.ONE * 11.5

func _on_astronaut_on_movement_vector_changed(movement_vector: Vector2) -> void:
	if game_manager.current_player == GameManager.Player.SHIP:
		return

	var target_position = movement_vector * camera_offset_margin
	
	var distance = target_position.length()
	if distance > camera_offset_margin:
		target_position = target_position.normalized() * camera_offset_margin
	
	position = position.lerp(target_position, camera_interpolation_speed)
