extends ColorRect

var moles: Array[Node] = []
var score: int = 0
var score_goal: int = 14000
var score_per_mole: int = 1
var is_on_cooldown_for_failing: bool = false
@onready var cooldown_timer: Timer = $cooldown_timer
@onready var XP: Label = $XPCounter/XP
@onready var MaxXP: Label = $XPCounter/MaxXP

func _ready() -> void:
	moles = get_children().filter(func(child): return child is Mole)
	for mole in moles:
		mole.mole_hit.connect(_on_mole_hit)
		mole.mole_missed.connect(_on_mole_missed)

	score_per_mole = randi_range(400, 500)
	MaxXP.text = "/ " + str(score_goal) + " XP"
	XP.text = str(score)
	cooldown_timer.timeout.connect(_on_cooldown_timer_timeout)

func _on_mole_hit(_mole: Mole) -> void:
	if is_on_cooldown_for_failing: return

	score += score_per_mole
	_update_xp_counter()
	if score >= score_goal:
		_resolve_issue()
	
func _on_mole_missed(_mole: Mole) -> void:
	if not is_on_cooldown_for_failing:
		is_on_cooldown_for_failing = true
		cooldown_timer.start(0.6)

func _resolve_issue() -> void:
	var parent: Issue = get_parent()
	parent.issue_resolved.emit()

func _update_xp_counter() -> void:
	XP.text = str(score)

func _on_cooldown_timer_timeout() -> void:
	is_on_cooldown_for_failing = false
