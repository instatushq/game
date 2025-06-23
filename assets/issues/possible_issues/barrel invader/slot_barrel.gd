extends Node2D

@onready var barrel_body: BarrelBody = get_parent()

@export var barrel_sprite: AnimatedSprite2D = null
@export_range(0.5, 4) var picking_time: float = 1.0
@export_range(0.5, 4) var waiting_time: float = 1.0

@export var normal_included: bool = true
@export var tnt_included: bool = true
@export var nuke_included: bool = true

var picking_array: Array[bool] = [normal_included, tnt_included, nuke_included]
var animations_array: Array[String] = ["normal", "tnt", "nuke"]
var animations_frames: Array[Array] = [[0, 1], [2, 3], [4, 5]]
@export var barrels_scenes: Array[PackedScene] = []

var current_picked_element = 0

var is_picking: bool = false

func _ready() -> void:
	if not picking_array.has(true):
		pick(0)
		return

	begin_picking()
	barrel_body.on_shot.connect(_on_shot)

func _on_shot() -> void:
	if is_picking:
		pick_based_on_frame()
	else:
		pick(current_picked_element)
	
func begin_picking() -> void:
	is_picking = true
	barrel_sprite.play("picking")
	await get_tree().create_timer(picking_time).timeout
	while not picking_array[current_picked_element]:
		current_picked_element += 1
		if current_picked_element >= picking_array.size():
			current_picked_element = 0

	barrel_sprite.play(animations_array[current_picked_element])
	is_picking = false
	await get_tree().create_timer(waiting_time).timeout
	current_picked_element = (current_picked_element + 1) % picking_array.size()
	begin_picking()

func pick(index: int) -> void:
	var scene = barrels_scenes[index]
	var barrel: BarrelBody = scene.instantiate()
	barrel.global_position = barrel_body.global_position
	barrel.global_rotation = barrel_body.global_rotation
	barrel_body.get_parent().add_child(barrel)
	barrel_body.queue_free()

func pick_based_on_frame() -> void:
	if not barrel_sprite.animation == "picking": return
	var frame = barrel_sprite.frame
	for i in range(animations_frames.size()):
		if frame >= animations_frames[i][0] and frame <= animations_frames[i][1]:
			pick(i)
			break
