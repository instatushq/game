extends Node2D

func _on_button_pressed() -> void:
	var parent: Issue = get_parent()
	parent.issue_resolved.emit()
