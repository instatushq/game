class_name NormalBarrel extends Node

@export_range(0, 4) var explosion_force_multiplier: float = 1
@export_range(0, 60) var blowing_invincibility_frames: int = 3
@onready var barrel_body: BarrelBody = get_parent()
var times_shot: int = 0
var max_shots: int = 3
var frames_since_last_explosion: int = 0

func _ready() -> void:
	barrel_body.on_shot.connect(_on_shot)
	barrel_body.on_contact_explosion.connect(_on_explosion_contact)

func _on_shot() -> void:
	times_shot += 1
	if times_shot >= max_shots:
		barrel_body.on_barrel_destroyed.emit()

func blow_away(cause_location: Vector2) -> void:
	var effect_direction: Vector2 = cause_location.direction_to(barrel_body.global_position)
	barrel_body.apply_force(effect_direction * 100_000 * explosion_force_multiplier)
	barrel_body.apply_torque(randf_range(100_000, 100_000))

func _on_explosion_contact(body: Node2D, explosion_type: BarrelBody.EXPLOSION_TYPE, intensity: ExplosionNuke.ExplosionIntensity) -> void:
	if frames_since_last_explosion <= blowing_invincibility_frames:
		return
	else:
		frames_since_last_explosion = 0

	print(":boom!")

	match explosion_type:
		BarrelBody.EXPLOSION_TYPE.NUKE:
			if intensity == ExplosionNuke.ExplosionIntensity.HIGH:
				barrel_body.queue_free()
			elif intensity == ExplosionNuke.ExplosionIntensity.MEDIUM:
				blow_away(body.global_position)
		BarrelBody.EXPLOSION_TYPE.TNT:
			blow_away(body.global_position)

func _physics_process(_delta: float) -> void:
	frames_since_last_explosion += 1
