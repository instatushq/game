extends AnimatedSprite2D

@onready var trail_sprite: AnimatedSprite2D = $Trail
@onready var light_sprite: AnimatedSprite2D = $Light
@onready var fuel: ShipFuel = $"../../../Fuel"
@onready var health: ShipHealth = $"../../../Health"

var is_fueled_up: bool = true
var is_healed_up: bool = true

func _ready() -> void:
	fuel.on_fuel_change.connect(_on_fuel_change)
	health.on_health_change.connect(_on_health_change)

func _on_fuel_change(_old_fuel: float, new_fuel: float) -> void:
	if new_fuel <= 0 and is_fueled_up:
		is_fueled_up = false
		_on_fueled_status_change(is_fueled_up)
	elif new_fuel > 0 and not is_fueled_up:
		is_fueled_up = true
		_on_fueled_status_change(is_fueled_up)

func _on_health_change(_old_health: float, new_health: float) -> void:
	if new_health <= 0 and is_healed_up:
		is_healed_up = false
		_on_fueled_status_change(is_healed_up)
	elif new_health > 0 and not is_healed_up:
		is_healed_up = true
		_on_fueled_status_change(is_healed_up)

func _on_fueled_status_change(is_fueled: bool) -> void:
	if !is_fueled:
		light_sprite.play("fuel_end")
		trail_sprite.play("fuel_end")
		play("fuel_end")
