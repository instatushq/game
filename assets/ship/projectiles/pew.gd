extends RigidBody2D

class_name Pew

@export var movement_direction: Vector2 = Vector2.ZERO
@export var speed: int = 1000
@onready var sprite = $Sprite2D
@onready var particle_impact_effect = $CPUParticles2D
@onready var collision_shape_2d = $CollisionShape2D

func _ready() -> void:
	linear_velocity = movement_direction * speed


func _process(_delta: float) -> void:
	var angle = movement_direction.angle()
	sprite.rotation = angle

func _on_body_entered(body: Node2D) -> void:
	if body is ShipImpacter:
		_on_impact()

func _on_impact() -> void:
	sprite.visible = false
	linear_velocity = Vector2.ZERO
	particle_impact_effect.emitting = true
	call_deferred("disable_collision")

func disable_collision() -> void:
	collision_shape_2d.disabled = true

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()

func _on_cpu_particles_2d_finished() -> void:
	queue_free()
