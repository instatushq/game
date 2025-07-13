class_name TempestContainer extends Node2D

@onready var parent: Issue = get_parent()
@onready var game: TempestGame = $TempestGame
@onready var difficulty_manager: DifficultyOrganizer = DifficultyManager

func _ready() -> void:
	parent.issue_opened.connect(func() -> void: game.start_game())
	game.on_issue_resolved.connect(func() -> void: parent.issue_resolved.emit())
	game.on_game_lost.connect(func() -> void: issue_failed())
	_adapt_difficulty()
	

func issue_failed() -> void:
	parent.issue_failed.emit()

func segment_completed() -> void:
	parent.on_issue_segment_success()

func segment_failed() -> void:
	parent.on_issue_segment_failed()

func _adapt_difficulty() -> void:
	match difficulty_manager.current_difficulty:
		DifficultyOrganizer.DIFFICULTY.EASY:
			parent.hp_revive_per_issue_segment = 3
			game._set_enemy_spawn_interval(1.5)
		DifficultyOrganizer.DIFFICULTY.MEDIUM:
			parent.hp_revive_per_issue_segment = 2
			game._set_enemy_spawn_interval(1.3)
		DifficultyOrganizer.DIFFICULTY.HARD:
			parent.hp_revive_per_issue_segment = 2
			game._set_enemy_spawn_interval(1.2)
		DifficultyOrganizer.DIFFICULTY.INSANE:
			parent.hp_revive_per_issue_segment = 1
			game._set_enemy_spawn_interval(1)