extends CanvasLayer

@onready var meteor_countdown: Label = $MeteorCountdown/Countdown
@onready var meteor_timer: Timer = $Timer
@onready var parent_issue: BarrelInvader = get_parent()

signal meteor_herd_value_changed(time_left: float)

func _ready():
	parent_issue.game_started.connect(_on_game_started)
	meteor_countdown.visible = false
	meteor_timer.timeout.connect(_on_timer_timeout)
	meteor_herd_value_changed.connect(_on_meteor_event_value_changed)

func _on_game_started() -> void:
	meteor_countdown.visible = true
	meteor_timer.start()

func _on_meteor_event_value_changed(time_left: float) -> void:
	var minutes = floor(time_left / 60)
	var seconds = int(time_left) % 60
	meteor_countdown.text = "%02d:%02d" % [minutes, seconds]

func _physics_process(_delta: float) -> void:
	if not parent_issue.is_playing: return
	meteor_herd_value_changed.emit(meteor_timer.time_left)

func _on_timer_timeout() -> void:
	var issue_issue: Issue = parent_issue.get_parent()
	issue_issue.issue_resolved.emit()
