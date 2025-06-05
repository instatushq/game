extends Camera2D

@export var movement_speed: float = 100.0
@onready var game_manager: BarrelInvader = get_parent()

func _physics_process(_delta: float) -> void:
	if not game_manager.is_playing: return
	global_position.y -= movement_speed * _delta
