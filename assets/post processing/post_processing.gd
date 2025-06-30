class_name PostProcessing extends CanvasLayer

@onready var vignette: ColorRect = $Vignette

func toggle_vignette(toggled: bool):
	vignette.visible = toggled
