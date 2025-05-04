extends RigidBody2D

class_name ShipRigidBody

signal on_impact(impacter: ShipImpacter)

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body) -> void:
	if body is ShipImpacter:
		var ship_impacter: ShipImpacter = body;
		if ship_impacter.amount_of_impacts < ship_impacter.maximum_amount_of_impacts:
			on_impact.emit(ship_impacter)
