class_name SequenceTextureButton extends TextureButton

@export var neutral_sequence: Texture2D
@export var showing_sequence: Texture2D
@export var correct_sequence: Texture2D
@export var incorrect_sequence: Texture2D

enum SequenceState {
	NEUTRAL,
	SHOWING,
	CORRECT,
	INCORRECT
}

func set_sequence_texture(state: SequenceState) -> void:
	var textures: Array[Texture2D] = [neutral_sequence, showing_sequence, correct_sequence, incorrect_sequence]
	texture_normal = textures[state]
