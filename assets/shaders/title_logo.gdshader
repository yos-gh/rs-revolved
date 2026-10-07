shader_type canvas_item;

// The title logo: the atlas slides in through the strips of strip_reveal.gdshaderinc while
// sharp horizontal slices tear it sideways. The V arrives as a single chevron, one letter
// thick; once its strips land, the upper and lower chevrons slip out from behind it.
#include "res://assets/shaders/strip_reveal.gdshaderinc"

// One white chevron on the atlas grid (the middle one); the V is three copies of it.
uniform sampler2D chevron_mask : filter_linear, repeat_disable;
// Slice tearing fades out over this window of progress (seconds).
uniform float glitch_fade_start = 0.30;
uniform float glitch_fade_end = 0.62;
uniform float glitch_rate = 30.0;
// The V splits over this window of progress (seconds), starting as soon as its own strips
// (3 and 4 of 12) have landed: 3 * stagger + duration.
uniform float split_start = 0.31;
uniform float split_time = 0.32;

const vec2 ATLAS_PX = vec2(640.0, 64.0);
// Split, the chevrons sit the original 8px apart.
const float SPLIT_GAP = 8.0;
// The V's own colours: one gradient per chevron, top to bottom.
const vec3 PIECE_TOP[3] = {vec3(1.0, 0.0, 0.0), vec3(0.835, 0.290, 0.286), vec3(0.722, 0.675, 0.671)};
const vec3 PIECE_BOTTOM[3] = {vec3(0.933, 0.125, 0.125), vec3(0.647, 0.627, 0.624), vec3(0.565, 0.800, 0.792)};
// The middle chevron's bounding rows on the atlas.
const float CHEVRON_TOP = 22.0;
const float CHEVRON_H = 24.0;
// A letter stem (the R's) whose rows carry the letters' gradient.
const float STEM_X = 52.5;
const float LETTER_TOP = 22.0;
const float LETTER_H = 17.0;

float hash11(float p) {
	return fract(sin(p * 127.1) * 43758.5453);
}

float hash21(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

void fragment() {
	vec2 uv = UV;
	// Slices: random bands of rows jump sideways in whole atlas pixels, re-rolled at a
	// steady rate so the tearing reads digital rather than wobbly.
	float glitch = progress > 0.0 ? 1.0 - smoothstep(glitch_fade_start, glitch_fade_end, progress) : 0.0;
	if (glitch > 0.0 && exit_progress < 0.0) {
		float st = floor(progress * glitch_rate) + 1.0;
		float y = uv.y * ATLAS_PX.y;
		float band_h = mix(1.0, 7.0, hash11(st * 0.37 + 1.0));
		float band_id = floor((y + hash11(st) * 8.0) / band_h);
		float slice_on = step(1.0 - 0.45 * glitch, hash21(vec2(band_id, st)));
		float slice_px = floor((hash21(vec2(band_id, st + 7.0)) - 0.5) * 90.0 * glitch + 0.5);
		uv.x += slice_on * slice_px / ATLAS_PX.x;
	}

	float shift = strip_shift(uv.x);
	if (shift >= 2.0) {
		COLOR = vec4(0.0);
	} else {
		vec2 tex_uv = vec2(uv.x - shift, uv.y);
		vec4 col = texture(TEXTURE, tex_uv);
		// Ease out: the outer chevrons shoot clear, then settle.
		float split = 1.0 - pow(1.0 - clamp((progress - split_start) / split_time, 0.0, 1.0), 3.0);
		vec2 px = tex_uv * ATLAS_PX;
		// Alone, the middle chevron takes the letters' gradient so it reads as one more letter.
		float solo_t = clamp((px.y - CHEVRON_TOP) / CHEVRON_H, 0.0, 1.0);
		vec3 solo_col = texture(TEXTURE, vec2(STEM_X, LETTER_TOP + 0.5 + solo_t * (LETTER_H - 1.0)) / ATLAS_PX).rgb;
		// Outer chevrons first so they slide out from behind the middle one.
		const int ORDER[3] = {0, 2, 1};
		for (int n = 0; n < 3; n++) {
			int k = ORDER[n];
			if (k != 1 && split <= 0.0) {
				continue;
			}
			float dy = float(k - 1) * SPLIT_GAP * split;
			float m = texture(chevron_mask, (px - vec2(0.0, dy)) / ATLAS_PX).a;
			if (m <= 0.0) {
				continue;
			}
			float piece_t = clamp((px.y - CHEVRON_TOP - dy) / CHEVRON_H, 0.0, 1.0);
			vec3 c = mix(PIECE_TOP[k], PIECE_BOTTOM[k], piece_t);
			if (k == 1) {
				c = mix(solo_col, c, split);
			}
			float a = m + col.a * (1.0 - m);
			col.rgb = (c * m + col.rgb * col.a * (1.0 - m)) / max(a, 1e-4);
			col.a = a;
		}
		COLOR = col;
	}
}
