extends Node2D

@onready var http: HTTPRequest = $HTTPRequest
@onready var leaderboard: LeaderboardUI = $Camera2D/Leaderboard
var base_url: String = "http://localhost:3000"
@export var leaderboard_count = 20
var LEADERBOARD_ENTRIES_URL: String = base_url+"/leaderboard?count_player="+str(leaderboard_count)

func _ready() -> void:
	http.request_completed.connect(_on_request_complete)
	http.set_tls_options(TLSOptions.client_unsafe())
	http.request(LEADERBOARD_ENTRIES_URL)

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
	http.set_tls_options(TLSOptions.client_unsafe())
	http.request(LEADERBOARD_ENTRIES_URL)


func _on_click_social_media_skip() -> void:
	pass # Replace with function body.
