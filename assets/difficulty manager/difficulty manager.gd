class_name DifficultyOrganizer extends Node2D

@onready var label: Label = $CanvasLayer/Label

enum DIFFICULTY {
	EASY,
	MEDIUM,
	HARD,
	INSANE
}

var current_difficulty: DIFFICULTY = DIFFICULTY.EASY

signal difficulty_changed(old_difficulty: int, new_difficulty: int)

func get_difficulty() -> DIFFICULTY:
	return current_difficulty

func set_difficulty(new_difficulty: DIFFICULTY) -> void:
	var old_difficulty = get_difficulty()
	current_difficulty = new_difficulty
	difficulty_changed.emit(old_difficulty, new_difficulty)
	label.text = "Difficulty: " + str(DIFFICULTY.keys()[new_difficulty])

func increase_difficulty() -> void:
	if current_difficulty == DIFFICULTY.INSANE: return
	set_difficulty(DIFFICULTY.values()[current_difficulty + 1])

# func _input(event: InputEvent) -> void:
# 	if event is InputEventKey and event.pressed and event.keycode == KEY_R:
# 		set_difficulty(DIFFICULTY.EASY)
# 	elif event is InputEventKey and event.pressed and event.keycode == KEY_T:
# 		set_difficulty(DIFFICULTY.MEDIUM)
# 	elif event is InputEventKey and event.pressed and event.keycode == KEY_Y:
# 		set_difficulty(DIFFICULTY.HARD)
# 	elif event is InputEventKey and event.pressed and event.keycode == KEY_U:
# 		set_difficulty(DIFFICULTY.INSANE)


func process_difficulty_number_increment(difficulty_number: float, ceil_to_decimal: bool = true, difficulty_level: DIFFICULTY = current_difficulty) -> float:
	match difficulty_level:
		DIFFICULTY.EASY:
			return difficulty_number * 1 # don't ceil if its easy level or it'll round up anyways if it's a float
		DIFFICULTY.MEDIUM:
			return ceil(difficulty_number * 1.2) if ceil_to_decimal else difficulty_number * 1.25
		DIFFICULTY.HARD:
			return ceil(difficulty_number * 1.35) if ceil_to_decimal else difficulty_number * 1.5
		DIFFICULTY.INSANE:
			return ceil(difficulty_number * 1.5) if ceil_to_decimal else difficulty_number * 2
	
	return difficulty_number

func process_difficulty_number_decrement(difficulty_number: float, ceil_to_decimal: bool = true, difficulty_level: DIFFICULTY = current_difficulty) -> float:
	match difficulty_level:
		DIFFICULTY.EASY:
			return difficulty_number * 1 # don't ceil if its easy level or it'll round up anyways if it's a float
		DIFFICULTY.MEDIUM:
			return floor(difficulty_number * 0.8) if ceil_to_decimal else difficulty_number * 0.8
		DIFFICULTY.HARD:
			return floor(difficulty_number * 0.65) if ceil_to_decimal else difficulty_number * 0.7
		DIFFICULTY.INSANE:
			return floor(difficulty_number * 0.5) if ceil_to_decimal else difficulty_number * 0.6
	
	return difficulty_number
