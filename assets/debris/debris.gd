extends Node2D

func _on_ship_impacter_on_shot(laser_bullet: Node2D) -> void:
	queue_free()
	laser_bullet.queue_free()
