extends TextureRect


func _ready() -> void:
	start_rotation()

func start_rotation() -> void:
	var tween: Tween = create_tween()
	tween.set_loops()
	tween.tween_property(self, "rotation_degrees", 360.0, 8.0).from(0.0).set_trans(Tween.TRANS_LINEAR)
