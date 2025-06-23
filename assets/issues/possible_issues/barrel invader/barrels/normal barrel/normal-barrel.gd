class_name NormalBarrel extends Node

@onready var barrel_body: BarrelBody = get_parent()
var times_shot: int = 0
var max_shots: int = 3

func _ready() -> void:
	barrel_body.on_shot.connect(_on_shot)

func _on_shot() -> void:
	times_shot += 1
	if times_shot >= max_shots:
		barrel_body.on_barrel_destroyed.emit()
