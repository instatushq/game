class_name LeaderboardEntry extends HBoxContainer

@onready var rank_label: Label = $Rank
@onready var name_label: Label = $Name
@onready var score_label: Label = $Score
@onready var link_container: Control = $URL
@onready var link: LinkButton = $URL/LinkButton
@onready var link_name: Label = $URL/LinkButton/LinkName
@onready var link_underline: ColorRect = $URL/LinkButton/LinkName/Underline

var rank_colors = [
	Color("#7EDCE7"),
	Color("#27ACAF"),  
	Color("#367CB8"),
	Color("#FFFFFF")
]

func _ready() -> void:
	link_underline.visible = false

	link.mouse_entered.connect(func():
		link_underline.visible = true
	)
	link.mouse_exited.connect(func():
		link_underline.visible = false
	)
	link.focus_entered.connect(func():
		link_underline.visible = true
	)
	link.focus_exited.connect(func():
		link_underline.visible = false
	)

func set_entry_data(rank: String, entry_name: String, score: int, numerical_rank: int, name_link: String) -> void:
	rank_label.text = rank
	name_label.text = entry_name
	link_name.text = "@"+entry_name
	score_label.text = str(score)
	link_underline.scale.x = (entry_name.length() + 1) * link_underline.scale.x
	
	if name_link != "":
		name_label.visible = false
		link_container.visible = true
		link.uri = name_link

		var font = link_name.get_theme_font("font")
		var font_size = link_name.get_theme_font_size("font_size")
		var text_width = font.get_string_size("@"+link_name.text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
		link.custom_minimum_size.x = text_width
		link.custom_minimum_size.y = link_name.size.y

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
		link_underline.color = selected_color
		name_label.label_settings = new_name_settings
		link_name.label_settings = new_name_settings
	else:
		var new_name_settings = LabelSettings.new()
		new_name_settings.font_color = selected_color
		link_underline.color = selected_color
		name_label.label_settings = new_name_settings
		link_name.label_settings = new_name_settings
	
	if score_label.label_settings:
		var new_score_settings = score_label.label_settings.duplicate()
		new_score_settings.font_color = selected_color
		score_label.label_settings = new_score_settings
	else:
		var new_score_settings = LabelSettings.new()
		new_score_settings.font_color = selected_color
		score_label.label_settings = new_score_settings
