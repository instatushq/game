class_name VFXAsteroidExplode extends CPUParticles2D

@export var normal_explosion: bool = true
@onready var explosion_animation: AnimatedSprite2D = $Explosion

func _ready() -> void:
	explosion_animation.play("normal" if normal_explosion else "special")
