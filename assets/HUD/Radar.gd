extends TextureRect

@export var rotation_speed: float = 0.7  # Duration in seconds for each rotation
@export var pause_duration: float = 0.2  # Duration in seconds for each pause
@export var transition_type: Tween.TransitionType = Tween.TransitionType.TRANS_SPRING


func _ready() -> void:
	start_rotation()

func start_rotation() -> void:
	var tween: Tween = create_tween()
	tween.set_loops()
	
	# Create a sequence that rotates through specific angles with pauses
	tween.tween_property(self, "rotation_degrees", 90.0, rotation_speed).from(0.0).set_trans(transition_type)
	tween.tween_interval(pause_duration)
	tween.tween_property(self, "rotation_degrees", 180.0, rotation_speed).set_trans(transition_type)
	tween.tween_interval(pause_duration)
	tween.tween_property(self, "rotation_degrees", 270.0, rotation_speed).set_trans(transition_type)
	tween.tween_interval(pause_duration)
	tween.tween_property(self, "rotation_degrees", 360.0, rotation_speed).set_trans(transition_type)
	tween.tween_interval(pause_duration)
