shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

// Wire tunnel lines placed on the GPU. Each MultiMesh instance is a unit box whose custom data
// holds (ring, segment); the script only uploads the per-ring shape (40 rings) each frame, and
// the vertex stage stretches the box between two tunnel points, matching the old per-instance
// transforms. Shading matches the StandardMaterial3D the tunnel used before. Rings are octagons,
// so the tube shows its corners.

const int RING_COUNT = 40;
const int SEGMENTS = 8;
const float TAU_F = 6.28318530718;

uniform vec4 albedo : source_color = vec4(1.0);
uniform vec4 emission : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float emission_energy = 1.0;
uniform float roughness = 0.42;
// Radial lines join a ring to the next one; ring lines join neighbouring segments.
uniform bool radial = false;
uniform float line_height = 0.018;
// Per ring: centre xy, radius, squashed radius.
uniform vec4 ring_shape[RING_COUNT];
// Per ring: angle offset, depth (0 far .. RING_COUNT - 1 near).
uniform vec2 ring_twist[RING_COUNT];

vec2 tunnel_point(int ring, int segment) {
	vec4 shape = ring_shape[ring];
	float angle = float(segment) / float(SEGMENTS) * TAU_F + ring_twist[ring].x;
	return shape.xy + vec2(cos(angle) * shape.z, sin(angle) * shape.w);
}

float line_width(float depth, bool is_radial) {
	float normalized_depth = clamp(depth / float(RING_COUNT - 1), 0.0, 1.0);
	float near_width = is_radial ? 0.010 : 0.012;
	return mix(0.0015, near_width, pow(normalized_depth, 0.65));
}

void vertex() {
	int ring = int(INSTANCE_CUSTOM.x + 0.5);
	int segment = int(INSTANCE_CUSTOM.y + 0.5);
	float depth = ring_twist[ring].y;
	vec2 a = tunnel_point(ring, segment);
	vec2 b;
	float width;
	bool hidden = false;
	if (radial) {
		// Rings scroll by index, so the last ring's neighbour is ring 0; the pair that straddles
		// the far/near wrap is the only one skipped.
		int next_ring = (ring + 1) % RING_COUNT;
		float next_depth = ring_twist[next_ring].y;
		hidden = next_depth <= depth;
		b = tunnel_point(next_ring, segment);
		width = line_width((depth + next_depth) * 0.5, true);
	} else {
		b = tunnel_point(ring, (segment + 1) % SEGMENTS);
		width = line_width(depth, false);
	}
	vec2 d = b - a;
	float len = length(d);
	vec2 u = len > 0.0 ? d / len : vec2(1.0, 0.0);
	float z_scale = max(0.01, len);
	vec2 mid = (a + b) * 0.5;
	vec3 v = VERTEX;
	VERTEX = vec3(
		width * u.y * v.x + u.x * z_scale * v.z + mid.x,
		width * v.y + line_height,
		-width * u.x * v.x + u.y * z_scale * v.z + mid.y
	);
	// The box axes stay orthogonal, so the rotation alone carries the normals.
	NORMAL = vec3(u.y * NORMAL.x + u.x * NORMAL.z, NORMAL.y, -u.x * NORMAL.x + u.y * NORMAL.z);
	if (hidden) {
		VERTEX = vec3(0.0);
	}
}

void fragment() {
	ALBEDO = albedo.rgb;
	METALLIC = 0.0;
	ROUGHNESS = roughness;
	SPECULAR = 0.5;
	EMISSION = emission.rgb * emission_energy;
}
