class_name Ship extends Node2D

@export var movement_speed: float = 10
@export var bottom_camera_movement_margin: float = 700.0
var side_movement_padding: float = 48.0

@export var cannon_one_active: bool = true
@export var pew_scene: PackedScene = preload("res://assets/ship/projectiles/pew.tscn")
@export var fire_cooldown: float = 0.15
@export var damage_cooldown_seconds: float = 2.0
@export_range(0.0, 100) var reduce_ship_speed_by: float = 67.0
var is_invincible: bool = false

@onready var rb: ShipRigidBody = $ShipRigidBody
@onready var ship_sprite: AnimatedSprite2D = $ShipRigidBody/SpritesContainer/ShipSprite
@onready var sprites_animation_player: AnimationPlayer = $ShipRigidBody/SpritesContainer/SpritesAnimations
@onready var hit_animation_player: AnimationPlayer = $ShipRigidBody/SpritesContainer/ShipStates
@onready var cannon_1: Node2D = $ShipRigidBody/ShipPoints/Canon
@onready var game_manager: BarrelInvader = get_parent()
@onready var cannon_fire: AudioStreamPlayer = $Shoot
@onready var difficulty_manager: DifficultyOrganizer = DifficultyManager

var can_control: bool = false
var can_fire: bool = true
var fire_timer: float = 0.0
var input_buffered: bool = false
var is_firing: bool = false
var current_ship_y_position: float = 300.0

var ship_position: Vector2 = Vector2.DOWN * 400
var is_keyboard_controlled: bool = true
var y_position_synced: bool = false
var global_input_axis: Vector2 = Vector2.ZERO

@export var game_camera: Camera2D

signal on_contact_explosion(body: Node2D, explosion_type: BarrelBody.EXPLOSION_TYPE, intensity: ExplosionNuke.ExplosionIntensity)

func _ready():
	rb.on_barrel_impact.connect(_on_barrel_impact)
	game_manager.game_started.connect(_on_issue_opened)
	on_contact_explosion.connect(_on_contact_explosion)
	_adapt_difficulty()

func _adapt_difficulty() -> void:
	if difficulty_manager.current_difficulty == DifficultyOrganizer.DIFFICULTY.HARD or difficulty_manager.current_difficulty == DifficultyOrganizer.DIFFICULTY.INSANE:
		damage_cooldown_seconds = 0.3
	elif difficulty_manager.current_difficulty == DifficultyOrganizer.DIFFICULTY.EASY or difficulty_manager.current_difficulty == DifficultyOrganizer.DIFFICULTY.MEDIUM:
		damage_cooldown_seconds = 1.5

func _on_contact_explosion(body: Node2D, _explosion_type: BarrelBody.EXPLOSION_TYPE, _intensity: ExplosionNuke.ExplosionIntensity) -> void:
	if not (body is ExplosionNuke or body is ExplosionTNT): return
	if is_invincible: return
	if game_manager.parent_issue.game_manager != null:
		game_manager.parent_issue.game_manager.ship_health.decrease_health(difficulty_manager.process_difficulty_number_increment(3))

	is_invincible = true
	hit_animation_player.play("Took Damage")
	await get_tree().create_timer(damage_cooldown_seconds).timeout
	hit_animation_player.play("normal")
	is_invincible = false

func _on_issue_opened() -> void:
	var global_mouse_position = get_global_mouse_position()
	var camera_position = game_camera.global_position
	var mouse_position_relative_to_camera = global_mouse_position - camera_position
	ship_position = mouse_position_relative_to_camera

func _on_barrel_impact(_barrel: BarrelBody) -> void:
	if is_invincible: return
		
	if game_manager.parent_issue.game_manager != null:
		game_manager.parent_issue.game_manager.ship_health.decrease_health(difficulty_manager.process_difficulty_number_increment(3))

	is_invincible = true
	hit_animation_player.play("Took Damage")
	await get_tree().create_timer(damage_cooldown_seconds).timeout
	hit_animation_player.play("normal")
	is_invincible = false

func _process(delta: float) -> void:
	# ship_sprite.material.set_shader_parameter("base_modulate", ship_sprite.modulate)
	if not game_manager.is_playing: return

	if not can_fire:
		fire_timer += delta
		if fire_timer >= fire_cooldown:
			can_fire = true
			fire_timer = 0.0
			if input_buffered or is_firing:
				input_buffered = false
				can_fire = false
	
	_handle_ship_tilt(global_input_axis)

func _physics_process(_delta: float) -> void:
	var input_axis = Vector2(Input.get_axis("move_left", "move_right"), Input.get_axis("move_up", "move_down"))
	global_input_axis = input_axis
	_handle_ship_movement(input_axis, game_camera)
	
	rb.enforce_global_position(game_camera.global_position + ship_position)

	if Input.is_action_pressed("fire_cannon") and can_fire and game_manager.is_playing:
		_fire_cannons()
		can_fire = false

func _input(event: InputEvent) -> void:
	var input_axis = Vector2.ZERO
	
	if event is InputEventMouseMotion:
		input_axis = Vector2(event.relative.x, event.relative.y) * (reduce_ship_speed_by / 1000)
	_handle_ship_movement(input_axis, game_camera)

func _handle_ship_movement(input_axis: Vector2, camera: Camera2D) -> void:
	var viewport_size = get_viewport_rect().size
	var bottom_edge = ((camera.global_position.y + (viewport_size.y / camera.zoom.y) / 2))
	var right_edge = ((camera.global_position.x + (viewport_size.x / camera.zoom.x) / 2))
	var left_edge = ((camera.global_position.x - viewport_size.x) / camera.zoom.x) / 2
	var final_ship_position_unrestricted = ship_position + (input_axis * movement_speed)
	var final_ship_global_position = camera.global_position + final_ship_position_unrestricted

	var x_position_restricted = clamp(final_ship_global_position.x, left_edge + side_movement_padding, right_edge - side_movement_padding)
	var bottom_edge_to_center = bottom_edge - camera.global_position.y
	var y_position_restricted = clamp(final_ship_position_unrestricted.y, bottom_edge_to_center - bottom_camera_movement_margin, bottom_edge_to_center)
	
	if game_manager.is_playing:
		ship_position = Vector2(x_position_restricted - camera.global_position.x, y_position_restricted)

func toggle_control(new_can_control: bool) -> void:
	can_control = new_can_control
	rb.freeze = not new_can_control

func create_pew(cannon: Node2D) -> void:
	var pew: Pew = pew_scene.instantiate()
	game_manager.add_child(pew)
	pew.global_position = cannon.global_position
	pew.linear_velocity = Vector2.UP * pew.speed
	cannon_fire.play()

func _fire_cannons() -> void:
	sprites_animation_player.play("shoot")
	if cannon_one_active:
		create_pew(cannon_1)

func _handle_ship_tilt(input_axis: Vector2) -> void:
	if input_axis.x > 0:
		ship_sprite.play("right")
	elif input_axis.x < 0:
		ship_sprite.play("left")
	else:
		ship_sprite.play("default")
