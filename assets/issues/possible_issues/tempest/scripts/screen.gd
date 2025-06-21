class_name Screen extends TextureRect

signal screen_finished

@export var countdown_duration: int = 3 ## In seconds.

@onready var label_title: Label = $LabelTitle
@onready var label_subtitle: Label = $LabelSubtitle
@onready var timer_second: Timer = $TimerSecond ## Timer that timeouts every 1 second.

var screen_mode: int = -1 # 0 = game_start, 1 = game_win, 2 = game_lose
var seconds_passed: int = 0

func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	hide()

func _process(_delta: float) -> void:
	# Check if game is paused
	var parent_game = get_parent().get_parent()
	if parent_game and parent_game.has_method("_is_game_paused") and parent_game._is_game_paused:
		return
	
	if screen_mode == 0:
		label_subtitle.text = str(countdown_duration - seconds_passed)

func game_start() -> void:
	screen_mode = 0
	label_title.text = "Game starting!"
	label_subtitle.text = ""
	seconds_passed = 0
	timer_second.start()
	show()
	$Sfx/Countdown.pitch_scale = 1.0
	$Sfx/Countdown.play()

func game_win() -> void:
	screen_mode = 1
	label_title.text = "You win!"
	label_subtitle.text = ""
	seconds_passed = 0
	timer_second.start()
	show()

func game_lose() -> void:
	screen_mode = 2
	label_title.text = "You lose!"
	label_subtitle.text = ""
	seconds_passed = 0
	timer_second.start()
	show()

func _on_timer_second_timeout() -> void:
	seconds_passed += 1
	match screen_mode:
		0: # Game start.
			if seconds_passed >= countdown_duration:
				timer_second.stop()
				$Sfx/Countdown.pitch_scale = 1.5
				$Sfx/Countdown.play()
				screen_mode = -1
				hide()
				screen_finished.emit()
			else:
				$Sfx/Countdown.pitch_scale = 1.0
				$Sfx/Countdown.play()
		1: # Game win.
			if seconds_passed >= 3:
				timer_second.stop()
				screen_mode = -1
				hide()
				screen_finished.emit()
		2: # Game lose.
			if seconds_passed >= 3:
				timer_second.stop()
				screen_mode = -1
				hide()
				screen_finished.emit()
