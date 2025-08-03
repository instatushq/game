extends Node2D

@export var light: PointLight2D
@onready var icon_sprite: AnimatedSprite2D = $GithubIcon

func _ready() -> void:
	light.visible = false

func _on_link_button_focus_entered() -> void:
	_on_hover()

func _on_link_button_focus_exited() -> void:
	_on_unhover()

func _on_link_button_mouse_entered() -> void:
	_on_hover()


func _on_link_button_mouse_exited() -> void:
	_on_unhover()

func _on_hover() -> void:
	icon_sprite.play("hovered")
	light.visible = true

func _on_unhover() -> void:
	icon_sprite.play("default")
	light.visible = false
