extends Node2D

@onready var barrel_body: BarrelBody = get_parent()

@export var screen_detector: VisibleOnScreenNotifier2D = null
@export var barrel_sprite: AnimatedSprite2D = null
@export var glitch_effect: AnimationPlayer = null

@export_range(0.5, 4) var picking_time: float = 0.3
@export_range(0.5, 4) var waiting_time: float = 1
@export_range(0.1, 0.4) var reduce_waiting_time_by_on_exposure: float = 0.2
var original_waiting_time: float = waiting_time

@export var normal_included: bool = true
@export var tnt_included: bool = true
@export var nuke_included: bool = true

@export var reinforced_barrel: PackedScene = null
var picking_array: Array[bool] = [normal_included, tnt_included, nuke_included]
var animations_array: Array[String] = ["normal", "tnt", "nuke"]
var animations_frames: Array[Array] = [[0, 1], [2, 3], [4, 5]]
@export var barrels_scenes: Array[PackedScene] = []

var current_picked_element = 0

var is_going_to_pick_reinforced: bool = false
var is_picking: bool = false
var exposed: bool = false

func _ready() -> void:
	if not picking_array.has(true):
		pick(0)
		return

	begin_picking()
	barrel_body.on_shot.connect(_on_shot)
	screen_detector.screen_entered.connect(func(): exposed = true)

func _on_shot() -> void:
	if is_picking:
		pick_based_on_frame()
	else:
		pick(current_picked_element)

func pick_reinforced_in(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout
	pick(-1)

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
	if exposed:
		waiting_time = max(waiting_time - reduce_waiting_time_by_on_exposure, 0.0)
		if waiting_time <= original_waiting_time * 0.5:
			glitch_effect.play("normal")
		elif waiting_time <= original_waiting_time * 0.25:
			glitch_effect.play("critical")
			
		if waiting_time <= 0.0 and not is_going_to_pick_reinforced:
			is_going_to_pick_reinforced = true
			pick_reinforced_in(1.4)
		
	begin_picking()

func pick(index: int) -> void:
	var scene = barrels_scenes[index] if index != -1 else reinforced_barrel
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
