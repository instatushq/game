extends Node2D

class_name InternalShip

@onready var ship_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var issues: Issues = $Issues
@onready var animator: AnimationPlayer = $Animations
@onready var game_manager: GameManager = %GameManager
var has_played_broken_animation: bool = false
var is_playing_revive_animation: bool = false

func _on_animation_finish() -> void:
	if ship_sprite.animation == "breakdown":
		ship_sprite.play("default" if is_playing_revive_animation else "broken")
		if is_playing_revive_animation:
			is_playing_revive_animation = false
			has_played_broken_animation = false

func _on_game_manager_current_player_changed(new_current_player: GameManager.Player) -> void:
	if new_current_player == GameManager.Player.SHIP: return
	if has_played_broken_animation: return
	if not issues.has_any_issues(): return
	has_played_broken_animation = true
	ship_sprite.play("breakdown")
	animator.play("breakdown")

func _on_issues_on_clear_issues(issues_left: bool) -> void:
	if not issues_left:
		is_playing_revive_animation = true
		ship_sprite.play_backwards("breakdown")
		animator.play("revive")

func _on_animator_animation_finish(anim_name: StringName) -> void:
	if anim_name == "breakdown":
		animator.play("broken")

func _on_issues_on_issue_generated(_zone: Area2D, issues_count: int) -> void:
	if issues_count == 1 and not has_played_broken_animation and game_manager.current_player == GameManager.Player.ASTRONAUT:
		has_played_broken_animation = true
		ship_sprite.play("breakdown")
		animator.play("breakdown")
