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
@export var default_lights_texutres: Texture2D
@export var broken_lights_texture: Texture2D
var has_played_broken_animation: bool = false
var is_playing_revive_animation: bool = false
var issue_generated_during_revival: bool = false

signal on_ship_broken
signal on_ship_revived

func _ready() -> void:
	issues.on_clear_issues.connect(_on_issue_resolved)
	ship_right_part.visible = false
	ship_left_part.visible = false

func _on_issue_resolved(zone: Area2D, _issues_left: bool) -> void:
	ship_health.increase_health(randi_range(2, 5))
	if ship_health.health > 50:
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
			if issue_generated_during_revival:
				ship_sprite.play("breakdown")
				animator.play("breakdown")
				ship_right_part.visible = false
				ship_right_part.visible = false
				issue_generated_during_revival = false
			else:
				ship_sprite.play("default")
				screens_light.texture = default_lights_texutres
				on_ship_revived.emit()
				if ship_health.health > 50:
					ship_right_part.visible = true
					ship_left_part.visible = true
				else:
					if issues.does_zone_have_issues(Issues.ISSUE_DIRECTION.RIGHT):
						ship_right_part.visible = true
					if issues.does_zone_have_issues(Issues.ISSUE_DIRECTION.LEFT):
						ship_left_part.visible = true
					
			is_playing_revive_animation = false
			has_played_broken_animation = false
		else:
			ship_right_part.visible = false
			ship_left_part.visible = false
			ship_sprite.play("broken")
			screens_light.texture = broken_lights_texture
			on_ship_broken.emit()

func _on_game_manager_solving_puzzle_changed(is_solving_puzzle: bool) -> void:
	if ship_health.health > 50: return
	if not is_solving_puzzle: return
	if has_played_broken_animation: return
	if not issues.has_any_issues(): return
	has_played_broken_animation = true
	ship_sprite.play("breakdown")
	animator.play("breakdown")
	ship_right_part.visible = false
	ship_right_part.visible = false

func _on_issues_on_clear_issues(issues_left: bool) -> void:
	if not issues_left:
		is_playing_revive_animation = true
		ship_sprite.play_backwards("breakdown")
		animator.play("revive")
	else:
		ship_right_part.visible = false
		ship_left_part.visible = false

func _on_animator_animation_finish(anim_name: StringName) -> void:
	if anim_name == "breakdown":
		animator.play("broken")
		if not is_playing_revive_animation:
			on_ship_broken.emit()

func _on_issues_on_issue_generated(_zone: Area2D, issues_count: int) -> void:
	if is_playing_revive_animation:
		issue_generated_during_revival = true
		return
		
	if issues_count == 1 and not has_played_broken_animation and ship_health.health <= 50:
		has_played_broken_animation = true
		ship_sprite.play("breakdown")
		animator.play("breakdown")
		ship_right_part.visible = false
		ship_left_part.visible = false
	
	if _zone.name.containsn("right"):
		ship_right_part.visible = true
	elif _zone.name.containsn("left"):
		ship_left_part.visible = true
