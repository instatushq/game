class_name PostProcessing extends CanvasLayer

@onready var vignette: ColorRect = $Vignette
@onready var game_vignette: ColorRect = $GameVignette
@onready var shaking: TextureRect = $Shaking
@onready var timer: Timer = $Shaking/Timer
@onready var animation_player: AnimationPlayer = $Shaking/AnimationPlayer

func _ready() -> void:
	timer.timeout.connect(func(): animation_player.play("stop"))

func toggle_vignette(toggled: bool):
	vignette.visible = toggled
	game_vignette.visible = not toggled

func shake(toggled: bool) -> void:
	animation_player.play("play" if toggled else "stop")
