shader_type canvas_item;

// Reveals a texture as vertical strips that slide in from the left one after another,
// the same motion as the title's left band. progress is in seconds since the reveal began.
uniform float progress = 10.0;
uniform int strip_count = 12;
uniform float stagger = 0.03;
uniform float duration = 0.22;
uniform float travel = 1.0;

void fragment() {
	vec4 col = vec4(0.0);
	for (int i = 0; i < strip_count; i++) {
		float p = clamp((progress - float(i) * stagger) / duration, 0.0, 1.0);
		if (p <= 0.0) {
			continue;
		}
		float eased = 1.0 - pow(1.0 - p, 4.0);
		float shift = (1.0 - eased) * travel;
		float lo = float(i) / float(strip_count) - shift;
		float hi = float(i + 1) / float(strip_count) - shift;
		if (UV.x >= lo && UV.x < hi) {
			col = texture(TEXTURE, vec2(UV.x + shift, UV.y));
			break;
		}
	}
	COLOR = col;
}
