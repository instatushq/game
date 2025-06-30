class_name Issue extends Node2D

@export_range(0, 100) var min_hp_revive: int = 20
@export_range(0, 100) var max_hp_revive: int = 25

@export var default_visibility: bool = false
@export var spawn_position: Vector2 = Vector2(5000, 5000)
@export var allow_abort: bool = true
@export var abort_font: Font = null
var abort_ui: PackedScene = preload("res://assets/issues/abort_ui.tscn")
@onready var abort_ui_instance: CanvasLayer = null
@onready var abort_loading_bar = null
@onready var custom_camera: Camera2D = null
@onready var canvas_layer: CanvasLayer = null
@onready var scene_root = get_tree().root.get_child(get_tree().root.get_children().size() - 1)
@onready var abort_timer: Timer = Timer.new()

var main_camera: Camera2D = null
var is_open: bool = false

signal issue_resolved
signal issue_opened
signal issue_closed
signal issue_failed
signal issue_aborted
signal issue_segment_success(hp_restored: int)

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
	issue_aborted.connect(abort_issue)
	abort_timer.timeout.connect(abort_issue)
	custom_camera = _find_camera2d(self)
	canvas_layer = _find_canvas_layer(self)
	var game_manager: GameManager = scene_root.get_node("%GameManager")
	if game_manager != null:
		main_camera = game_manager.camera
	
	if canvas_layer != null:
		canvas_layer.visible = default_visibility
	
	global_position = spawn_position
	visible = default_visibility
	
	abort_timer.one_shot = true
	add_child(abort_timer)

	abort_ui_instance = abort_ui.instantiate()
	add_child(abort_ui_instance)
	abort_ui_instance.visible = false
	abort_loading_bar = abort_ui_instance.get_node("Container/Background/BarBG2")
	abort_loading_bar.scale.x = 0
	
	# for testing bugs
	# open_issue()

func open_issue() -> void:
	is_open = true
	visible = true
	if custom_camera:
		custom_camera.make_current()
	if canvas_layer:
		canvas_layer.visible = true
	
	issue_opened.emit()

func close_issue() -> void:
	is_open = false
	if custom_camera and main_camera:
		main_camera.make_current()
	if canvas_layer:
		canvas_layer.visible = false

	issue_closed.emit()

func _input(event: InputEvent) -> void:
	if not allow_abort: return
	if event.is_action_pressed("abort"):
		if abort_timer.is_stopped() or abort_timer.paused:
			abort_timer.start(1.5)
			abort_ui_instance.visible = true
	elif event.is_action_released("abort"):
		abort_timer.stop()
		abort_loading_bar.scale.x = 0
		abort_ui_instance.visible = false

func _physics_process(_delta: float) -> void:
	if not abort_timer.paused and not abort_timer.is_stopped():
		var time_progress = clamp(1 - (abort_timer.time_left / abort_timer.wait_time), 0, 1)
		abort_loading_bar.scale.x = time_progress

func abort_issue() -> void:
	abort_ui_instance.visible = false
	if is_open:
		close_issue()
		issue_aborted.emit()

func on_issue_segment_success(hp_restored: int) -> void:
	issue_segment_success.emit(hp_restored)