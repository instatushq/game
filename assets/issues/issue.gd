extends Node2D

class_name Issue

@export_range(0, 100) var min_hp_revive: int = 20
@export_range(0, 100) var max_hp_revive: int = 25

@export var default_visibility: bool = false
@export var spawn_position: Vector2 = Vector2(5000, 5000)
@onready var custom_camera: Camera2D = null
@onready var canvas_layer: CanvasLayer = null
@onready var scene_root = get_tree().root.get_child(get_tree().root.get_children().size() - 1)
var main_camera: Camera2D = null

signal issue_resolved
signal issue_opened
signal issue_closed
signal issue_failed

func _find_camera2d(node: Node) -> Camera2D:
	if node is Camera2D:
		return node
	for child in node.get_children():
		var found = _find_camera2d(child)
		if found:
			return found
	return null

func _find_canvas_layer(node: Node) -> CanvasLayer:
	if node is CanvasLayer and not node is ParallaxBackground:
		return node
	for child in node.get_children():
		var found = _find_canvas_layer(child)
		if found:
			return found
	return null

func _ready() -> void:
	issue_resolved.connect(close_issue)
	issue_failed.connect(close_issue)
	custom_camera = _find_camera2d(self)
	canvas_layer = _find_canvas_layer(self)
	var game_manager: GameManager = scene_root.get_node("%GameManager")
	if game_manager != null:
		main_camera = game_manager.camera
	
	if canvas_layer != null:
		canvas_layer.visible = default_visibility
	
	global_position = spawn_position
	visible = default_visibility

func open_issue() -> void:
	visible = true
	if custom_camera:
		custom_camera.make_current()
	if canvas_layer:
		canvas_layer.visible = true
	
	issue_opened.emit()

func close_issue() -> void:
	if custom_camera and main_camera:
		main_camera.make_current()
	if canvas_layer:
		canvas_layer.visible = false

	issue_closed.emit()
