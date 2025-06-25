extends Node2D

@onready var barrel_body: BarrelBody = get_parent()
@export var explosion_scene: PackedScene = null

signal on_explosion_triggered

func _ready() -> void:
	on_explosion_triggered.connect(_on_explode)
	barrel_body.on_shot.connect(trigger_nuke)
	barrel_body.on_contact_explosion.connect(_on_contact_explosion)

func _on_contact_explosion(body: Node2D, explosion_type: BarrelBody.EXPLOSION_TYPE, intensity: ExplosionNuke.ExplosionIntensity) -> void:
	if explosion_type == BarrelBody.EXPLOSION_TYPE.TNT:
		on_explosion_triggered.emit()
	elif explosion_type == BarrelBody.EXPLOSION_TYPE.NUKE:
		on_explosion_triggered.emit()

func _on_explode() -> void:
	if explosion_scene != null:
		var explosion = explosion_scene.instantiate()
		explosion.global_position = barrel_body.global_position
		barrel_body.get_parent().add_child(explosion)
	barrel_body.call_deferred("queue_free")

func trigger_nuke() -> void:
	on_explosion_triggered.emit()
