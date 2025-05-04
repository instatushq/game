extends RigidBody2D

class_name ShipRigidBody

signal on_impact(impacter: ShipImpacter)

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body) -> void:
	if body is ShipImpacter: on_impact.emit(body)
