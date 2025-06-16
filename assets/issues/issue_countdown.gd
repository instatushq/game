class_name IssueCountdown extends CanvasLayer

signal issue_countdown_finished

@onready var countdown: Label = $CountdownContainer/Countdown
@onready var timer: Timer = $Timer

func _ready():
	countdown.visible = false
	timer.timeout.connect(_on_timer_timeout)

func start_game_countdown(time_sec: float) -> void:
	countdown.visible = true
	timer.start(time_sec)

func _on_timer_timeout() -> void:
	issue_countdown_finished.emit()

func _physics_process(_delta: float) -> void:
	if timer.paused or timer.is_stopped(): return
	var time_left = timer.time_left
	var minutes = floor(time_left / 60)
	var seconds = int(time_left) % 60
	countdown.text = "%02d:%02d" % [minutes, seconds]
