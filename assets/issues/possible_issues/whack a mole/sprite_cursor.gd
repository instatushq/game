class_name SpriteCursor extends AnimatedSprite2D

@export var offset_from_cursor: Vector2 = Vector2.ZERO
@onready var animation_player: AnimationPlayer = $Hit
@export var whack_a_mole: WhackAMole = null

func _ready() -> void:
	animation_finished.connect(_on_animation_finished)
	whack_a_mole.on_successful_hit.connect(_on_hit)
	whack_a_mole.on_missed_hit.connect(_on_miss)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var mouse_position = get_global_mouse_position()
		global_position = mouse_position + (offset_from_cursor * scale)

	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		animation_player.play("Hit")

func _notification(what) -> void:
	if what == NOTIFICATION_PREDELETE:
		pass

func _on_animation_finished() -> void:
	if animation == "hit" or animation == "miss":
		play("default")

func _on_hit() -> void:
	play("default")
	play("hit")

func _on_miss() -> void:
	play("default")
	play("miss")
