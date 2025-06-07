class_name BarrelInvader extends Node2D

var parallax_background_offset: Vector2 = Vector2(0, 0)
@onready var parallax_background:  ParallaxBackgroundController = %ParallaxBackground
@export var vector_offset: Vector2 = Vector2(0, 0)
var init_offset: Vector2 = Vector2(0, 0)
var is_playing: bool = false

signal game_started

func _ready() -> void:
	var parent_issue: Issue = get_parent()
	parent_issue.issue_opened.connect(_on_game_start)

	if parent_issue != null:
		vector_offset = parent_issue.spawn_position
	
	init_offset = parallax_background.offset
	parallax_background.visible = false

func _process(_delta: float) -> void:
	parallax_background.offset = init_offset + (vector_offset * 2)

func _on_game_start() -> void:
	is_playing = true
	parallax_background.visible = true
	game_started.emit()
