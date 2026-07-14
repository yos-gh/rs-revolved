shader_type spatial;
render_mode unshaded, blend_mix, depth_prepass_alpha, cull_disabled;

uniform vec4 face_color : source_color = vec4(0.2, 0.9, 1.0, 0.28);
uniform float emission_strength : hint_range(0.0, 4.0) = 0.55;

void fragment() {
	ALBEDO = face_color.rgb;
	EMISSION = face_color.rgb * emission_strength;
	ALPHA = face_color.a;
}
