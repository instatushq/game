extends Node2D

@onready var http: HTTPRequest = $HTTPRequest
@onready var leaderboard: LeaderboardUI = $Camera2D/Leaderboard

func _ready() -> void:
	http.request_completed.connect(_on_request_complete)
	http.request("http://localhost:3000/leaderboard")

func _on_request_complete(_result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var json = JSON.parse_string(body.get_string_from_utf8())
	if json == null:
		push_error("Failed to parse JSON response")
		return
		
	var entries: Array = []
	for entry_data in json:
		entries.append(entry_data)
	
	leaderboard.set_entries_data(entries)

func _on_leaderboard_on_added_new_score() -> void:
	http.request("http://localhost:3000/leaderboard")
	print("updating leaderboard view")
