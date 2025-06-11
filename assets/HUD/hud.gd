extends CanvasLayer

signal score_cycle_completed
signal on_emotionally_triggering_event(event_type: EMOTIONALLY_TRIGGER_EVENT, health: float)

@export var score_for_complete_bar: int = 500
@export var xp_score_color_flash: Color = Color.WHITE
@onready var score_xp_bar: ColorRect = $HUDUI/XP/BarContainer/Bar
@onready var health_label: Label = $HUDUI/Health/HealthContainer/HealthLabel
@onready var health_bar_color_rects_container: VBoxContainer = $HUDUI/Bars
@onready var health_arrows: Label = $HUDUI/Health/Arrows
@onready var systems_label: Label = $HUDUI/Systems
@onready var systems_label_font_size: int = systems_label.label_settings.font_size
@onready var score_label: Label = $HUDUI/XP/Score
@onready var score_label_original_color: Color = score_label.label_settings.font_color
@onready var game_manager: GameManager = %GameManager
@onready var ship_node: InternalShip = %InternalShip
@onready var ship: ShipHealth = %InternalShip/Health
@onready var issues: Issues = %InternalShip/Issues
@onready var bars: Array[ColorRect] = []
@onready var dialog_box: DialogBox = $HUDUI/DialogBox
@onready var time_label: Label = $HUDUI/DialogBox/Clock
@onready var emotion_sprite: AnimatedTextureRect = $HUDUI/Emotion
@onready var controls_animated_texture: AnimatedTextureRect = $Controls
@onready var vhs_effect: AnimationPlayer = $VHS/NoiseAnimation
@onready var speech_bubble_sound: AudioStreamPlayer = $E_N_Stat

var music_bus = AudioServer.get_bus_index("Music")
var sfx_bus = AudioServer.get_bus_index("Sound FX")
var music_bus_muted: bool = AudioServer.is_bus_mute(music_bus)
var sfx_bus_muted: bool = AudioServer.is_bus_mute(sfx_bus)
var is_force_mute: bool = true if music_bus_muted and sfx_bus_muted else false
var started_with_force_mute: bool = is_force_mute

var _freeze_score_to_nearest_cycle = false

enum EMOTIONALLY_TRIGGER_EVENT {
	ISSUE_SPAWNED_RIGHT,
	ISSUE_SPAWNED_LEFT,
	SHIP_BREAKDOWN,
	SHIP_BOOTING_UP,
	ISSUE_FIXED
}

enum COMPUTER_EMOTION {
	DEFAULT,
	NERVOUS,
	SCARED,
	RELIEF
}

const EMOTION_ANIMATIONS: Dictionary = {
	COMPUTER_EMOTION.DEFAULT: "default",
	COMPUTER_EMOTION.NERVOUS: "nervous",
	COMPUTER_EMOTION.SCARED: "scared",
	COMPUTER_EMOTION.RELIEF: "relief"
}

const EMOTION_SOUND_PITCHES: Dictionary = {
	COMPUTER_EMOTION.DEFAULT: 1.0,
	COMPUTER_EMOTION.NERVOUS: 1.2,
	COMPUTER_EMOTION.SCARED: 1.4,
}

const SYSTEMS_TITLES = [
	{ "threshold": 75, "text": "All Systems\nOperational", "font_size_adjustment": 0 },
	{ "threshold": 50, "text": "All Systems\nDegraded", "font_size_adjustment": 0 },
	{ "threshold": 25, "text": "Systems\nPartially Outaged", "font_size_adjustment": -4 },
	{ "threshold": 0, "text": "Systems\nMajorly Outaged", "font_size_adjustment": -4 }
]

const BARS_COLORS = [
	{ "bars_count": 3, "color": Color("216a7a")},
	{ "bars_count": 4, "color": Color("399cb3")},
	{ "bars_count": 4, "color": Color("72bcf2")},
]

const IDLE_ANIMATIONS_LIST: Array[String] = ["default", "nervous", "scared"]
const EVENTS_LINKED_DIALOGS = []


func _ready():
	if is_force_mute:
		controls_animated_texture.play('muted')

	dialog_box.dialog_finished.connect(func() -> void: speech_bubble_sound.stop())

	ship_node.on_ship_breakdown.connect(func() -> void: 
		vhs_effect.play("HIGH")
		await get_tree().create_timer(vhs_effect.get_animation("HIGH").length).timeout
		vhs_effect.play_backwards("HIGH")
	)
	ship_node.on_ship_reviving.connect(func() -> void: vhs_effect.play("LOW"))
	ship_node.on_ship_revived.connect(func() -> void: vhs_effect.play("LOW"))

	_update_systems_titles(100.0)
	score_cycle_completed.connect(_on_score_cycle_complete)
	if game_manager != null:
		game_manager.score_changed.connect(on_score_change)
	if ship != null:
		ship.on_health_change.connect(_on_health_change)

	emotion_sprite.on_animation_ending.connect(_on_emotion_animation_ending)

	var current_bars_count: int = 0
	var current_colors_index: int = 0
	var current_color: Color = BARS_COLORS[0].color

	for bar in health_bar_color_rects_container.get_children():
		bar.color = current_color
		current_bars_count += 1
		if current_bars_count > BARS_COLORS[current_colors_index].bars_count:
			current_bars_count = 0
			current_colors_index += 1
			current_color = BARS_COLORS[current_colors_index].color

	on_emotionally_triggering_event.connect(_play_emotion_triggering_animation)

	issues.on_clear_issues.connect(func(_zone: IssueArea2D, _issues_left: bool) -> void:
		on_emotionally_triggering_event.emit(EMOTIONALLY_TRIGGER_EVENT.ISSUE_FIXED, ship.health)
	)

	issues.on_issue_generated.connect(func(zone: IssueArea2D, _issues_count: int) -> void:
		on_emotionally_triggering_event.emit(EMOTIONALLY_TRIGGER_EVENT.ISSUE_SPAWNED_RIGHT if zone.name.containsn("right") else EMOTIONALLY_TRIGGER_EVENT.ISSUE_SPAWNED_LEFT, ship.health)
	)

	vhs_effect.play("LOW")

	_portray_emotion(COMPUTER_EMOTION.DEFAULT, "Conputer Is Here.\nI Am Conputer. But I am Good Conputer. Have fun")

	game_manager.on_solving_puzzle_changed.connect(func(is_solving_puzzle: bool) -> void: visible = not is_solving_puzzle)

func _physics_process(_delta: float) -> void:
	var time_dict = Time.get_datetime_dict_from_system()
	var hour = time_dict.hour % 12
	if hour == 0:
		hour = 12
	time_label.text = str(hour) + ":" + str(time_dict.minute).pad_zeros(2) + " " + ("AM" if time_dict.hour < 12 else "PM")

func _on_health_change(old_health: float, new_health: float) -> void:
	_update_systems_titles(new_health)
	if emotion_sprite._current_animation in IDLE_ANIMATIONS_LIST:
		_play_emotion_idle_animation(new_health)

	if old_health != new_health:
		health_arrows.rotation_degrees = 270 if new_health > old_health else 90
	
	var color_rects = health_bar_color_rects_container.get_children()
	health_label.text = str(int(new_health))
	var percent_per_bar: float = 100.0 / health_bar_color_rects_container.get_child_count()

	for i in range(color_rects.size()):
		if new_health < percent_per_bar * (i + 1):
			var current_bar_index = color_rects.size() - i - 1
			if current_bar_index == color_rects.size() - 1:
				color_rects[current_bar_index].visible = new_health > 0
			else:
				color_rects[current_bar_index].visible = false
		else:
			color_rects[color_rects.size() - i - 1].visible = true

func _update_systems_titles(new_health: float) -> void:
	for title in SYSTEMS_TITLES:
		if new_health > title.threshold:
			systems_label.text = title.text
			systems_label.label_settings.font_size = systems_label_font_size + title.font_size_adjustment
			break

func _portray_emotion(emotion: COMPUTER_EMOTION, dialog: String, display_animation: bool = true) -> void:
	if emotion in EMOTION_SOUND_PITCHES:
		speech_bubble_sound.pitch_scale = EMOTION_SOUND_PITCHES[emotion]
	
	speech_bubble_sound.play(0.1)

	dialog_box.speak_words(dialog, "E N.Stat", 0.03, 7)
	if display_animation: emotion_sprite.play(EMOTION_ANIMATIONS[emotion])

func on_score_change(old_score: int, new_score: int):
	if not _freeze_score_to_nearest_cycle:
		score_label.text = str(new_score)
	else:
		var nearest_cycle = round(float(new_score) / float(score_for_complete_bar)) * score_for_complete_bar
		score_label.text = str(int(nearest_cycle))

	var remainder = fmod(new_score, score_for_complete_bar)
	var completion_percentage = remainder / score_for_complete_bar
	score_xp_bar.scale.x = completion_percentage
	
	if remainder < old_score % score_for_complete_bar:
		score_cycle_completed.emit()

func _on_score_cycle_complete() -> void:
	_freeze_score_to_nearest_cycle = true

	for i in range(3):
		score_label.label_settings.font_color = xp_score_color_flash
		await get_tree().create_timer(0.2).timeout
		score_label.label_settings.font_color = score_label_original_color
		await get_tree().create_timer(0.2).timeout

	_freeze_score_to_nearest_cycle = false

func _play_emotion_idle_animation(health: float) -> void:
	if health <= 30:
		if emotion_sprite._current_animation != "scared":
			emotion_sprite.play("scared")
			_portray_emotion(COMPUTER_EMOTION.SCARED, SCARED_DIALOGS.pick_random(), false)
	elif health <= 60:
		if emotion_sprite._current_animation != "nervous":
			emotion_sprite.play("nervous")
			_portray_emotion(COMPUTER_EMOTION.DEFAULT, NERVOUS_DIALOGS.pick_random(), false)
	else:
		if emotion_sprite._current_animation != "default":
			emotion_sprite.play("default")

func _on_emotion_animation_ending(animation_name: String) -> void:
	if animation_name in IDLE_ANIMATIONS_LIST: return
	_play_emotion_idle_animation(ship.health)

func _play_emotion_triggering_animation(event_type: EMOTIONALLY_TRIGGER_EVENT, _health: float) -> void:
	if event_type == EMOTIONALLY_TRIGGER_EVENT.ISSUE_FIXED:
		_portray_emotion(COMPUTER_EMOTION.RELIEF, ISSUE_FIXED_DIALOGS.pick_random())
		emotion_sprite.play("relief")
	elif event_type == EMOTIONALLY_TRIGGER_EVENT.ISSUE_SPAWNED_RIGHT:
		_portray_emotion(COMPUTER_EMOTION.NERVOUS, ISSUE_SPAWNED_DIALOGS.pick_random())
		emotion_sprite.play("issue_right")
	elif event_type == EMOTIONALLY_TRIGGER_EVENT.ISSUE_SPAWNED_LEFT:
		_portray_emotion(COMPUTER_EMOTION.NERVOUS, ISSUE_SPAWNED_DIALOGS.pick_random())
		emotion_sprite.play("issue_left")

const ISSUE_FIXED_DIALOGS = [
	"This is not the time to be dead in space! Keep going!",
	"Phew, that was close! Let's hope it's not going to happen again.",
	"Dang, You fixed this one instantly! You are a PRO!",
	"Houston, We HAD a problem. All good now!"
]

const NERVOUS_DIALOGS = [
	"I'm nervous, I'm nervous, I'm nervous!",
	"Some things are broken and it was not me"
]

const SCARED_DIALOGS = [
	"We're at risk here move faster!",
	"I'm scared, I'm scared, I'm scared!",
]

const ISSUE_SPAWNED_DIALOGS = [
	"Houston, we have a problem!",
	"I Discovered a problem on the ship, Head there quick!",
	"THE SYSTEMS ARE DOWN! FIX IT!"
]

func _on_mute_button_pressed() -> void:
	_toggle_audible_animation()

func _input(event: InputEvent) -> void:	
	if event.is_action_pressed("mute"):
		_toggle_audible_animation()

func _toggle_audible_animation() -> void:
	if is_force_mute:
		controls_animated_texture.play('audible')
		AudioServer.set_bus_mute(music_bus, false if started_with_force_mute else music_bus_muted)
		AudioServer.set_bus_mute(sfx_bus, false if started_with_force_mute else sfx_bus_muted)
		is_force_mute = false
	else:
		controls_animated_texture.play('muted')
		AudioServer.set_bus_mute(music_bus, true)
		AudioServer.set_bus_mute(sfx_bus, true)
		is_force_mute = true

enum VHS_EFFECT_INTENSITY {
	LOW,
	MEDIUM,
	HIGH
}
