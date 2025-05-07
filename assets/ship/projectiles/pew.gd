extends RigidBody2D

class_name Pew

@export var movement_direction: Vector2 = Vector2.ZERO
@export var speed: int = 1000
@onready var sprite = $Sprite2D

func _ready() -> void:
	linear_velocity = movement_direction * speed


func _process(_delta: float) -> void:
	if not is_on_screen():
		queue_free()
	var angle = movement_direction.angle() + PI / 2
	sprite.rotation = angle

func is_on_screen() -> bool:
	var viewport_rect = get_viewport_rect()
	var camera = get_viewport().get_camera_2d()
	if camera:
		var global_pos = global_position
		var camera_pos = camera.global_position
		var view_size = viewport_rect.size
		
		# Check if the projectile is outside the camera view with some margin
		return (global_pos.x > camera_pos.x - view_size.x/2 and
				global_pos.x < camera_pos.x + view_size.x/2 and
				global_pos.y > camera_pos.y - view_size.y/2 and
				global_pos.y < camera_pos.y + view_size.y/2)
	return true

func _on_body_entered(body: Node2D) -> void:
	if body is ShipImpacter:
		_on_impact()

func _on_impact() -> void:
	sprite.visible = false
	linear_velocity = Vector2.ZERO
	await get_tree().create_timer(1.0).timeout
	queue_free()
