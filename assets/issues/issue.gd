extends CanvasLayer

class_name Issue

@export var default_visibility: bool = false

signal issue_resolved

func _ready() -> void:
	visible = default_visibility
	issue_resolved.connect(close_issue) 

func open_issue() -> void:
	visible = true

func close_issue() -> void:
	visible = false
