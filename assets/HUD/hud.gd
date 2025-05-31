extends CanvasLayer

@onready var health_label: Label = $HUDUI/Health/HealthContainer/HealthLabel
@onready var health_bar_color_rects_container: VBoxContainer = $HUDUI/Bars
@onready var score_label: Label = $TextureRect/ScoreContainer/Score
@onready var game_manager: GameManager = %GameManager
@onready var ship: ShipHealth = %InternalShip/Health
@onready var issues: Issues = %InternalShip/Issues
@onready var bars: Array[ColorRect] = []


const HEALTH_COLORS = [
	{ "threshold": 75, "text": "All Systems Operational" },
	{ "threshold": 50, "text": "Degraded Systems" },
	{ "threshold": 25, "text": "Partial Outage" },
	{ "threshold": 0, "text": "Major Outage" }
]

const BARS_COLORS = [
	{ "bars_count": 3, "color": Color("216a7a")},
	{ "bars_count": 4, "color": Color("399cb3")},
	{ "bars_count": 4, "color": Color("72bcf2")},
]

func _ready():
	if game_manager != null:
		game_manager.score_changed.connect(on_score_change)
	if ship != null:
		ship.on_health_change.connect(_on_health_change)

	var current_bars_count: int = 0
	var current_colors_index: int = 0
	var current_color: Color = BARS_COLORS[0].color

	for bar in health_bar_color_rects_container.get_children():
		bar.color = current_color
		current_bars_count += 1
		if current_bars_count > BARS_COLORS[current_colors_index].bars_count:
			current_bars_count = 0
			current_colors_index += 1
			current_color = BARS_COLORS[current_colors_index].color

func _on_health_change(_old_health: float, new_health: float) -> void:
	var color_rects = health_bar_color_rects_container.get_children()
	health_label.text = str(int(new_health))
	var percent_per_bar: float = 100.0 / health_bar_color_rects_container.get_child_count()

	for i in range(color_rects.size()):
		if new_health < percent_per_bar * (i + 1):
			color_rects[color_rects.size() - i - 1].visible = false
		else:
			color_rects[color_rects.size() - i - 1].visible = true


func on_score_change(_old_screen: int, new_score: int):
	pass
