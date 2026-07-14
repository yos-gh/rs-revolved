class_name DebugOverlay
extends Node3D

const DEBUG_HEIGHT := 0.02
const DEFAULT_LINE_WIDTH := 0.025

var _mesh_instance: MeshInstance3D
var _material: ShaderMaterial
var _vertices := PackedVector3Array()
var _colors := PackedColorArray()
var _indices := PackedInt32Array()


func _init() -> void:
	_mesh_instance = MeshInstance3D.new()
	_mesh_instance.name = "DebugOverlayMesh"
	_mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(_mesh_instance)

	_material = ShaderMaterial.new()
	var shader := Shader.new()
	shader.code = """
shader_type spatial;
render_mode unshaded, cull_disabled, blend_mix, depth_draw_never;

void fragment() {
	ALBEDO = COLOR.rgb;
	ALPHA = COLOR.a;
}
"""
	_material.shader = shader
	_mesh_instance.material_override = _material


func set_enabled(value: bool) -> void:
	visible = value
	if not value:
		clear_shapes()


func begin_shapes() -> void:
	_vertices.clear()
	_colors.clear()
	_indices.clear()


func end_shapes() -> void:
	if _vertices.is_empty():
		_mesh_instance.mesh = null
		return

	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = _vertices
	arrays[Mesh.ARRAY_COLOR] = _colors
	arrays[Mesh.ARRAY_INDEX] = _indices

	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	_mesh_instance.mesh = mesh


func clear_shapes() -> void:
	begin_shapes()
	_mesh_instance.mesh = null


func show_segment(a: Vector2, b: Vector2, width: float, color: Color) -> void:
	_append_segment(a, b, width, color)


func show_circle(center: Vector2, radius: float, color: Color, segments := 24) -> void:
	for i in range(segments):
		var a0 := TAU * float(i) / float(segments)
		var a1 := TAU * float(i + 1) / float(segments)
		var p0 := center + Vector2(cos(a0), sin(a0)) * radius
		var p1 := center + Vector2(cos(a1), sin(a1)) * radius
		show_segment(p0, p1, DEFAULT_LINE_WIDTH, color)


func show_capsule(a: Vector2, b: Vector2, radius: float, color: Color) -> void:
	var dir := b - a
	if dir.length_squared() <= 0.000001:
		show_circle(a, radius, color)
		return
	var normal := dir.normalized().orthogonal()
	show_segment(a + normal * radius, b + normal * radius, DEFAULT_LINE_WIDTH, color)
	show_segment(a - normal * radius, b - normal * radius, DEFAULT_LINE_WIDTH, color)
	show_circle(a, radius, color, 16)
	show_circle(b, radius, color, 16)


func _append_segment(a: Vector2, b: Vector2, width: float, color: Color) -> void:
	var dir := b - a
	if dir.length_squared() <= 0.000001:
		return
	var normal := dir.normalized().orthogonal() * width * 0.5
	var start_index := _vertices.size()
	_vertices.push_back(Vector3(a.x + normal.x, DEBUG_HEIGHT, a.y + normal.y))
	_vertices.push_back(Vector3(a.x - normal.x, DEBUG_HEIGHT, a.y - normal.y))
	_vertices.push_back(Vector3(b.x - normal.x, DEBUG_HEIGHT, b.y - normal.y))
	_vertices.push_back(Vector3(b.x + normal.x, DEBUG_HEIGHT, b.y + normal.y))
	for i in range(4):
		_colors.push_back(color)
	_indices.push_back(start_index)
	_indices.push_back(start_index + 1)
	_indices.push_back(start_index + 2)
	_indices.push_back(start_index)
	_indices.push_back(start_index + 2)
	_indices.push_back(start_index + 3)
