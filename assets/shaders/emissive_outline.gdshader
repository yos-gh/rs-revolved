shader_type spatial;
render_mode unshaded, blend_add, cull_disabled;

uniform vec4 line_color : source_color = vec4(0.4, 1.0, 0.95, 0.9);
uniform float emission_strength : hint_range(0.0, 6.0) = 1.8;

void fragment() {
	ALBEDO = line_color.rgb;
	EMISSION = line_color.rgb * emission_strength;
	ALPHA = line_color.a;
}
