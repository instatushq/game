extends Node2D

@onready var ship_health: ShipHealth = $"../Health"
var possible_issues: Array[PackedScene] = []
var possible_zones: Array = []

var current_issues: Dictionary = {}
var chance_of_issues: int = 0

func _ready() -> void:
	possible_zones = find_children("*", "Area2D")

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
	var issue_instance = random_issue.instantiate()
	zone.add_child(issue_instance)
	current_issues[zone.get_instance_id()] = issue_instance

func _on_timer_timeout() -> void:
	var random_chance = randi_range(0, 100)
	if random_chance < chance_of_issues:
		var random_zone = _get_random_issueless_zone()
		if random_zone != null:
			_generate_random_issue(random_zone)