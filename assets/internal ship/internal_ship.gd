extends Node2D

class_name InternalShip

@onready var ship_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var ship_right_part: AnimatedSprite2D = $AnimatedSprite2D/RightPC
@onready var ship_left_part: AnimatedSprite2D = $AnimatedSprite2D/LeftPC
@onready var issues: Issues = $Issues
@onready var ship_health: ShipHealth = %InternalShip/Health
@onready var animator: AnimationPlayer = $Animations
@onready var game_manager: GameManager = %GameManager
@onready var screens_light: PointLight2D = $AnimatedSprite2D/Lights/Screens
@onready var alarm_sound: AudioStreamPlayer2D = $Alarm
@onready var engine_run: AudioStreamPlayer2D = $EngineRun
@onready var engine_running: AudioStreamPlayer2D = $EngineRunning
@onready var engine_fail: AudioStreamPlayer2D = $EngineFail
@export var default_lights_texutres: Texture2D
@export var broken_lights_texture: Texture2D
var has_played_broken_animation: bool = false
var is_playing_revive_animation: bool = false
var ship_broke_during_revival: bool = false
@export var ship_major_outage_health_amount: int = 50
var queue_ship_status_change: bool = false
var queued_ship_status_change_toggled: bool = false

@onready var alarm_sound_volume: float = alarm_sound.volume_db
@onready var engine_run_volume: float = engine_run.volume_db
@onready var engine_running_volume: float = engine_running.volume_db
@onready var engine_fail_volume: float = engine_fail.volume_db

signal on_ship_breakdown
signal on_ship_broken
signal on_ship_revived
signal on_ship_reviving

func _ready() -> void:
	engine_run.finished.connect(func(): engine_running.play(0.1))
	_do_engine_sound_transition(true)
	issues.on_issue_resolved.connect(_on_issue_resolved)
	if game_manager != null:
		game_manager.on_solving_puzzle_changed.connect(func(solving: bool) -> void:
			visible = not solving
			_toggle_ship_parts_sound(not solving)
		)
	ship_right_part.visible = false
	ship_left_part.visible = false
	ship_sprite.frame_changed.connect(_on_ship_frame_change)
	if ship_health != null:
		ship_health.on_health_change.connect(_on_health_change)

func _on_ship_frame_change() -> void:
	ship_right_part.frame = ship_sprite.frame
	ship_left_part.frame = ship_sprite.frame
	

func _on_issue_resolved(zone: IssueArea2D, issue_instance: Issue) -> void:
	ship_health.increase_health(randi_range(issue_instance.min_hp_revive, issue_instance.max_hp_revive))
	if ship_health.health > ship_major_outage_health_amount:
		if zone.name.containsn("right"):
			ship_right_part.visible = false
		elif zone.name.containsn("left"):
			ship_left_part.visible = false
	else:
		ship_right_part.visible = false
		ship_left_part.visible = false

func _on_issue_failed(zone: IssueArea2D) -> void:
	ship_health.decrease_health(3)
	if ship_health.health > ship_major_outage_health_amount:
		if zone.name.containsn("right"):
			ship_right_part.visible = false
		elif zone.name.containsn("left"):
			ship_left_part.visible = false
	else:
		ship_right_part.visible = false
		ship_left_part.visible = false
		
func _on_animation_finish() -> void:
	if ship_sprite.animation == "breakdown":
		if is_playing_revive_animation:
			if ship_broke_during_revival:
				_toggle_major_outage(true)
				ship_broke_during_revival = false
			else:
				ship_sprite.play("default")
				screens_light.texture = default_lights_texutres
				on_ship_revived.emit()
				if ship_health.health > ship_major_outage_health_amount:
					if issues.does_zone_have_issues(Issues.ISSUE_DIRECTION.RIGHT):
						ship_right_part.visible = true
					if issues.does_zone_have_issues(Issues.ISSUE_DIRECTION.LEFT):
						ship_left_part.visible = true
				else:
					ship_right_part.visible = false
					ship_left_part.visible = false
					
			is_playing_revive_animation = false
			has_played_broken_animation = false
		else:
			ship_right_part.visible = false
			ship_left_part.visible = false
			ship_sprite.play("broken")
			screens_light.texture = broken_lights_texture
			on_ship_broken.emit()

func _on_game_manager_solving_puzzle_changed(is_solving_puzzle: bool) -> void:
	if queue_ship_status_change and not is_solving_puzzle:
		_toggle_major_outage(queued_ship_status_change_toggled)
		queue_ship_status_change = false

func _on_issues_on_clear_issues(_zone: IssueArea2D, issues_left: bool) -> void:
	if not issues_left:
		if ship_health.health < ship_major_outage_health_amount and not has_played_broken_animation:
			_toggle_major_outage(false)
	else:
		if issues.does_zone_have_issues(Issues.ISSUE_DIRECTION.RIGHT):
			ship_right_part.visible = true
		if issues.does_zone_have_issues(Issues.ISSUE_DIRECTION.LEFT):
			ship_left_part.visible = true

func _on_animator_animation_finish(anim_name: StringName) -> void:
	if anim_name == "breakdown":
		animator.play("broken")
		if not is_playing_revive_animation:
			on_ship_broken.emit()

func _on_issues_on_issue_generated(_zone: IssueArea2D, _issues_count: int) -> void:	
	if not has_played_broken_animation:
		if _zone.name.containsn("right"):
			ship_right_part.visible = true
		elif _zone.name.containsn("left"):
			ship_left_part.visible = true

func _on_health_change(_old_health: int, new_health: int) -> void:
	if is_playing_revive_animation and new_health < ship_major_outage_health_amount:
		ship_broke_during_revival = true
		return

	if new_health < ship_major_outage_health_amount and not has_played_broken_animation:
		has_played_broken_animation = true
		if game_manager.is_solving_puzzle:
			queue_ship_status_change = true
			queued_ship_status_change_toggled = true
		else:
			_toggle_major_outage(true)
	
	if new_health > ship_major_outage_health_amount and has_played_broken_animation:
		if game_manager.is_solving_puzzle:
			queue_ship_status_change = true
			queued_ship_status_change_toggled = false
		else:
			_toggle_major_outage(false)

func _toggle_major_outage(toggled: bool) -> void:
	if toggled:
		has_played_broken_animation = true
		ship_sprite.play("breakdown")
		animator.play("breakdown")
		ship_right_part.visible = false
		ship_right_part.visible = false
		on_ship_breakdown.emit()
		_do_engine_sound_transition(false)
	else:
		is_playing_revive_animation = true
		ship_sprite.play_backwards("breakdown")
		animator.play("revive")
		on_ship_reviving.emit()
		ship_right_part.visible = issues.does_zone_have_issues(Issues.ISSUE_DIRECTION.RIGHT)
		ship_left_part.visible = issues.does_zone_have_issues(Issues.ISSUE_DIRECTION.LEFT)
		_do_engine_sound_transition(true)

func _do_engine_sound_transition(engine_state: bool) -> void:
	if engine_state:
		engine_run.play()
		alarm_sound.stop()
	else:
		engine_running.stop()
		engine_fail.play(0.1)
		alarm_sound.play()

func _toggle_ship_parts_sound(toggled: bool) -> void:
	if toggled:
		engine_run.volume_db = engine_run_volume
		alarm_sound.volume_db = alarm_sound_volume
		engine_running.volume_db = engine_running_volume
		engine_fail.volume_db = engine_fail_volume
	else:
		engine_run.volume_db = 0
		alarm_sound.volume_db = 0
		engine_running.volume_db = 0
		engine_fail.volume_db = 0