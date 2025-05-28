extends CanvasLayer

@onready var health_label: Label = $TextureRect/Status
@onready var health_label_percentage: Label = $TextureRect/Health
@onready var health_bar_color_rects_container: Control = $TextureRect/StatusBars
@onready var score_label: Label = $TextureRect/ScoreContainer/Score
@onready var game_manager: GameManager = %GameManager
@onready var ship: ShipHealth = %InternalShip/Health
@onready var issues: Issues = %InternalShip/Issues


const HEALTH_COLORS = [
	{ "threshold": 75, "color": Color("#00f7bc"), "text": "All Systems Operational" },
	{ "threshold": 50, "color": Color("#FFFF00"), "text": "Degraded Systems" },
	{ "threshold": 25, "color": Color("#FF8000"), "text": "Partial Outage" },
	{ "threshold": 0,  "color": Color("#FF0000"), "text": "Major Outage" }
]

func _ready():
	game_manager.score_changed.connect(on_score_change)
	ship.on_health_change.connect(_on_health_change)
	# Initialize all color rects with the default color
	_update_health_text(100)

func _update_color_rects(new_health: float) -> void:
	var color_rects = health_bar_color_rects_container.get_children()	

	for entry in HEALTH_COLORS:
		if new_health > entry.threshold:
			for i in range(color_rects.size()):
				color_rects[i].color = entry.color
			return
	
	for i in range(color_rects.size()):
		color_rects[i].color = HEALTH_COLORS[0].color


func _update_health_text(new_health):
	_update_color_rects(new_health)

	for entry in HEALTH_COLORS:
		if new_health > entry.threshold:
			health_label.label_settings.font_color = entry.color
			health_label.text = entry.text
			health_label_percentage.text = str(int(new_health)) + "%"
			return
			
	health_label.label_settings.font_color = HEALTH_COLORS[-1].color
	health_label.text = HEALTH_COLORS[-1].text
	health_label_percentage.text = str(int(new_health)) + "%"

func _on_health_change(_old_health: float, new_health: float) -> void:
	_update_health_text(new_health)

func on_score_change(_old_screen: int, new_score: int):
	score_label.text = str(new_score)
