extends RigidBody2D

class_name ShipImpacter

@export var maximum_amount_of_impacts: int = 1
@export var min_damage_range: float = 2
@export var max_damage_range: float = 8

var amount_of_impacts = 0;

signal on_impact_ship(ship: Node2D, current_impact_count: int, max_impact_count: int)
signal on_shot(body: Node2D)

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body) -> void:
	var viewport = get_viewport()
	var viewport_rect = viewport.get_visible_rect()
	var viewport_pos = viewport.get_canvas_transform() * global_position
	if not viewport_rect.has_point(viewport_pos):
		if body is Pew:
			body.queue_free()
		return
		
	if body.get_parent().name.to_lower() == "ship" and amount_of_impacts < maximum_amount_of_impacts:
		amount_of_impacts += 1
		on_impact_ship.emit(body.get_parent(), amount_of_impacts, maximum_amount_of_impacts)
	elif body is Pew:
		on_shot.emit(body)
