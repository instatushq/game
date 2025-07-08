class_name MainMenuAmbience extends AudioStreamPlayer

@onready var music_stream: AudioStreamOggVorbis = preload("res://assets/audio/background/ambience.ogg")

var is_playing_track: bool = false

func _ready() -> void:
	stream = music_stream

func set_playing_track(value: bool):
	if value and not is_playing_track:
		play(0.0)
		is_playing_track = true
	elif not value and is_playing_track:
		stop()
		is_playing_track = false
