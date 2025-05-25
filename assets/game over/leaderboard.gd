class_name LeaderboardUI extends Control

signal on_added_new_score

@onready var entries_container = $VBoxContainer/VBoxContainer

@onready var submit_score_request: HTTPRequest = $VBoxContainer/Form/SubmitScore
@onready var query_rank_request: HTTPRequest = $VBoxContainer/Form/QueryRank
@onready var score_rank: Label = $VBoxContainer/Form/CenterContainer/HBoxContainer/Rank
@onready var name_edit: LineEdit = $VBoxContainer/Form/CenterContainer/HBoxContainer/NameEdit
@onready var new_score_label: Label = $VBoxContainer/Form/CenterContainer/HBoxContainer/Score
@onready var save_button: Button = $VBoxContainer/Form/HBoxContainer/SaveScore
@onready var current_player_score = 10
@export var screen_transition: TransitionScreen
@export var entry_scene: PackedScene = null
var is_form_enabled: bool = true

var entries_data: Array = []
var ui_entries: Array[LeaderboardEntry] = []

signal on_entries_data_updated

func _ready() -> void:
	for i in 10:    
		var entry: LeaderboardEntry = entry_scene.instantiate()
		entries_container.add_child(entry)
		ui_entries.append(entry)
		entry.set_entry_data("N/A", "N/A", 0)
	
	new_score_label.text = str(current_player_score)
	
	on_entries_data_updated.connect(_on_entries_data_updated)
	query_rank_request.request_completed.connect(_on_query_rank_request_completed)
	submit_score_request.request_completed.connect(_on_submit_score_request_completed)
	query_rank_request.request("http://localhost:3000/leaderboard/rank/" + str(current_player_score))
	
	name_edit.grab_focus()

func set_entries_data(entries: Array) -> void:
	entries_data = entries
	on_entries_data_updated.emit()

func _update_entries_values() -> void:
	for i in entries_data.size():
		var ordinal_suffix = " " + Rank.get_ordinal_suffix(i + 1)
		ui_entries[i].set_entry_data(str(i + 1) + ordinal_suffix, entries_data[i].name, entries_data[i].score)

func _on_entries_data_updated() -> void:
	_update_entries_values()

func _on_query_rank_request_completed(_result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var json = JSON.parse_string(body.get_string_from_utf8())
	if json == null:
		push_error("Failed to parse JSON response")
		score_rank.text = "N/A"
		return
	
	score_rank.text = str(int(json.rank)) + " " + Rank.get_ordinal_suffix(int(json.rank))
	save_button.disabled = false



func _on_press_main_menu() -> void:
	screen_transition.transition(func():
		get_tree().change_scene_to_file("res://assets/main menu/main menu.tscn")
	,TransitionScreen.TransitionPoint.MIDDLE)


func _on_save_score_pressed() -> void:
	if is_form_enabled:
		save_score(current_player_score, name_edit.text)


func _on_name_edit_text_submitted(new_text: String) -> void:
	if is_form_enabled:
		save_score(current_player_score, new_text)

func save_score(score: int, player_name: String) -> void:
	if player_name.strip_edges().is_empty():
		return
		
	var headers = ["Content-Type: application/json"]
	var payload = JSON.stringify({"score": score, "name": player_name})

	submit_score_request.request(
		"http://localhost:3000/leaderboard",
		headers,
		HTTPClient.METHOD_POST,
		payload
	)

func _on_submit_score_request_completed(_result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var json = JSON.parse_string(body.get_string_from_utf8())
	if json == null:
		push_error("Failed to parse JSON response")
		toggle_form(true)
		return
	
	toggle_form(false)
	on_added_new_score.emit()


func toggle_form(enabled: bool) -> void:
	is_form_enabled = enabled
	save_button.disabled = not enabled
	save_button.focus_mode = Control.FOCUS_ALL if enabled else Control.FOCUS_NONE
	name_edit.editable = enabled
	name_edit.focus_mode = Control.FOCUS_ALL if enabled else Control.FOCUS_NONE
	name_edit.selecting_enabled = enabled
	name_edit.caret_blink = enabled
	if not enabled:
		name_edit.release_focus()


func _on_name_edit_text_changed(new_text: String) -> void:
	var filtered_text = ""
	for character in new_text:
		if character.is_valid_identifier():
			filtered_text += character
	
	# If the text was modified, update the LineEdit
	if filtered_text != new_text:
		name_edit.text = filtered_text
		name_edit.caret_column = filtered_text.length()
