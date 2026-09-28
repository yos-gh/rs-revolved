shader_type spatial;
render_mode unshaded, blend_mix, depth_draw_never, cull_disabled, shadows_disabled, fog_disabled;

// Composites the separately rendered background tunnel with a soft depth-of-field blur.
// The tunnel is flattened into the playfield, so depth is estimated from the distance to
// its vanishing point: the far end (small rings) gets the widest blur.

uniform sampler2D bg_tex : source_color, filter_linear, repeat_disable;
uniform vec2 vanish_world = vec2(0.0);
uniform float near_radius = 24.0;
uniform float ring_squash = 0.58;
uniform float far_blur_px = 2.4;
uniform float near_blur_px = 0.7;
uniform float px_scale = 1.0;
uniform float far_fade = 0.10;

const int TAPS = 12;
const float GOLDEN_ANGLE = 2.39996323;

varying vec2 world_xz;

void vertex() {
	world_xz = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xz;
}

void fragment() {
	vec2 d = (world_xz - vanish_world) * vec2(1.0, 1.0 / ring_squash);
	// Ring radius grows with depth^2.8, so invert that to recover a 0 (far) .. 1 (near) depth.
	float depth = pow(clamp(length(d) / near_radius, 0.0, 1.0), 1.0 / 2.8);
	float radius = mix(far_blur_px, near_blur_px, smoothstep(0.0, 0.75, depth)) * px_scale;
	vec2 texel = 1.0 / vec2(textureSize(bg_tex, 0));

	// Gaussian-weighted Vogel disc: the centre dominates so each wire keeps a sharp core
	// and only gains a soft halo. The viewport is cleared to transparent black, so colour
	// is premultiplied and can be averaged directly.
	vec4 acc = texture(bg_tex, SCREEN_UV);
	float wsum = 1.0;
	for (int i = 1; i < TAPS; i++) {
		float t = sqrt(float(i) / float(TAPS - 1));
		float a = float(i) * GOLDEN_ANGLE;
		float w = exp(-t * t * 2.2);
		acc += texture(bg_tex, SCREEN_UV + vec2(cos(a), sin(a)) * t * radius * texel) * w;
		wsum += w;
	}
	acc /= wsum;

	ALBEDO = acc.rgb / max(acc.a, 1e-4);
	ALPHA = acc.a * (1.0 - far_fade * (1.0 - depth));
}
