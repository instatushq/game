class_name Mole extends Button

signal mole_hit(mole: Mole)
signal mole_missed(mole: Mole)

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer: Timer = $Timer
@onready var hit_sound: AudioStreamPlayer = $HitSound
@onready var coming_up_sound: AudioStreamPlayer = $ComingUp
@onready var going_down_sound: AudioStreamPlayer = $GoingDown
@export var reset_colors_on_frame: int = 3

var is_player_on_cooldown: bool = false

enum MoleState {DOWN, UP, OUT}
var current_state: MoleState = MoleState.DOWN
var is_active: bool = true

var is_game_started: bool = false

const MIN_TIME_BETWEEN_APPEARANCES = 1.0
const MAX_TIME_BETWEEN_APPEARANCES = 3.0
const MIN_TIME_OUTSIDE = 0.5
const MAX_TIME_OUTSIDE = 1.5

@onready var parent: WhackAMole = get_parent()

func _ready() -> void:
	z_index = 0
	parent.on_game_started.connect(func(): is_game_started = true)
	self_modulate = Color.WHITE
	pressed.connect(_on_pressed)
	timer.timeout.connect(_on_timer_timeout)
	animated_sprite.animation_finished.connect(_on_animation_finished)
	animated_sprite.frame_changed.connect(func(): 
		if animated_sprite.animation == "hit" and animated_sprite.frame == reset_colors_on_frame:
			animated_sprite.self_modulate = Color(1, 1, 1, 1))

	
	animated_sprite.play("down")
	
	_start_random_timer()

func set_active(active: bool) -> void:
	is_active = active
	if not active:
		timer.stop()
		_set_state(MoleState.DOWN)
	elif current_state == MoleState.DOWN:
		_start_random_timer()

func _on_pressed() -> void:
	if not is_active or is_player_on_cooldown:
		return
		
	match current_state:
		MoleState.OUT:
			mouse_filter = Control.MOUSE_FILTER_IGNORE
			mole_hit.emit(self)
			animated_sprite.play("hit")
			animated_sprite.self_modulate = Color.from_rgba8(255, 80, 80)
			current_state = MoleState.DOWN
			_start_random_timer()
			if is_game_started: hit_sound.play()
		_:
			mole_missed.emit(self)

func _on_timer_timeout() -> void:
	if not is_active:
		return
		
	match current_state:
		MoleState.DOWN:
			_set_state(MoleState.UP)
		MoleState.OUT:
			_set_state(MoleState.DOWN)
			_start_random_timer()

func _on_animation_finished() -> void:
	if not is_active:
		return
		
	match animated_sprite.animation:
		"up":
			_set_state(MoleState.OUT)
			timer.start(randf_range(MIN_TIME_OUTSIDE, MAX_TIME_OUTSIDE))
			mouse_filter = Control.MOUSE_FILTER_STOP
		"out":
			if current_state == MoleState.OUT:
				animated_sprite.self_modulate = Color(0, 0, 0, 1)
				_set_state(MoleState.DOWN)
				_start_random_timer()

func _set_state(new_state: MoleState) -> void:
	current_state = new_state
	match current_state:
		MoleState.DOWN:
			animated_sprite.play("down")
			await get_tree().create_timer(0.15).timeout
			if is_game_started: going_down_sound.play()
			mouse_filter = Control.MOUSE_FILTER_IGNORE
		MoleState.UP:
			animated_sprite.play("up")
			if is_game_started: coming_up_sound.play()
		MoleState.OUT:
			animated_sprite.play("out")

func _start_random_timer() -> void:
	if is_active:
		timer.start(randf_range(MIN_TIME_BETWEEN_APPEARANCES, MAX_TIME_BETWEEN_APPEARANCES))

func get_adjacent_node_name() -> String:
	var index: int = int(name)
	return str(index + 4) if index < 4 else str(index - 3)
