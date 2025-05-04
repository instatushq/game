extends RigidBody2D

class_name ShipImpacter

var impacted = false

signal on_impact_ship(ship: Node2D)

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body) -> void:	
	if body.get_parent().name.to_lower() == "ship" and not impacted:
		impacted = true
		on_impact_ship.emit(body.get_parent())
