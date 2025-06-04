class_name IssueIcon extends Node2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

enum ICON_TYPE {
	INTERACTABLE,
	EXCLAMATION_MARK
}

func set_icon(icon_name: ICON_TYPE) -> void:
	match icon_name:
		ICON_TYPE.INTERACTABLE:
			animated_sprite.play("interact")
		ICON_TYPE.EXCLAMATION_MARK:
			animated_sprite.play("exclaim")
