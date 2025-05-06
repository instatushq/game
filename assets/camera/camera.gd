extends Camera2D

class_name Camera

@onready var astronaut: Astronaut = get_node("%Astronaut")
@onready var ship: Ship = get_node("%Ship")

enum FOCUS_TARGETS {
	SHIP,
	ASTRONAUT,

}

@export var focus_target: FOCUS_TARGETS = FOCUS_TARGETS.SHIP

var timepassed: int = 0;

func _process(_delta: float) -> void:
	timepassed += 1
	if timepassed > 1:
		focus_ship()

func focus_ship() -> void:
	var ship_parent_target: Node2D = ship.get_node("RigidBody2D")
	reparent(ship_parent_target)
	position = Vector2.ZERO
	zoom = Vector2.ONE * 2

func focus_astronaut() -> void:
	reparent(astronaut)
	position = Vector2.ZERO
	zoom = Vector2.ONE * 10
