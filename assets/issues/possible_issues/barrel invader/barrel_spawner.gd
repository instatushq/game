class_name BarrelSpawner extends Node2D

@export var camera: Camera2D = null
@export var spawn_map: FastNoiseLite = null

func _ready() -> void:
	spawn_map = FastNoiseLite.new()
	spawn_map.seed = randi()
	spawn_map.noise_type = FastNoiseLite.TYPE_CELLULAR
