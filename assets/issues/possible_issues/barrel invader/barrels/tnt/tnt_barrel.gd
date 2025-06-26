extends Node2D

@export var explosion_scene: PackedScene = null
@export var tnt_sprite: AnimatedSprite2D = null
@export var hole_filler: Sprite2D = null
@export var times_shot_to_blow_up_post_activation: int = 1
@onready var tnt_countdown_audio: AudioStreamPlayer2D = $TNTCountdownAudio
@onready var flash_time: float = 0.1
@onready var barrel_body: BarrelBody = get_parent()

var triggered: bool = false

var time_intervals: Array[float] = [0.5, 0.2, 0.15]

signal on_explosion_triggered

# func _input(event: InputEvent) -> void:
# 	if event.is_action_pressed("interact"):
# 		on_explosion_triggered.emit()

func _ready() -> void:
	on_explosion_triggered.connect(_on_explode)
	barrel_body.on_shot.connect(_on_shoot_tnt)
	barrel_body.on_contact_explosion.connect(_on_contact_explosion)

func _on_contact_explosion(_body: Node2D, explosion_type: BarrelBody.EXPLOSION_TYPE, intensity: ExplosionNuke.ExplosionIntensity) -> void:
	if explosion_type == BarrelBody.EXPLOSION_TYPE.NUKE:
		if intensity == ExplosionNuke.ExplosionIntensity.HIGH:
			on_explosion_triggered.emit()
	elif explosion_type == BarrelBody.EXPLOSION_TYPE.TNT:
		on_explosion_triggered.emit()

func _on_shoot_tnt() -> void:
	if not triggered:
		trigger_tnt()
	else:
		on_explosion_triggered.emit()

func _on_explode() -> void:
	call_deferred("_spawn_explosion")
	barrel_body.queue_free()

func _spawn_explosion() -> void:
	if explosion_scene != null:
		var explosion = explosion_scene.instantiate()
		explosion.global_position = barrel_body.global_position
		barrel_body.get_parent().add_child(explosion)

func trigger_tnt() -> void:
	if triggered: return
	triggered = true
	
	var current_index = 1
	var beginning_size: int = time_intervals.size()
	
	while time_intervals.size() > 0:
		_update_progress_bar(float(beginning_size - time_intervals.size()) / beginning_size)
		for i in range(current_index + 2 if time_intervals.size() > 1 else current_index + 5):
			var time_interval = time_intervals[0]
			_blink_barrel(flash_time)
			await get_tree().create_timer(time_interval).timeout
		
		time_intervals.pop_front()
		current_index += 1

	on_explosion_triggered.emit()

func _blink_barrel(time_to_tween: float) -> void:
	var animation_tween = create_tween()

	animation_tween.tween_method(
		func(value): tnt_sprite.material.set_shader_parameter("time", value), 0.0, 1.0, time_to_tween / 2.0
	)
	tnt_countdown_audio.play()
	
	tnt_sprite.play("expanded")
	
	animation_tween.tween_method(
		func(value): tnt_sprite.material.set_shader_parameter("time", value),
		1.0, 0.0, time_to_tween
	)
	await get_tree().create_timer(time_to_tween).timeout
	tnt_sprite.play("normal")

func _update_progress_bar(progress: float) -> void:
	hole_filler.scale.y = progress
