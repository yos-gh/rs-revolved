// Sharp horizontal slices that tear the art sideways while its strips slide in. Bands of
// rows jump in whole art pixels, re-rolled at a steady rate so the tearing reads digital
// rather than wobbly, and fade out as the strips settle. Needs strip_reveal.gdshaderinc.
// Slice tearing fades out over this window of progress (seconds).
uniform float glitch_fade_start = 0.30;
uniform float glitch_fade_end = 0.62;
uniform float glitch_rate = 30.0;

float slice_hash11(float p) {
	return fract(sin(p * 127.1) * 43758.5453);
}

float slice_hash21(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

// uv shifted by the current slices; art_px is the art's size in its own pixels, bands are
// 1 to max_band_px rows tall and jump up to max_shift_px, all in those pixels.
vec2 slice_glitch(vec2 uv, vec2 art_px, float max_band_px, float max_shift_px) {
	float glitch = progress > 0.0 ? 1.0 - smoothstep(glitch_fade_start, glitch_fade_end, progress) : 0.0;
	if (glitch > 0.0 && exit_progress < 0.0) {
		float st = floor(progress * glitch_rate) + 1.0;
		float y = uv.y * art_px.y;
		float band_h = mix(1.0, max_band_px, slice_hash11(st * 0.37 + 1.0));
		float band_id = floor((y + slice_hash11(st) * (max_band_px + 1.0)) / band_h);
		float slice_on = step(1.0 - 0.45 * glitch, slice_hash21(vec2(band_id, st)));
		float slice_px = floor((slice_hash21(vec2(band_id, st + 7.0)) - 0.5) * max_shift_px * glitch + 0.5);
		uv.x += slice_on * slice_px / art_px.x;
	}
	return uv;
}
