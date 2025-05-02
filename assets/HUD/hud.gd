extends CanvasLayer

@onready var Score: Label = $Score
@onready var game_manager: GameManager = get_node("%GameManager")

func _ready():
	game_manager.score_changed.connect(on_score_change)
	
func on_score_change(_old_screen: int, new_score: int):
	Score.text = str(new_score) + " XP"
