shader_type spatial;
render_mode blend_mix, depth_draw_never, cull_disabled, unshaded;

// Tunnel wall panels between two neighbouring rings, so the wire tube reads as a solid surface.
// Each instance is a unit plane whose custom data holds (ring, side); the vertex stage moves its
// four corners onto the two rings, and each panel takes a flat shade from which way it faces.

const int RING_COUNT = 40;
const int SEGMENTS = 8;
const float TAU_F = 6.28318530718;

uniform vec4 face_color : source_color = vec4(1.0);
uniform float face_alpha = 0.35;
uniform float face_height = 0.010;
uniform vec2 light_dir = vec2(-0.6, -0.8);
uniform vec4 ring_shape[RING_COUNT];
uniform vec2 ring_twist[RING_COUNT];

varying float shade;

vec2 tunnel_point(int ring, int segment) {
	vec4 shape = ring_shape[ring];
	float angle = float(segment) / float(SEGMENTS) * TAU_F + ring_twist[ring].x;
	return shape.xy + vec2(cos(angle) * shape.z, sin(angle) * shape.w);
}

void vertex() {
	int ring = int(INSTANCE_CUSTOM.x + 0.5);
	int segment = int(INSTANCE_CUSTOM.y + 0.5);
	float depth = ring_twist[ring].y;
	int next_ring = (ring + 1) % RING_COUNT;
	float next_depth = ring_twist[next_ring].y;
	int corner_ring = VERTEX.z > 0.0 ? next_ring : ring;
	int corner_side = VERTEX.x > 0.0 ? (segment + 1) % SEGMENTS : segment;
	vec2 p = tunnel_point(corner_ring, corner_side);
	// The panel faces the tunnel axis; light falls across the tube from one side.
	vec2 mid_a = (tunnel_point(ring, segment) + tunnel_point(ring, (segment + 1) % SEGMENTS)) * 0.5;
	vec2 inward = normalize(ring_shape[ring].xy - mid_a + vec2(1e-5));
	float lambert = dot(inward, normalize(light_dir)) * 0.5 + 0.5;
	float normalized_depth = clamp((depth + next_depth) * 0.5 / float(RING_COUNT - 1), 0.0, 1.0);
	shade = lambert * lambert * smoothstep(0.0, 0.7, normalized_depth);
	VERTEX = vec3(p.x, face_height, p.y);
	if (next_depth <= depth) {
		VERTEX = vec3(0.0);
	}
}

void fragment() {
	ALBEDO = face_color.rgb * shade;
	ALPHA = face_alpha * (0.35 + 0.65 * shade);
}
