class_name PostProcessing extends CanvasLayer

@onready var vignette: ColorRect = $Vignette
@onready var game_vignette: ColorRect = $GameVignette

func toggle_vignette(toggled: bool):
	vignette.visible = toggled
	game_vignette.visible = not toggled