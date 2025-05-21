extends Node2D

class_name Issues

@export var possible_issues: Array[PackedScene] = []
var possible_zones: Array = []

var current_issues: Dictionary = {}
var chance_of_issues: int = 80
var last_entered_zone: Area2D = null
var is_issue_open: bool = false
@onready var game_manager: GameManager = get_node("/root/Game/GameManager")
@onready var timer: Timer = $Timer

signal zone_body_entered(zone: Area2D, body: Node2D)
signal zone_body_exited(zone: Area2D, body: Node2D)
signal on_clear_issues(issues_left: bool)
signal on_issue_generated(zone: Area2D, issues_count: int)

func _ready() -> void:
	possible_zones = find_children("*", "Area2D")
	game_manager.current_player_changed.connect(_on_current_player_change)
	for zone in possible_zones:
		zone.connect("body_entered", Callable(self, "_on_area_entered").bind(zone))
		zone.connect("body_exited", Callable(self, "_on_area_exited").bind(zone))

func _on_area_entered(body: Node, zone: Area2D) -> void:
	if current_issues.has(zone.get_instance_id()):
		last_entered_zone = zone
		zone_body_entered.emit(zone, body)

func _on_area_exited(body: Node, zone: Area2D) -> void:
	if last_entered_zone and last_entered_zone.get_instance_id() == zone.get_instance_id():
		last_entered_zone = null
	zone_body_exited.emit(zone, body)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_E:
		if last_entered_zone != null:
			var current_issue = current_issues[last_entered_zone.get_instance_id()]
			current_issue.open_issue()
			is_issue_open = true
	elif event is InputEventKey and event.pressed and event.keycode == KEY_Q:
		_generate_random_issue(_get_random_issueless_zone())

func _get_random_issueless_zone() -> Area2D:
	var issueless_zones: Array = []
	for zone in possible_zones:
		if not current_issues.has(zone.get_instance_id()):
			issueless_zones.append(zone)
	if issueless_zones.is_empty():
		return null
	return issueless_zones[randi_range(0, issueless_zones.size() - 1)]

func _generate_random_issue(zone: Area2D) -> void:
	var random_issue = possible_issues[randi_range(0, possible_issues.size() - 1)]
	var issue_instance: Issue = random_issue.instantiate()
	zone.add_child(issue_instance)
	issue_instance.issue_resolved.connect(Callable(self, "_on_issue_resolved").bind(zone))
	current_issues[zone.get_instance_id()] = issue_instance
	on_issue_generated.emit(zone, current_issues.size())
	
func _on_timer_timeout() -> void:
	var random_chance = randi_range(0, 100)
	if random_chance < chance_of_issues:
		var random_zone = _get_random_issueless_zone()
		if random_zone != null:
			_generate_random_issue(random_zone)

func _on_issue_resolved(zone: Area2D) -> void:
	var issue_id = zone.get_instance_id()
	current_issues[issue_id].queue_free()
	current_issues.erase(issue_id)
	is_issue_open = false
	on_clear_issues.emit(has_any_issues())

func _on_current_player_change(new_player: GameManager.Player):
	if new_player == GameManager.Player.SHIP:
		timer.start()
	else:
		timer.stop()

func has_any_issues() -> bool:
	return not current_issues.is_empty()
