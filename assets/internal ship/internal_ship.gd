extends Node2D

@onready var ship_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var issues: Issues = $Issues
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


func _on_issues_on_clear_issues(issues_left: bool) -> void:
	if not issues_left:
		is_playing_revive_animation = true
		ship_sprite.play_backwards("breakdown")
