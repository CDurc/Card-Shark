shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back;

uniform vec4 color_top : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 color_bottom : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float gradient_shift : hint_range(-1.0, 1.0) = 0.0;
uniform float glow_strength : hint_range(0.0, 100.0) = 1.0;

void fragment() {
    float blend = UV.y + gradient_shift;
    blend = clamp(blend, 0.0, 1.0);
    vec4 final_color = mix(color_bottom, color_top, blend);
    ALBEDO = final_color.rgb;
    ALPHA = final_color.a;
    
    // Glow follows the same gradient
    EMISSION = final_color.rgb * glow_strength * blend;
}