shader_type canvas_item;

uniform vec4 baseColor: source_color = vec4(0.3058, 0.835, 0.960, 1.);
uniform float speed = 0.5;
uniform vec4 linesColor: source_color = vec4(0.633232, 0.910156, 0.555693, 1.);
uniform float linesColorIntensity = 5.;
uniform sampler2D hologramTexture;
uniform vec2 hologramTextureTiling = vec2(1., 5.);
uniform float alpha = 1.0;
uniform bool grayscale = false;

vec2 tilingAndOffset(vec2 uv, vec2 tiling, vec2 offset) {
    return mod(uv * tiling + offset, 1);
}

void fragment() {
    vec2 offset = vec2(TIME * speed / 100.0);
    vec2 tiling = tilingAndOffset(UV, hologramTextureTiling, offset);
    
    vec4 noise = texture(hologramTexture, tiling);
    
    float fresnel = 0.71;
    vec4 colorLines = linesColor * vec4(vec3(linesColorIntensity), 1.0);
    vec4 emission = colorLines * fresnel * noise;
    
    vec4 albedo = baseColor;
    float alpha_noise = dot(noise.rgb, vec3(1.0));
    vec4 hologram;
    hologram.rgb = emission.rgb + (1.0 - emission.rgb) * albedo.rgb * albedo.a;
    hologram.a = emission.a + (1.0 - emission.a) * alpha_noise;
    hologram.a = hologram.a + (1.0 - hologram.a) * albedo.a;
    COLOR = texture(TEXTURE, UV);
    
    // Apply grayscale if enabled
    if (grayscale) {
        float gray = dot(COLOR.rgb, vec3(0.299, 0.587, 0.114));
        COLOR.rgb = vec3(gray);
    }
    
    // Apply alpha uniform to underlying texture only
    COLOR.a *= alpha;
    
    COLOR.rgb = COLOR.rgb + (1.0 - COLOR.rgb) * hologram.rgb;
    COLOR.a = min(COLOR.a, hologram.a);
}
