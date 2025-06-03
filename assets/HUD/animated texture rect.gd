class_name AnimatedTextureRect extends TextureRect

signal on_animation_ending(animation_name: String)

@export var sprites: SpriteFrames
@export var autoplay: bool = true

var _current_animation: String
var _current_frame: int = 0
var _time_passed: float = 0.0
var _is_playing: bool = false
var _is_looping: bool = false

func _ready() -> void:
	if sprites == null:
		push_error("SpriteFrames resource is not set!")
		return
		
	if autoplay and sprites.get_animation_names().size() > 0:
		# Get the first animation name as default
		play(sprites.get_animation_names()[0])

func _process(delta: float) -> void:
	if not _is_playing or sprites == null:
		return
		
	_time_passed += delta
	var frame_time: float = 1.0 / sprites.get_animation_speed(_current_animation)
	
	if _time_passed >= frame_time:
		_time_passed = 0.0
		_advance_frame()

func play(animation_name: String) -> void:
	if sprites == null or not sprites.has_animation(animation_name):
		push_error("Animation '%s' not found in SpriteFrames!" % animation_name)
		return
		
	_current_animation = animation_name
	_current_frame = 0
	_is_playing = true
	_is_looping = false
	_update_texture()

func stop() -> void:
	_is_playing = false

func pause() -> void:
	_is_playing = false

func resume() -> void:
	_is_playing = true

func _advance_frame() -> void:
	var frame_count: int = sprites.get_frame_count(_current_animation)
	_current_frame += 1
	
	if _current_frame >= frame_count:
		if _is_looping or sprites.get_animation_loop(_current_animation):
			_current_frame = 0
		else:
			_current_frame = frame_count - 1
			_is_playing = false
			on_animation_ending.emit(_current_animation)
			
	_update_texture()

func _update_texture() -> void:
	if sprites == null or not sprites.has_animation(_current_animation):
		return
		
	texture = sprites.get_frame_texture(_current_animation, _current_frame)
