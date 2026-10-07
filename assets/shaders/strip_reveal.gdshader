shader_type canvas_item;

// Shows a texture through the sliding strips of strip_reveal.gdshaderinc.
#include "res://assets/shaders/strip_reveal.gdshaderinc"

void fragment() {
	float shift = strip_shift(UV.x);
	COLOR = shift < 2.0 ? texture(TEXTURE, vec2(UV.x - shift, UV.y)) : vec4(0.0);
}
