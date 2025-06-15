class_name LeaderboardUI extends Control

signal on_added_new_score

@onready var entries_container = $VBoxContainer/VScrollBar/VBoxContainer

@onready var submit_score_request: HTTPRequest = $VBoxContainer/Form/SubmitScore
@onready var query_rank_request: HTTPRequest = $VBoxContainer/Form/QueryRank
@onready var score_rank: Label = $VBoxContainer/Form/CenterContainer/HBoxContainer/Rank
@onready var name_edit: LineEdit = $VBoxContainer/Form/CenterContainer/HBoxContainer/NameEdit
@onready var new_score_label: Label = $VBoxContainer/Form/CenterContainer/HBoxContainer/Score
@onready var save_button: Button = $VBoxContainer/Form/HBoxContainer/SaveScore
@onready var social_media_container: ColorRect = $SocialMediaContainer
@onready var current_player_score = Stats.current_score
@onready var music: AudioStreamPlayer = Music
@onready var music_volume: float = music.volume_db
@onready var error_label: Label = $SocialMediaContainer/Form2/Error
@onready var social_media_url_input: LineEdit = $SocialMediaContainer/Form2/Control/NameEdit
@onready var skip_button: Button = $SocialMediaContainer/Form2/HBoxContainer/Skip
@onready var save_button_form_2: Button = $SocialMediaContainer/Form2/HBoxContainer/Save
@export var screen_transition: TransitionScreen
@export var entry_scene: PackedScene = null
var is_form_enabled: bool = true

var entries_data: Array = []
var ui_entries: Array[LeaderboardEntry] = []
var base_url: String = "https://api.game.instatus.com"

@export var displayed_entries_count: int = 20

signal on_entries_data_updated

func _ready() -> void:
	social_media_container.visible = false
	for i in displayed_entries_count:
		var entry: LeaderboardEntry = entry_scene.instantiate()
		entries_container.add_child(entry)
		ui_entries.append(entry)
		entry.set_entry_data("N/A", "N/A", 0, i + 1, "")
	
	new_score_label.text = str(current_player_score)
	
	on_entries_data_updated.connect(_on_entries_data_updated)
	query_rank_request.request_completed.connect(_on_query_rank_request_completed)
	submit_score_request.request_completed.connect(_on_submit_score_request_completed)
	query_rank_request.set_tls_options(TLSOptions.client_unsafe())
	submit_score_request.set_tls_options(TLSOptions.client_unsafe())
	query_rank_request.request(base_url+"/leaderboard/rank/" + str(current_player_score))
	
	name_edit.grab_focus()

func set_entries_data(entries: Array) -> void:
	entries_data = entries
	on_entries_data_updated.emit()

func _update_entries_values() -> void:
	for i in entries_data.size():
		var ordinal_suffix = " " + Rank.get_ordinal_suffix(i + 1)
		ui_entries[i].set_entry_data(str(i + 1) + ordinal_suffix, entries_data[i].name, entries_data[i].score, i + 1, entries_data[i].socialMediaUrl)

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

	var tween = create_tween()
	tween.tween_property(music, "volume_db", -80.0, 0.4)  # Fade to silence over 0.5 seconds
	await tween.finished
	music.stop()
	music.volume_db = music_volume


func _on_save_score_pressed() -> void:
	social_media_container.visible = true
	toggle_form(false)

func _on_name_edit_text_submitted(_new_text: String) -> void:
	social_media_container.visible = true
	toggle_form(false)

func save_score(score: int, player_name: String, social_media_url: String) -> void:
	if player_name.strip_edges().is_empty():
		return
		
	var headers = ["Content-Type: application/json"]
	var payload = JSON.stringify({"score": score, "name": player_name, "socialMediaUrl": social_media_url})

	submit_score_request.request(
		base_url+"/leaderboard",
		headers,
		HTTPClient.METHOD_POST,
		payload
	)
	
func _on_submit_score_request_completed(_result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if _response_code != 200:
		error_label.text = body.get_string_from_utf8()
		skip_button.disabled = false
		save_button_form_2.disabled = false
		social_media_url_input.editable = true
		return
	
	var json = JSON.parse_string(body.get_string_from_utf8())
	if json == null:
		error_label.text = body.get_string_from_utf8()
		toggle_form(true)
		return
	
	social_media_container.visible = false
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

func _on_click_social_media_save() -> void:
	skip_button.disabled = true
	save_button_form_2.disabled = true
	social_media_url_input.editable = false
	var social_media_url_text = social_media_url_input.text
	save_score(current_player_score, name_edit.text, social_media_url_text)

func _on_click_social_media_skip() -> void:
	skip_button.disabled = true
	save_button_form_2.disabled = true
	social_media_url_input.editable = false
	save_score(current_player_score, name_edit.text, "")
