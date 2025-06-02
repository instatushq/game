shader_type canvas_item;
uniform vec4 default_color;
uniform vec4 detection_color;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	COLOR = default_color;
}