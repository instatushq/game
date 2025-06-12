class_name LeaderboardEntry extends HBoxContainer

@onready var rank_label: Label = $Rank
@onready var name_label: Label = $Name
@onready var score_label: Label = $Score

var rank_colors = [
	Color("#7EDCE7"),
	Color("#27ACAF"),  
	Color("#367CB8"),
	Color("#FFFFFF")
]

func set_entry_data(rank: String, entry_name: String, score: int, numerical_rank: int) -> void:
	rank_label.text = rank
	name_label.text = entry_name
	score_label.text = str(score)
	
	var color_index = min(numerical_rank - 1, rank_colors.size() - 1)
	var selected_color = rank_colors[color_index]
	
	if rank_label.label_settings:
		var new_rank_settings = rank_label.label_settings.duplicate()
		new_rank_settings.font_color = selected_color
		rank_label.label_settings = new_rank_settings
	else:
		var new_rank_settings = LabelSettings.new()
		new_rank_settings.font_color = selected_color
		rank_label.label_settings = new_rank_settings
	
	if name_label.label_settings:
		var new_name_settings = name_label.label_settings.duplicate()
		new_name_settings.font_color = selected_color
		name_label.label_settings = new_name_settings
	else:
		var new_name_settings = LabelSettings.new()
		new_name_settings.font_color = selected_color
		name_label.label_settings = new_name_settings
	
	if score_label.label_settings:
		var new_score_settings = score_label.label_settings.duplicate()
		new_score_settings.font_color = selected_color
		score_label.label_settings = new_score_settings
	else:
		var new_score_settings = LabelSettings.new()
		new_score_settings.font_color = selected_color
		score_label.label_settings = new_score_settings
