class_name ExplosionTNT extends Area2D

@export var auto_explode: bool = false
@onready var explosion_collision_shape: CollisionShape2D = $CollisionShape2D
@onready var explosion_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var explosion_sprites_container: Node2D = $SurroundSprites
@onready var explosion_audio: AudioStreamPlayer2D = $Explode
@onready var explosion_particles: CPUParticles2D = $ExplosionParticles
@export_range(10, 300) var harsh_explosion_radius: float = 100
@export_range(10, 300) var explosion_radius: float = 100

enum ExplosionIntensity {
	LOW,
	MEDIUM,
	HIGH
}

var explosion_sprites: Array[AnimatedSprite2D] = []

func _ready() -> void:
	explosion_sprite.frame_changed.connect(_on_explosion_frame_changed)
	for child in explosion_sprites_container.get_children():
		explosion_sprites.append(child)
		
	if auto_explode:
		_begin_explosion_sequence()

func _begin_explosion_sequence() -> void:
	explosion_sprite.play("boom")
	explosion_audio.play(0.15)
	
func _play_surround_sprites() -> void:
	for sprite in explosion_sprites:
		sprite.play("boom")

func _on_explosion_frame_changed() -> void:
	if explosion_sprite.animation != "boom": return
	var explosion_shape: CircleShape2D = explosion_collision_shape.shape
	
	if explosion_sprite.frame == 2:
		explosion_sprite.pause()
		explosion_shape.radius = harsh_explosion_radius
		_play_surround_sprites()
		await get_tree().create_timer(0.02).timeout
		explosion_sprite.play()
		explosion_particles.emitting = true
		await get_tree().create_timer(0.09).timeout
		explosion_shape.radius = explosion_radius

func calculate_explosion_intensity_percentage(target_global_position: Vector2) -> ExplosionIntensity:
	var distance_to_target: float = global_position.distance_to(target_global_position)
	if distance_to_target <= harsh_explosion_radius:
		return ExplosionIntensity.HIGH
	elif distance_to_target < explosion_radius:
		return ExplosionIntensity.MEDIUM
	
	return ExplosionIntensity.LOW
