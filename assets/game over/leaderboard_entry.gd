class_name LeaderboardEntry extends HBoxContainer

@onready var rank_label: Label = $Rank
@onready var name_label: Label = $Name
@onready var score_label: Label = $Score

func set_entry_data(rank: String, entry_name: String, score: int) -> void:
	rank_label.text = rank
	name_label.text = entry_name
	score_label.text = str(score)
	
