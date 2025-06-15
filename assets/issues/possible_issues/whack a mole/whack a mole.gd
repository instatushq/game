extends Control

var moles: Array[Node] = []
var score: int = 0
var score_goal: int = 14000
var score_per_mole: int = 1
var is_on_cooldown_for_failing: bool = false
@onready var cooldown_timer: Timer = $cooldown_timer
@onready var XP: Label = $XPCounter/XP
@onready var pc_face: AnimatedSprite2D = $AnimatedSprite2D/Face
@onready var pc_face_wink_timer: Timer = $"AnimatedSprite2D/Face/wink timer"

func _ready() -> void:
	moles = get_children().filter(func(child): return child is Mole)
	for mole in moles:
		mole.mole_hit.connect(_on_mole_hit)
		mole.mole_missed.connect(_on_mole_missed)

	score_per_mole = randi_range(400, 600)
	var percentage: int = int((float(score) / score_goal) * 100)
	XP.text = str(percentage)
	cooldown_timer.timeout.connect(_on_cooldown_timer_timeout)
	pc_face.animation_finished.connect(_on_pc_face_animation_finished)
	pc_face_wink_timer.start(randf_range(3, 5))

func _on_mole_hit(_mole: Mole) -> void:
	if is_on_cooldown_for_failing: return

	score += score_per_mole
	_update_xp_counter()
	pc_face.play("hit")
	pc_face_wink_timer.stop()
	if score >= score_goal:
		_resolve_issue()
	
func _on_mole_missed(_mole: Mole) -> void:
	if not is_on_cooldown_for_failing:
		is_on_cooldown_for_failing = true
		cooldown_timer.start(0.6)
		pc_face.play("miss")
		$Miss.play()
		pc_face_wink_timer.stop()
		for mole in moles:
			mole.is_player_on_cooldown = true

func _resolve_issue() -> void:
	var parent: Issue = get_parent().get_parent()
	parent.issue_resolved.emit()

func _update_xp_counter() -> void:
	var percentage: int = int((float(score) / score_goal) * 100)
	XP.text = str(percentage)

func _on_cooldown_timer_timeout() -> void:
	is_on_cooldown_for_failing = false
	for mole in moles:
		mole.is_player_on_cooldown = false

func _on_pc_face_animation_finished() -> void:
	if pc_face.animation == "miss" or pc_face.animation == "hit":
		pc_face.play("default")
		pc_face_wink_timer.start(randf_range(3, 5))
	elif pc_face.animation == "wink":
		pc_face.play("default")


func _on_wink_timer_timeout() -> void:
	pc_face.play("wink")
	pc_face_wink_timer.start(randf_range(10, 15))
