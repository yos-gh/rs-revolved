shader_type canvas_item;

// Shows a texture through the sliding strips of strip_reveal.gdshaderinc, torn by the same
// slices as the title logo while it arrives.
#include "res://assets/shaders/strip_reveal.gdshaderinc"
#include "res://assets/shaders/slice_glitch.gdshaderinc"

// The art's own pixel grid (a menu row of the UI SVG), which the slices snap to.
uniform vec2 art_px = vec2(340.0, 14.0);
uniform float slice_max_band = 3.0;
uniform float slice_max_shift = 48.0;

void fragment() {
	vec2 uv = slice_glitch(UV, art_px, slice_max_band, slice_max_shift);
	float shift = strip_shift(uv.x);
	COLOR = shift < 2.0 ? texture(TEXTURE, vec2(uv.x - shift, uv.y)) : vec4(0.0);
}
