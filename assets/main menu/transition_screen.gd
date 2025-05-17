class_name TransitionScreen

extends CanvasLayer

enum TransitionPoint {
	MIDDLE,
	END
}

@onready var color_rect = $ColorRect
@onready var animation_player = $AnimationPlayer

signal on_begin_fade_to_black
signal on_transition_finish
signal on_mid_transition_finish

var _callback: Callable
var _transition_point: TransitionPoint
@export var start_dark: bool = false

func _ready() -> void:
	color_rect.visible = false
	animation_player.animation_finished.connect(_on_animation_finished)
	if start_dark:
		color_rect.visible = true
		var canvas_item_modulate = color_rect.modulate
		color_rect.modulate = Color(canvas_item_modulate.r, canvas_item_modulate.g, canvas_item_modulate.b, 1.0)
		animation_player.play("fade_to_view")

func _on_animation_finished(anim_name):
	if anim_name == "fade_to_black":
		on_mid_transition_finish.emit()
		if _callback.is_valid() and _transition_point == TransitionPoint.MIDDLE:
			_callback.call()
		animation_player.play("fade_to_view")
	elif anim_name == "fade_to_view":
		color_rect.visible = false
		on_transition_finish.emit()
		if _callback.is_valid() and _transition_point == TransitionPoint.END:
			_callback.call()

func transition(callback: Callable = Callable(), transition_point: TransitionPoint = TransitionPoint.END):
	_callback = callback
	_transition_point = transition_point
	on_begin_fade_to_black.emit()
	color_rect.visible = true
	animation_player.play("fade_to_black")
