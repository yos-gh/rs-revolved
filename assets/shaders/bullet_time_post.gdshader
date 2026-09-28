shader_type canvas_item;
render_mode unshaded, blend_disabled;

// Bullet-time "hyperfocus" post effect. Distances are measured in canvas pixels so the
// player mask stays aligned under any window size or stretch. Effects that move pixels
// use a wider mask than colour-only effects, keeping nearby threats in their true place.

uniform sampler2D screen_tex : hint_screen_texture, filter_linear, repeat_disable;
uniform float intensity : hint_range(0.0, 1.0) = 0.0;
uniform float time = 0.0;
uniform vec2 canvas_size = vec2(1280.0, 720.0);
uniform vec2 focus_px = vec2(640.0, 360.0);
uniform float beat_env = 0.0;
uniform float ring_age = 10.0;
uniform float burst = 0.0;
uniform float burst_seed = 0.0;
uniform float clear_radius = 0.12;
uniform float soft_radius = 0.26;
uniform float shift_clear_radius = 0.20;
uniform float shift_soft_radius = 0.30;

const int ZOOM_TAPS = 5;
const vec3 LUMA = vec3(0.2126, 0.7152, 0.0722);
const vec3 SHADOW_TINT = vec3(0.03, 0.17, 0.24);
const vec3 HIGHLIGHT_TINT = vec3(0.92, 0.96, 1.0);

varying vec2 local_px;

float hash11(float p) {
	p = fract(p * 0.1031);
	p *= p + 33.33;
	p *= p + p;
	return fract(p);
}

float hash21(vec2 p) {
	vec3 p3 = fract(vec3(p.xyx) * 0.1031);
	p3 += dot(p3, p3.yzx + 33.33);
	return fract((p3.x + p3.y) * p3.z);
}

void vertex() {
	local_px = VERTEX;
}

void fragment() {
	// Map canvas pixels to screen UV; both are affine over the quad so derivatives are exact.
	vec2 d_px = vec2(dFdx(local_px.x), dFdy(local_px.y));
	vec2 uv_per_px = vec2(dFdx(SCREEN_UV.x), dFdy(SCREEN_UV.y)) / (sign(d_px) * max(abs(d_px), vec2(1e-5)));
	vec2 focus_uv = SCREEN_UV + (focus_px - local_px) * uv_per_px;

	vec2 to_focus = (local_px - focus_px) / canvas_size.y;
	float dist = length(to_focus);
	vec2 dir_uv = dist > 1e-4 ? normalize((local_px - focus_px) * uv_per_px) : vec2(0.0);
	float periph = smoothstep(clear_radius, clear_radius + soft_radius, dist);
	float shift_mask = smoothstep(shift_clear_radius, shift_clear_radius + shift_soft_radius, dist);
	float amt = intensity * periph;
	float shift_amt = intensity * shift_mask;
	vec2 screen_n = local_px / canvas_size;
	float edge = smoothstep(0.25, 0.95, length((screen_n - 0.5) * vec2(canvas_size.x / canvas_size.y, 1.0)) * 1.25);

	// Stepped clock: glitch layouts jump at ~15 fps like hand-keyed motion graphics.
	float st = floor(time * 15.0) + burst_seed * 17.0;
	vec2 uv = SCREEN_UV;

	// Beat shockwave: a faint refracting ring travelling out from the player.
	float ring_r = shift_clear_radius + ring_age * 1.0;
	float ring = exp(-pow((dist - ring_r) / 0.05, 2.0)) * exp(-ring_age * 2.6);
	uv -= dir_uv * ring * 0.008 * shift_amt;

	// Slice displacement: horizontal bands tear sideways, mostly during beat bursts.
	float band_h = mix(0.010, 0.06, hash11(st * 0.37 + 1.0));
	float band_id = floor((screen_n.y + hash11(st) * 0.5) / band_h);
	float slice_on = step(1.0 - (0.02 + 0.22 * burst) * intensity, hash21(vec2(band_id, st)));
	float slice_shift = (hash21(vec2(band_id, st + 7.0)) - 0.5) * (0.010 + 0.07 * burst) * slice_on * shift_mask;
	uv.x += slice_shift;

	// Smear streaks: a segment of a band is stretched from its left edge like a pixel-sort
	// streak. A few run constantly; beat bursts add many more.
	float smear_h = mix(0.004, 0.022, hash11(st * 0.71 + 9.0));
	float smear_id = floor((screen_n.y + hash11(st + 13.0) * 0.3) / smear_h);
	float smear_on = step(1.0 - (0.035 + 0.16 * burst) * intensity, hash21(vec2(smear_id, st + 31.0)));
	float seg_start = hash21(vec2(smear_id, st + 41.0));
	float seg_len = mix(0.04, 0.32, hash21(vec2(smear_id, st + 43.0)));
	float in_seg = step(seg_start, screen_n.x) * step(screen_n.x, seg_start + seg_len);
	smear_on *= in_seg * step(0.3, shift_mask);
	uv.x = mix(uv.x, uv.x - (screen_n.x - seg_start) * 0.94 * canvas_size.x * uv_per_px.x, smear_on);

	// Block corruption: sparse coarse cells pixelate and sample from a neighbouring region.
	vec2 bsize = vec2(mix(28.0, 96.0, hash11(st + 3.0)), mix(10.0, 36.0, hash11(st + 5.0)));
	vec2 bid = floor(local_px / bsize);
	float block_on = step(1.0 - (0.022 + 0.09 * burst) * intensity, hash21(bid + st * 1.37)) * step(0.5, shift_mask);
	vec2 block_off = (vec2(hash21(bid + st), hash21(bid - st)) - 0.5) * vec2(0.06, 0.02);
	vec2 cell_uv = SCREEN_UV + ((floor(local_px / 6.0) * 6.0 + 3.0) - local_px) * uv_per_px + block_off;
	uv = mix(uv, cell_uv, block_on);

	// Radial zoom blur toward the player plus spectral chromatic aberration.
	float blur = shift_amt * (0.010 + 0.016 * beat_env);
	float ca = amt * (0.0025 + 0.006 * edge + 0.004 * beat_env) + slice_on * shift_mask * 0.004 * (1.0 + burst);
	vec2 rel = uv - focus_uv;
	vec3 col = vec3(0.0);
	float wsum = 0.0;
	for (int i = 0; i < ZOOM_TAPS; i++) {
		float t = float(i) / float(ZOOM_TAPS - 1);
		float w = 1.0 - t * 0.75;
		float s = 1.0 - blur * t;
		col.r += texture(screen_tex, focus_uv + rel * (s + ca)).r * w;
		col.g += texture(screen_tex, focus_uv + rel * s).g * w;
		col.b += texture(screen_tex, focus_uv + rel * (s - ca)).b * w;
		wsum += w;
	}
	col /= wsum;

	// Grading: pull the periphery toward a cold duotone while keeping value contrast.
	float lum = dot(col, LUMA);
	vec3 duo = mix(SHADOW_TINT, HIGHLIGHT_TINT, smoothstep(0.02, 0.85, lum));
	vec3 graded = mix(col, duo * (0.4 + lum * 0.9), 0.30 * edge);
	graded = (graded - 0.5) * (1.0 + 0.12 * intensity) + 0.5;
	col = mix(col, graded, amt);

	// Vignette that breathes with the beat.
	float vig = smoothstep(0.35, 1.05, length((screen_n - 0.5) * vec2(canvas_size.x / canvas_size.y, 1.0)) * 1.2);
	col *= 1.0 - vig * (0.34 + 0.08 * beat_env) * intensity;

	// Scanlines, analog line noise and chroma grain.
	float scan = 0.5 + 0.5 * sin(local_px.y * 3.14159);
	col *= 1.0 - (0.13 + 0.05 * beat_env) * amt * scan;
	float line_id = floor(local_px.y / 2.0);
	float line_r = hash21(vec2(line_id, st + 57.0));
	float line_on = step(1.0 - (0.012 + 0.03 * burst) * intensity, line_r);
	col += (hash11(line_id + st * 3.1) - 0.35) * 0.35 * line_on * amt;
	vec3 grain = vec3(
		hash21(local_px + fract(time) * 311.0),
		hash21(local_px + fract(time) * 173.0 + 19.0),
		hash21(local_px + fract(time) * 97.0 + 41.0)) - 0.5;
	col += mix(vec3(grain.g), grain, 0.5) * 0.10 * amt;

	COLOR = vec4(clamp(col, 0.0, 1.0), 1.0);
}
