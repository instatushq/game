extends ColorRect

@onready var left_group: Array[Node] = $LeftContainer.get_children(false)
@onready var right_group: Array[Node] = $RightContainer.get_children(false)

enum COLOR_MATCH_COLOR {
	RED,
	BLUE,
	YELLOW,
	GREEN,
	PURPLE
}

var current_selected_node = null

const colors_values = {
	COLOR_MATCH_COLOR.RED: Color("#CC3D94"),
	COLOR_MATCH_COLOR.BLUE: Color("#3159BA"),
	COLOR_MATCH_COLOR.YELLOW: Color("#CC3D40"),
	COLOR_MATCH_COLOR.GREEN: Color("#23DEBC"),
	COLOR_MATCH_COLOR.PURPLE: Color("#02B4CF")
}

var assigned_left_colors: Dictionary = {}
var assigned_right_colors: Dictionary = {}
var connected_colors: Array[COLOR_MATCH_COLOR] = []


func _find_element_in_dictionaries(button: Button) -> Dictionary:	
	var button_id = str(button.get_instance_id())
	
	if assigned_left_colors.has(button_id):
		return {
			"found": true,
			"is_left": true,
			"color": assigned_left_colors[button_id]
		}
	elif assigned_right_colors.has(button_id):
		return {
			"found": true,
			"is_left": false,
			"color": assigned_right_colors[button_id]
		}
	
	return {
		"found": false,
		"color": null
	}

func _on_click_colored_button(button: Button) -> void:
	var clicked_button = _find_element_in_dictionaries(button)
	if not clicked_button.found: return

	if current_selected_node == null:
		current_selected_node = clicked_button
		button.get_node("AnimatedSprite2D").play("down")
		return

	if (not clicked_button.is_left and current_selected_node.is_left) or (clicked_button.is_left and not current_selected_node.is_left):
		if clicked_button.color == current_selected_node.color:
			connected_colors.append(clicked_button.color)
			current_selected_node = null
			_update_buttons_view()
			if _is_issue_resolved():
				_resolve_issue()
			return
	
func _assign_colors_randomly() -> void:
	var used_colors: Array[COLOR_MATCH_COLOR] = []
	
	for buttonNode in left_group:
		buttonNode.get_node("AnimatedSprite2D").play("up")
		var button: Button = buttonNode
		var available_colors = COLOR_MATCH_COLOR.values().filter(func(color_value): return not color_value in used_colors)
		var selected_color = COLOR_MATCH_COLOR.RED
		
		if available_colors.size() > 0:
			selected_color = available_colors[randi() % available_colors.size()]
			used_colors.append(selected_color)
		
		assigned_left_colors[str(button.get_instance_id())] = selected_color
		button.modulate = colors_values[assigned_left_colors[str(button.get_instance_id())]]

	used_colors.clear()
	
	for buttonNode in right_group:
		buttonNode.get_node("AnimatedSprite2D").play("up")
		var button: Button = buttonNode
		var available_colors = COLOR_MATCH_COLOR.values().filter(func(color_value): return not color_value in used_colors)
		var selected_color = COLOR_MATCH_COLOR.RED
		
		if available_colors.size() > 0:
			selected_color = available_colors[randi() % available_colors.size()]
			used_colors.append(selected_color)
		
		assigned_right_colors[str(button.get_instance_id())] = selected_color
		button.modulate = colors_values[assigned_right_colors[str(button.get_instance_id())]]

func _assign_controls() -> void:
	for button in left_group:
		button.connect("pressed", func(): _on_click_colored_button(button))
	for button in right_group:
		button.connect("pressed", func(): _on_click_colored_button(button))

func _ready() -> void:
	_assign_colors_randomly()
	_assign_controls()

func _is_issue_resolved() -> bool:
	return connected_colors.size() == COLOR_MATCH_COLOR.keys().size()

func _resolve_issue() -> void:
	var parent: Issue = get_parent().get_parent().get_parent()
	parent.issue_resolved.emit()

func _update_buttons_view() -> void:
	for button in left_group:
		var button_info = _find_element_in_dictionaries(button)
		if button_info.found and button_info.color in connected_colors:
			button.disabled = true
			button.get_node("AnimatedSprite2D").play("down")
	
	for button in right_group:
		var button_info = _find_element_in_dictionaries(button)
		if button_info.found and button_info.color in connected_colors:
			button.disabled = true
			button.get_node("AnimatedSprite2D").play("down")
