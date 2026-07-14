shader_type spatial;
render_mode unshaded, blend_mix, depth_draw_never, depth_test_disabled, cull_disabled;

uniform vec4 face_color : source_color = vec4(0.82, 0.96, 1.0, 0.15);
uniform float emission_strength : hint_range(0.0, 4.0) = 0.55;

void fragment() {
	ALBEDO = face_color.rgb;
	EMISSION = face_color.rgb * emission_strength;
	ALPHA = face_color.a;
}
