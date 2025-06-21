extends Node2D

@onready var units_container: Control = $CanvasLayer/UnitsContainer
@onready var controls: Array[Control] = []
var current_control_index: int = -1

func _ready() -> void:
	for unit in units_container.get_children():
		if unit is Control:
			controls.append(unit)
			unit.modulate.a = 0.0
	
	start_intro_sequence()

func _input(event: InputEvent) -> void:
	if event is InputEventKey or event is InputEventMouseButton or event is InputEventJoypadButton:
		if event.pressed:
			skip_intro()

func skip_intro() -> void:
	get_tree().change_scene_to_file("res://assets/main menu/main menu.tscn")

func start_intro_sequence() -> void:
	for control in controls:
		control.modulate.a = 0.0
	
	await get_tree().create_timer(1.0).timeout
	show_current_unit()

func show_current_unit() -> void:
	controls[current_control_index].modulate.a = 1.0
	await get_tree().create_timer(2.0).timeout
	controls[current_control_index].modulate.a = 0.0
	await get_tree().create_timer(1.0).timeout
	fade_in_current_control()

func fade_in_current_control() -> void:
	get_tree().change_scene_to_file("res://assets/main menu/main menu.tscn")
