extends Node2D

@onready var http: HTTPRequest = $HTTPRequest
@onready var leaderboard: LeaderboardUI = $Camera2D/Leaderboard
var base_url: String = "http://localhost:3000"

func _ready() -> void:
	if OS.has_environment("LEADERBOARD_URL"): base_url = OS.get_environment("LEADERBOARD_URL")
	http.request_completed.connect(_on_request_complete)
	http.set_tls_options(TLSOptions.client_unsafe())
	http.request(base_url+"/leaderboard")

func _on_request_complete(_result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	print(body.get_string_from_utf8())
	var json = JSON.parse_string(body.get_string_from_utf8())
	if json == null:
		push_error("Failed to parse JSON response")
		return
		
	var entries: Array = []
	for entry_data in json:
		entries.append(entry_data)
	
	leaderboard.set_entries_data(entries)

func _on_leaderboard_on_added_new_score() -> void:
	http.set_tls_options(TLSOptions.client_unsafe())
	http.request(base_url+"/leaderboard")
	print("updating leaderboard view")
