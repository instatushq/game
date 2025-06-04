class_name IssueIcon extends Node2D

@onready var screen_notifier: VisibleOnScreenNotifier2D = $ScreenNotifier
@onready var animated_sprite: AnimatedSprite2D = $ScreenNotifier/AnimatedSprite2D
@onready var indicator_sprite: AnimatedSprite2D = $IndicatorSprite
@onready var indicator_sprite_arrow: AnimatedSprite2D = $IndicatorSprite/Arrow
@export var aim_at_global_position: Vector2 = Vector2.ZERO

enum ICON_TYPE {
	INTERACTABLE,
	EXCLAMATION_MARK
}

func _ready() -> void:
	indicator_sprite.visible = not screen_notifier.is_on_screen()
	screen_notifier.screen_entered.connect(func(): indicator_sprite.visible = false)
	screen_notifier.screen_exited.connect(func(): indicator_sprite.visible = true)

func set_icon(icon_name: ICON_TYPE) -> void:
	match icon_name:
		ICON_TYPE.INTERACTABLE:
			animated_sprite.play("interact")
		ICON_TYPE.EXCLAMATION_MARK:
			animated_sprite.play("exclaim")

func _process(_delta: float) -> void:
	var camera = get_viewport().get_camera_2d()
	if camera == null: return

	_place_indicator_sprite_on_edge_of_screen(camera)
	
	# Calculate angle from indicator position to target
	var direction = aim_at_global_position - indicator_sprite.global_position
	indicator_sprite_arrow.rotation = direction.angle()

func _place_indicator_sprite_on_edge_of_screen(camera: Camera2D) -> void:
	var camera_position = camera.global_position
	var camera_size = camera.get_viewport_rect().size / camera.zoom
	var indicator_size = indicator_sprite.sprite_frames.get_frame_texture("exclaim", 0).get_size()
	var indicator_half_size = indicator_size / 2

	var min_x_position = camera_position.x - camera_size.x / 2 + indicator_half_size.x
	var max_x_position = camera_position.x + camera_size.x / 2 - indicator_half_size.x
	var min_y_position = camera_position.y - camera_size.y / 2 + indicator_half_size.y
	var max_y_position = camera_position.y + camera_size.y / 2 - indicator_half_size.y

	# Calculate direction from camera to target
	var direction = aim_at_global_position - camera_position
	var angle = direction.angle()
	
	# Calculate intersection with screen edges
	var x_position = camera_position.x
	var y_position = camera_position.y
	
	if abs(direction.x) > abs(direction.y):
		# Intersect with left/right edge
		x_position = max_x_position if direction.x > 0 else min_x_position
		y_position = camera_position.y + direction.y * (abs(x_position - camera_position.x) / abs(direction.x))
		y_position = clamp(y_position, min_y_position, max_y_position)
	else:
		# Intersect with top/bottom edge
		y_position = max_y_position if direction.y > 0 else min_y_position
		x_position = camera_position.x + direction.x * (abs(y_position - camera_position.y) / abs(direction.y))
		x_position = clamp(x_position, min_x_position, max_x_position)

	indicator_sprite.global_position = Vector2(x_position, y_position)
	
