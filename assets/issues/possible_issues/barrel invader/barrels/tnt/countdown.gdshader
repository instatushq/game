shader_type canvas_item;

uniform float end_time = 5.0; //length of animation in seconds
uniform float start_freq : hint_range(0.0, 1.0, 0.05) = 1; //how fast the flashing will be at start of animation
uniform float end_freq : hint_range(1.0, 20.0, 0.5) = 10; //how fast it will be in the end
uniform float time; //time variable to set in code
uniform vec3 flash_color : source_color = vec3(1.0);
uniform float blink_length : hint_range(0.0, 1.0) = 0.5;

void fragment() {
	float phase = 2.0 * PI * (start_freq * time + (end_freq - start_freq) / (2.0 * end_time) * time*time);
	float wave = sin(phase);
	float blink_wave = wave * (1.0/blink_length) - (1.0/blink_length) + 1.0;

	vec4 t = texture(TEXTURE, UV);
	if (blink_wave > 0.0) {
    	vec3 colorMix = mix(t.rgb, flash_color.rgb, blink_wave);
    	COLOR = vec4(colorMix, t.a); // Preserve the alpha value from the texture
	}
}
