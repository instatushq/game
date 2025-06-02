extends CanvasLayer

signal score_cycle_completed

@export var score_for_complete_bar: int = 500
@export var xp_score_color_flash: Color = Color.WHITE
@onready var score_xp_bar: ColorRect = $HUDUI/XP/BarContainer/Bar
@onready var health_label: Label = $HUDUI/Health/HealthContainer/HealthLabel
@onready var health_bar_color_rects_container: VBoxContainer = $HUDUI/Bars
@onready var health_arrows: Label = $HUDUI/Health/Arrows
@onready var systems_label: Label = $HUDUI/Systems
@onready var systems_label_font_size: int = systems_label.label_settings.font_size
@onready var score_label: Label = $HUDUI/XP/Score
@onready var score_label_original_color: Color = score_label.label_settings.font_color
@onready var game_manager: GameManager = %GameManager
@onready var ship: ShipHealth = %InternalShip/Health
@onready var issues: Issues = %InternalShip/Issues
@onready var bars: Array[ColorRect] = []
@onready var dialog_box: DialogBox = $HUDUI/DialogBox
@onready var time_label: Label = $HUDUI/DialogBox/Clock

var _freeze_score_to_nearest_cycle = false

enum COMPUTER_EMOTION {
	DEFAULT
}

const SYSTEMS_TITLES = [
	{ "threshold": 75, "text": "All Systems\nOperational", "font_size_adjustment": 0 },
	{ "threshold": 50, "text": "All Systems\nDegraded", "font_size_adjustment": 0 },
	{ "threshold": 25, "text": "Systems\nPartially Outaged", "font_size_adjustment": -4 },
	{ "threshold": 0, "text": "Systems\nMajorly Outaged", "font_size_adjustment": -4 }
]

const BARS_COLORS = [
	{ "bars_count": 3, "color": Color("216a7a")},
	{ "bars_count": 4, "color": Color("399cb3")},
	{ "bars_count": 4, "color": Color("72bcf2")},
]

func _physics_process(_delta: float) -> void:
	var time_dict = Time.get_datetime_dict_from_system()
	var hour = time_dict.hour % 12
	if hour == 0:
		hour = 12
	time_label.text = str(hour) + ":" + str(time_dict.minute).pad_zeros(2) + " " + ("AM" if time_dict.hour < 12 else "PM")

func _ready():
	_update_systems_titles(100.0)
	score_cycle_completed.connect(_on_score_cycle_complete)
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

func _on_health_change(old_health: float, new_health: float) -> void:
	_update_systems_titles(new_health)
	if old_health != new_health:
		health_arrows.rotation_degrees = 180 if new_health > old_health else 90
	
	var color_rects = health_bar_color_rects_container.get_children()
	health_label.text = str(int(new_health))
	var percent_per_bar: float = 100.0 / health_bar_color_rects_container.get_child_count()

	for i in range(color_rects.size()):
		if new_health < percent_per_bar * (i + 1):
			color_rects[color_rects.size() - i - 1].visible = false
		else:
			color_rects[color_rects.size() - i - 1].visible = true

func _update_systems_titles(new_health: float) -> void:
	for title in SYSTEMS_TITLES:
		if new_health > title.threshold:
			systems_label.text = title.text
			systems_label.label_settings.font_size = systems_label_font_size + title.font_size_adjustment
			break

func _portray_emotion(_emotion: COMPUTER_EMOTION, dialog: String) -> void:
	dialog_box.speak_words(dialog, "E N.Stat", 0.5, 1)

func on_score_change(old_score: int, new_score: int):
	if not _freeze_score_to_nearest_cycle:
		score_label.text = str(new_score)
	else:
		var nearest_cycle = round(float(new_score) / float(score_for_complete_bar)) * score_for_complete_bar
		score_label.text = str(int(nearest_cycle))

	var remainder = fmod(new_score, score_for_complete_bar)
	var completion_percentage = remainder / score_for_complete_bar
	score_xp_bar.scale.x = completion_percentage
	
	if remainder < old_score % score_for_complete_bar:
		score_cycle_completed.emit()

func _on_score_cycle_complete() -> void:
	_freeze_score_to_nearest_cycle = true
	dialog_box.speak_words("Conputer Is Here. \n I Am Conputer. But I am Good Conputer.", "E N.Stat", 0.1, 1)

	for i in range(3):
		score_label.label_settings.font_color = xp_score_color_flash
		await get_tree().create_timer(0.2).timeout
		score_label.label_settings.font_color = score_label_original_color
		await get_tree().create_timer(0.2).timeout

	_freeze_score_to_nearest_cycle = false
