class_name ShipRigidBody extends RigidBody2D

var game_position: Vector2 = Vector2.ZERO

signal on_impact(impacter: ShipImpacter)
signal on_barrel_impact(impacter: BarrelBody)

func _ready():
	body_entered.connect(_on_body_entered)

func enforce_global_position(rb_position: Vector2) -> void:
	game_position = rb_position

func _on_body_entered(body) -> void:
	if body is ShipImpacter:
		var ship_impacter: ShipImpacter = body;
		if ship_impacter.amount_of_impacts < ship_impacter.maximum_amount_of_impacts:
			on_impact.emit(ship_impacter)
	elif body is BarrelBody:
		on_barrel_impact.emit(body)
			
func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	state.transform.origin = game_position
