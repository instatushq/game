extends Node2D

@onready var transitions: TransitionScreen = $"Transition Screen"

func _ready() -> void:
	transitions.on_transition_finish.connect(_switch_to_game)
	pass

func _on_click_start_game() -> void:
	transitions.transition(_switch_to_game, TransitionScreen.TransitionPoint.MIDDLE)

func _on_click_options() -> void:
	pass

func _switch_to_game() -> void:
	get_tree().change_scene_to_file("res://main scene.tscn")


func _on_start_game_pressed() -> void:
	pass # Replace with function body.
