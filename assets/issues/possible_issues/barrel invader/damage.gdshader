shader_type canvas_item;
render_mode unshaded;

uniform float hit_effect : hint_range(0, 1) = 0.0;
uniform float shake_intensity = 10.0;

uniform vec4 blink_color: source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float blink_intensity : hint_range(0.0, 1.0) = 0.0;

uniform vec4 base_modulate : source_color = vec4(1.0);

uniform bool x_offset = true;
uniform bool y_offset = true;

float rand(vec2 co) {
    return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
    vec2 uv_offset = vec2(0.0);
    if (hit_effect > 0.0) {
        float time = TIME * 30.0;
        vec2 random_offset = vec2(
            x_offset ? rand(vec2(time, 0.0)) * 2.0 - 1.0 : 0.0,
            y_offset ? rand(vec2(time, 10.0)) * 2.0 - 1.0 : 0.0
        );
        vec2 tex_size = vec2(textureSize(TEXTURE, 0));
        uv_offset = (random_offset * shake_intensity * hit_effect) / tex_size;
    }

    vec4 c = textureLod(TEXTURE, UV + uv_offset, 0.0);

    if (c.a > 0.0001) {
        c.rgb /= c.a;
    }

    c.rgba *= base_modulate.rgba;

    c = mix(c, blink_color, blink_intensity * c.a);

    c.rgb *= c.a;

    COLOR = c;
}
