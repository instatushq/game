extends ParallaxBackground

@export var scroll_speed: float = 75.0
@onready var game_manager: GameManager = %GameManager

func _ready() -> void:
	game_manager.on_solving_puzzle_changed.connect(_on_solving_puzzle_changed)

func _on_solving_puzzle_changed(solving_puzzle: bool) -> void:
	visible = not solving_puzzle

func _physics_process(_delta: float) -> void:
	scroll_base_offset.y += scroll_speed * _delta
	scroll_base_offset.y = wrapf(scroll_base_offset.y, -50000, 50000)
