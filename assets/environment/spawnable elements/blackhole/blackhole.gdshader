shader_type canvas_item;

uniform sampler2D curve;
uniform float strength : hint_range(-1.0, 1.0) = 0.5;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear;

void fragment() {
	vec2 vector_to_center = vec2(0.5, 0.5) - UV;
	float distance_to_center = length(vector_to_center);
	float curve_value = textureLod(curve, vec2(distance_to_center, 0.0), 0.0).r;
	vec2 diff = normalize(vector_to_center) * strength * curve_value;
	COLOR = textureLod(SCREEN_TEXTURE, SCREEN_UV - diff, 0.0);
}