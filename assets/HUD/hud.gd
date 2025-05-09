extends CanvasLayer

@onready var score_label: Label = $Score
@onready var health_label: Label = $Health
@onready var game_manager: GameManager = %GameManager
@onready var ship: ShipHealth = %Ship/Health
@onready var issues: Issues = %InternalShip/Issues

const HEALTH_COLORS = [
	{ "threshold": 75, "color": Color("#00FF00"), "text": "Operational" },
	{ "threshold": 50, "color": Color("#FFFF00"), "text": "Degraded" },
	{ "threshold": 25, "color": Color("#FF8000"), "text": "Partial Outage" },
	{ "threshold": 0,  "color": Color("#FF0000"), "text": "Major Outage" }
]

func _ready():
	game_manager.score_changed.connect(on_score_change)
	ship.on_health_change.connect(on_health_change)
	_update_health_text(100)
	
func on_score_change(_old_screen: int, new_score: int):
	score_label.text = str(new_score) + " XP"

func _update_health_text(new_health):
	for entry in HEALTH_COLORS:
		if new_health > entry.threshold:
			health_label.label_settings.font_color = entry.color
			health_label.text = str(int(new_health)) + " %\n" + entry.text
			return
	health_label.label_settings.font_color = HEALTH_COLORS[-1].color
	health_label.text = str(int(new_health)) + " %\n" + HEALTH_COLORS[-1].text


func on_health_change(_old_health: float, new_health: float) -> void:
	_update_health_text(new_health)
