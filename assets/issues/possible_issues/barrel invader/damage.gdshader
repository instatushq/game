shader_type canvas_item;

/**
Color to use for the shock.
*/
uniform vec3 shock_color : source_color = vec3(1.0, 0.0, 0.0);
/**
Initial amplitude of the shock. This will start at this amplitude and
gradually attenuate.
*/
uniform float amplitude = 30.0;
/**
How fast should it move side to side, more frequency means it'll move more quickly
side to side.
*/
uniform float frequency = 10.0;
/**
Time when the effect was triggered. Set this from GDScript to trigger the effect.
*/
uniform float trigger_time = -1.0;
/**
Duration of the effect in seconds.
*/
uniform float duration = 3.0;

void vertex() {
	float time_since_trigger = TIME - trigger_time;
	float effect_strength = 0.0;

	if (trigger_time >= 0.0 && time_since_trigger >= 0.0 && time_since_trigger <= duration) {
		float exponent = time_since_trigger;
		effect_strength = amplitude * exp(-2.0*exponent) * sin(frequency*exponent);
	}

	VERTEX.x += effect_strength;
}

void fragment() {
	float time_since_trigger = TIME - trigger_time;
	vec4 normal_color = texture(TEXTURE, UV);
	vec4 effect_color = normal_color;
	effect_color.a = COLOR.a;

	if (trigger_time >= 0.0 && time_since_trigger >= 0.0 && time_since_trigger <= duration) {
		float exponent = time_since_trigger;
		effect_color.rgb = normal_color.rgb + shock_color * exp(-2.0*exponent);
	}

	COLOR = effect_color;
}