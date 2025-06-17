extends Node2D

@onready var parent: Issue = get_parent()
@onready var game: TempestGame = $TempestGame

func _ready() -> void:
	parent.issue_opened.connect(func() -> void: game.start_game())
	game.on_issue_resolved.connect(func() -> void: parent.issue_resolved.emit())
