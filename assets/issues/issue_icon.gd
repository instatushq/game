class_name IssueIcon extends Node2D

@onready var screen_notifier: VisibleOnScreenNotifier2D = $ScreenNotifier
@onready var animated_sprite: AnimatedSprite2D = $ScreenNotifier/AnimatedSprite2D
@onready var indicator_sprite: AnimatedSprite2D = $IndicatorSprite
@onready var indicator_sprite_arrow: AnimatedSprite2D = $IndicatorSprite/Arrow
@export var aim_at_global_position: Vector2 = Vector2.ZERO
@export var icon_edge_padding: float = 5.0

enum ICON_TYPE {
	INTERACTABLE,
	EXCLAMATION_MARK
}

func _ready() -> void:
	aim_at_global_position = animated_sprite.global_position
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
	
	var direction = (aim_at_global_position - camera_position).normalized()
	
	var camera_left = camera_position.x - camera_size.x/2
	var camera_right = camera_position.x + camera_size.x/2
	var camera_top = camera_position.y - camera_size.y/2
	var camera_bottom = camera_position.y + camera_size.y/2
	
	var t_horizontal = INF
	var t_vertical = INF
	
	if abs(direction.x) > 0.0001:
		var t_left = (camera_left - camera_position.x) / direction.x
		var t_right = (camera_right - camera_position.x) / direction.x
		if t_left > 0: t_horizontal = min(t_horizontal, t_left)
		if t_right > 0: t_horizontal = min(t_horizontal, t_right)
	
	if abs(direction.y) > 0.0001:
		var t_top = (camera_top - camera_position.y) / direction.y
		var t_bottom = (camera_bottom - camera_position.y) / direction.y
		if t_top > 0: t_vertical = min(t_vertical, t_top)
		if t_bottom > 0: t_vertical = min(t_vertical, t_bottom)
	
	var t = min(t_horizontal, t_vertical)
	var intersection_point = camera_position + direction * t
	
	indicator_sprite.global_position = intersection_point - direction * indicator_half_size