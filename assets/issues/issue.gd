extends CanvasLayer

class_name Issue

signal issue_resolved

func _ready() -> void:
	visible = false
	issue_resolved.connect(close_issue) 

func open_issue() -> void:
	visible = true

func close_issue() -> void:
	visible = false
