class_name AstronautFlashlight extends PointLight2D

@onready var astronaught_light_scale: Vector2 = scale
@onready var astronaut_light_energy: float = energy

@export var light_transition_duration: float = 0.5

enum LightDirection {
	RIGHT,
	LEFT,
	UP,
	DOWN
}

var current_light_tween: Tween = null

var _is_ship_broken: bool = false

func _ready() -> void:
	energy = 0.0

func interpolate_light_energy(target: float) -> void:
	if current_light_tween:
		current_light_tween.kill()
	
	current_light_tween = create_tween()
	current_light_tween.tween_property(self, "energy", target, light_transition_duration)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)

func on_ship_broken(flame_on_question_mark: bool = false) -> void:
	_is_ship_broken = true
	if flame_on_question_mark: flame_on()

func on_ship_revived() -> void:
	_is_ship_broken = false
	flame_off()

func flame_on() -> void:
	if not _is_ship_broken: return
	interpolate_light_energy(astronaut_light_energy)

func flame_off() -> void:
	interpolate_light_energy(0.0)

func set_light_facing_direction(direction: LightDirection) -> void:
	match direction:
		LightDirection.RIGHT:
			scale = astronaught_light_scale
		LightDirection.LEFT:
			scale = astronaught_light_scale * Vector2(-1, -1)
		LightDirection.UP:
			scale = astronaught_light_scale * Vector2(1, -1)
		LightDirection.DOWN:
			scale = astronaught_light_scale * Vector2(-1, 1)
