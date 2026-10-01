shader_type canvas_item;

// Shows a texture as vertical strips that slide in from the left one after another, the
// same motion as the title's left band, and later slide out to the right the same way.
// progress / exit_progress are seconds since each phase began; exit_progress < 0 means
// the strips have not started leaving.
uniform float progress = 10.0;
uniform float exit_progress = -1.0;
uniform int strip_count = 12;
uniform float stagger = 0.03;
uniform float duration = 0.22;
uniform float exit_stagger = 0.015;
uniform float exit_duration = 0.18;
uniform float travel = 1.0;

void fragment() {
	vec4 col = vec4(0.0);
	for (int i = 0; i < strip_count; i++) {
		float p = clamp((progress - float(i) * stagger) / duration, 0.0, 1.0);
		if (p <= 0.0) {
			continue;
		}
		float shift = -(1.0 - (1.0 - pow(1.0 - p, 4.0))) * travel;
		if (exit_progress >= 0.0) {
			float q = clamp((exit_progress - float(i) * exit_stagger) / exit_duration, 0.0, 1.0);
			shift += q * q * q * travel;
		}
		float lo = float(i) / float(strip_count) + shift;
		float hi = float(i + 1) / float(strip_count) + shift;
		if (UV.x >= lo && UV.x < hi) {
			col = texture(TEXTURE, vec2(UV.x - shift, UV.y));
			break;
		}
	}
	COLOR = col;
}
