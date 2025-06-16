extends Node2D

class_name Issues

@export var possible_issues: Array[PackedScene] = []
@export var notification_icon_scene: PackedScene
var possible_zones: Array = []

var current_issues: Dictionary = {}
var current_notifications: Dictionary = {}

@export var chance_of_issues: int = 50
var last_entered_zone: IssueArea2D = null
var is_issue_open: bool = false
@onready var game_manager: GameManager = get_node("/root/Game/GameManager")
@onready var timer: Timer = $Timer
@onready var issue_resolved_sound: AudioStreamPlayer = $IssueSolved
@onready var issues_randomizer: IssuesRandomizer = $IssuesRandomizer

signal zone_body_entered(zone: IssueArea2D, body: Node2D)
signal zone_body_exited(zone: IssueArea2D, body: Node2D)
signal on_clear_issues(zone: IssueArea2D,issues_left: bool)
signal on_issue_generated(zone: IssueArea2D, issues_count: int)

func _ready() -> void:
	possible_zones = find_children("*", "IssueArea2D")
	timer.start()
	for zone in possible_zones:
		zone.connect("body_entered", Callable(self, "_on_area_entered").bind(zone))
		zone.connect("body_exited", Callable(self, "_on_area_exited").bind(zone))

	on_clear_issues.connect(Callable(self, "_on_clear_issues"))
	issues_randomizer.init_weights(possible_issues.size())


func _on_area_entered(body: Node, zone: IssueArea2D) -> void:
	last_entered_zone = zone
	zone_body_entered.emit(zone, body)
	set_notification_icon_type(zone, IssueIcon.ICON_TYPE.INTERACTABLE)

func _on_area_exited(body: Node, zone: IssueArea2D) -> void:
	if last_entered_zone and last_entered_zone.get_instance_id() == zone.get_instance_id():
		last_entered_zone = null

	zone_body_exited.emit(zone, body)
	set_notification_icon_type(zone, IssueIcon.ICON_TYPE.EXCLAMATION_MARK)

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("interact"):
		if last_entered_zone != null and current_issues.has(last_entered_zone.get_instance_id()) and not game_manager.is_solving_puzzle:
			var current_issue = current_issues[last_entered_zone.get_instance_id()]
			current_issue.open_issue()
			is_issue_open = true
			game_manager.is_solving_puzzle = true
	# elif _event is InputEventKey and _event.pressed and _event.keycode == KEY_Q:
	# 	_generate_random_issue(_get_random_issueless_zone())

func _get_random_issueless_zone() -> IssueArea2D:
	var issueless_zones: Array = []
	for zone in possible_zones:
		if not current_issues.has(zone.get_instance_id()):
			issueless_zones.append(zone)
	if issueless_zones.is_empty():
		return null
	return issueless_zones.pick_random()

func _generate_random_issue(zone: IssueArea2D) -> void:
	var random_issue_index = issues_randomizer.get_random_index()
	issues_randomizer.step_randomizer(random_issue_index)
	var random_issue = possible_issues[random_issue_index]
	var issue_instance: Issue = random_issue.instantiate()
	var root_scene_node: Node = get_tree().current_scene
	root_scene_node.add_child(issue_instance)
	issue_instance.issue_resolved.connect(Callable(self, "_on_issue_resolved").bind(zone))
	current_issues[zone.get_instance_id()] = issue_instance
	generate_notification_for_zone(zone)
	var zone_error_sound: AudioStreamPlayer2D = zone.get_node("ErrorNoise")
	if zone_error_sound != null:
		zone_error_sound.play(0.0)
	on_issue_generated.emit(zone, current_issues.size())
	
func _on_timer_timeout() -> void:
	var random_chance = randi_range(0, 100)
	if random_chance < chance_of_issues:
		var random_zone = _get_random_issueless_zone()
		if random_zone != null:
			_generate_random_issue(random_zone)

func _on_issue_resolved(zone: IssueArea2D) -> void:
	var issue_id = zone.get_instance_id()
	current_issues[issue_id].queue_free()
	current_issues.erase(issue_id)
	is_issue_open = false
	game_manager.is_solving_puzzle = false
	remove_notification_for_zone(zone)
	on_clear_issues.emit(zone, has_any_issues())
	issue_resolved_sound.play()

func has_any_issues() -> bool:
	return not current_issues.is_empty()

func does_right_zone_have_issues() -> bool:
	for zone in possible_zones:
		if zone.name.containsn("right") and current_issues.has(zone.get_instance_id()):
			return true
	return false

enum ISSUE_DIRECTION {
	RIGHT,
	LEFT
}

func does_zone_have_issues(direction: ISSUE_DIRECTION) -> bool:
	for zone in possible_zones:
		if direction == ISSUE_DIRECTION.RIGHT and zone.name.containsn("right"):
			return current_issues.has(zone.get_instance_id())
		elif direction == ISSUE_DIRECTION.LEFT and zone.name.containsn("left"):
			return current_issues.has(zone.get_instance_id())
	return false

func generate_notification_for_zone(zone: IssueArea2D) -> void:
	var notification_instance: IssueIcon = notification_icon_scene.instantiate()
	zone.add_child(notification_instance)
	if last_entered_zone and last_entered_zone.get_instance_id() == zone.get_instance_id():
		notification_instance.set_icon(IssueIcon.ICON_TYPE.INTERACTABLE)

	notification_instance.position = zone.notification_icon_local_position
	current_notifications[zone.get_instance_id()] = notification_instance

func remove_notification_for_zone(zone: IssueArea2D) -> void:
	current_notifications[zone.get_instance_id()].queue_free()
	current_notifications.erase(zone.get_instance_id())

func set_notification_icon_type(zone: IssueArea2D, icon_type: IssueIcon.ICON_TYPE) -> void:
	if not current_notifications.has(zone.get_instance_id()): return
	var notification_instance: IssueIcon = current_notifications[zone.get_instance_id()]
	notification_instance.set_icon(icon_type)
