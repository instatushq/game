extends Node2D

@export var explosion_scene: PackedScene = null
@export var tnt_sprite: AnimatedSprite2D = null
@export var hole_filler: Sprite2D = null
@onready var tnt_countdown_audio: AudioStreamPlayer2D = $TNTCountdownAudio
@onready var flash_time: float = 0.1
@onready var barrel_body: BarrelBody = get_parent()

var triggered: bool = false

var time_intervals: Array[float] = [0.5, 0.2, 0.15]

signal on_explosion_triggered

func _ready() -> void:
	on_explosion_triggered.connect(_on_explode)
	barrel_body.on_shot.connect(_on_shoot_tnt)

func _on_shoot_tnt() -> void:
	trigger_tnt()

func _on_explode() -> void:
	if explosion_scene != null:
		var explosion = explosion_scene.instantiate()
		explosion.global_position = barrel_body.global_position
		barrel_body.get_parent().add_child(explosion)
	barrel_body.queue_free()

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
