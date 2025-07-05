class_name BarrelInvader extends Node2D

var parallax_background_offset: Vector2 = Vector2(0, 0)
@onready var parallax_background:  ParallaxBackgroundController = $ParallaxBackground
# @onready var ship_fuel: ShipFuel = $Ship/Fuel
@onready var parent_issue: Issue = get_parent()
@export var vector_offset: Vector2 = Vector2(0, 0)
var init_offset: Vector2 = Vector2(0, 0)
var is_playing: bool = false

signal game_started

func _ready() -> void:
	parent_issue.issue_opened.connect(_on_game_start)
	# ship_fuel.on_fuel_change.connect(_on_fuel_change)
	print(parent_issue.game_manager.ship_health)
	parent_issue.game_manager.ship_health.on_health_change.connect(_on_health_change)

	if parent_issue != null:
		vector_offset = parent_issue.spawn_position
	
	init_offset = parallax_background.offset
	parallax_background.visible = false

func _on_health_change(_old_fuel: float, new_fuel: float) -> void:
	if new_fuel <= 0:
		parent_issue.issue_failed.emit()

func _process(_delta: float) -> void:
	parallax_background.offset = init_offset + (vector_offset * 2)

func _on_game_start() -> void:
	is_playing = true
	parallax_background.visible = true
	game_started.emit()
