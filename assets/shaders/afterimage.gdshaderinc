// Shared vertex mapping for tunnel afterimages (after the original's shadow()): each object is
// shrunk around its own origin and the origin is pulled toward the tunnel's vanishing point.
// Doing it here lets the afterimage reuse the source's transforms with no per-frame script work.
global uniform vec2 afterimage_vanish;

uniform vec4 color : source_color = vec4(1.0);
uniform float pull = 0.3333333;
uniform float shrink = 0.4;
uniform float height = -5.965;
// Inverse of the part's offset inside its model, so a batched part shrinks around the model origin.
uniform mat4 local_inv = mat4(1.0);

void vertex() {
	vec3 origin = (MODEL_MATRIX * local_inv)[3].xyz;
	vec3 world = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	vec2 mapped = mix(origin.xz, afterimage_vanish, pull);
	vec3 rel = (world - origin) * shrink;
	POSITION = PROJECTION_MATRIX * VIEW_MATRIX * vec4(mapped.x + rel.x, height + rel.y, mapped.y + rel.z, 1.0);
}

void fragment() {
	ALBEDO = color.rgb;
	ALPHA = color.a;
}
