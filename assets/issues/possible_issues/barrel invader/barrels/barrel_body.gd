class_name BarrelBody extends RigidBody2D

enum BARREL_TYPE {
	NORMAL,
	TNT,
	NUKE,
	SLOT,
	REINFORCED
}

@export var barrel_type: BARREL_TYPE = BARREL_TYPE.NORMAL
@onready var screen_detector: VisibleOnScreenNotifier2D = $Screen
@onready var hitbox: Area2D = $HitBox
@export var destruction_particles_scene: PackedScene = null
@export_range(-100, 100) var min_angular_velocity: float = -3.0
@export_range(-100, 100) var max_angular_velocity: float = 3.0

var amount_of_impacts = 0;
@export_range(-100, 100) var movement_speed: float = 100.0

enum EXPLOSION_TYPE {
	TNT,
	NUKE
}

signal on_impact_ship(ship: Node2D)
signal on_shot()
signal on_barrel_destroyed()
signal on_contact_explosion(body: Node2D, explosion_type: EXPLOSION_TYPE, intensity: ExplosionNuke.ExplosionIntensity)

func _ready():
	screen_detector.screen_exited.connect(queue_free)
	hitbox.body_entered.connect(_on_body_entered)
	linear_velocity = Vector2(0, movement_speed)
	angular_velocity = randf_range(min_angular_velocity, max_angular_velocity)
	on_barrel_destroyed.connect(_on_barrel_destroyed)

func _on_barrel_destroyed() -> void:
	queue_free()
	if destruction_particles_scene == null: return
	var particles = destruction_particles_scene.instantiate()
	particles.global_position = global_position
	get_parent().add_child(particles)

func _prevent_auto_destroy() -> void:
	screen_detector.screen_exited.disconnect(queue_free)

func _on_body_entered(body: Node2D) -> void:	
	if body.get_parent().name.to_lower() == "ship":
		amount_of_impacts += 1
		on_impact_ship.emit(body.get_parent())
	elif body is Pew:
		on_shot.emit()
		body._on_impact()

func _nuke_explosion(body: Node2D, intensity: ExplosionNuke.ExplosionIntensity) -> void:
	on_contact_explosion.emit(body, EXPLOSION_TYPE.NUKE, intensity)

func _tnt_explosion(body: Node2D, intensity: ExplosionNuke.ExplosionIntensity) -> void:
	on_contact_explosion.emit(body, EXPLOSION_TYPE.TNT, intensity)
