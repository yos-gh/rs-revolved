extends SceneTree

const MainUtil := preload("res://scripts/prototype/main.gd")
const EnemyUtil := preload("res://scripts/game/enemy.gd")


func _init() -> void:
	var main := MainUtil.new()
	root.add_child(main)
	await process_frame

	assert(main._enemy_shadow_shape("zako0") == "triangle")
	assert(main._enemy_shadow_shape("zako1") == "diamond")
	assert(main._enemy_shadow_shape("zako2") == "round")
	assert(main._enemy_shadow_shape("zako4") == "diamond")
	assert(main._enemy_shadow_shape("zako5") == "triangle")
	assert(main._enemy_shadow_shape("zakoM0") == "diamond")

	var triangle := main._enemy_shadow_plate_mesh("zako0") as ArrayMesh
	var diamond := main._enemy_shadow_plate_mesh("zako1") as ArrayMesh
	var roundish := main._enemy_shadow_plate_mesh("zako2") as ArrayMesh
	assert(_vertex_count(triangle) == 7)
	assert(_vertex_count(diamond) == 9)
	assert(_vertex_count(roundish) == 25)
	assert(_mesh_extent(triangle).y > EnemyUtil.zako_radius("zako0") * 2.0)
	assert(_mesh_extent(diamond).x > EnemyUtil.zako_radius("zako1") * 2.0)
	assert(_mesh_extent(roundish).x > _mesh_extent(roundish).y)
	assert(_has_faded_edge(triangle))
	assert(_edge_feather(triangle) < 1.85)

	var mat := main._enemy_shadow_material(0.22)
	assert(mat.cull_mode == BaseMaterial3D.CULL_DISABLED)
	assert(mat.vertex_color_use_as_albedo)
	assert(mat.albedo_color.b > mat.albedo_color.r)
	assert(mat.albedo_color.g > mat.albedo_color.r)
	assert(mat.albedo_color.a < 0.26)

	assert(main.player_shadow == null)

	main.tunnel_time = 1.25
	var sample_pos := Vector2(4.0, 2.0)
	var tunnel_projection := main._tunnel_shadow_projection(sample_pos, 0.0)
	var tunnel_shadow_pos: Vector2 = tunnel_projection["pos"]
	assert(tunnel_shadow_pos.is_equal_approx(sample_pos))
	var tunnel_shadow_transform := main._tunnel_shadow_transform(sample_pos, 0.0, Vector3.ONE)
	assert(is_equal_approx(tunnel_shadow_transform.origin.y, main.TUNNEL_SHADOW_HEIGHT))
	assert(tunnel_shadow_transform.basis.y.normalized().dot(Vector3.UP) > 0.999)
	var center_shadow_projection := main._tunnel_shadow_projection(Vector2.ZERO, 0.0)
	var edge_shadow_projection := main._tunnel_shadow_projection(Vector2(main.FIELD_W * 0.48, main.FIELD_H * 0.42), 0.0)
	var center_shadow_scale: Vector3 = center_shadow_projection["scale"]
	var edge_shadow_scale: Vector3 = edge_shadow_projection["scale"]
	assert(edge_shadow_scale.x > center_shadow_scale.x * 2.0)

	main.queue_free()
	await process_frame
	await process_frame
	print("enemy shadow shapes verification passed")
	quit()


func _vertex_count(mesh: ArrayMesh) -> int:
	var arrays := mesh.surface_get_arrays(0)
	return (arrays[Mesh.ARRAY_VERTEX] as PackedVector3Array).size()

func _has_faded_edge(mesh: ArrayMesh) -> bool:
	var arrays := mesh.surface_get_arrays(0)
	var colors := arrays[Mesh.ARRAY_COLOR] as PackedColorArray
	var min_alpha := 1.0
	var max_alpha := 0.0
	for color in colors:
		min_alpha = minf(min_alpha, color.a)
		max_alpha = maxf(max_alpha, color.a)
	return min_alpha == 0.0 and max_alpha < 1.0 and max_alpha > 0.8


func _edge_feather(mesh: ArrayMesh) -> float:
	var arrays := mesh.surface_get_arrays(0)
	var vertices := arrays[Mesh.ARRAY_VERTEX] as PackedVector3Array
	var inner_max := 0.0
	var outer_max := 0.0
	var point_count := int((vertices.size() - 1) / 2)
	for i in range(point_count):
		var inner := vertices[i + 1]
		var outer := vertices[point_count + i + 1]
		inner_max = maxf(inner_max, Vector2(inner.x, inner.z).length())
		outer_max = maxf(outer_max, Vector2(outer.x, outer.z).length())
	return outer_max / inner_max


func _mesh_extent(mesh: ArrayMesh) -> Vector2:
	var arrays := mesh.surface_get_arrays(0)
	var vertices := arrays[Mesh.ARRAY_VERTEX] as PackedVector3Array
	var min_pos := Vector2(INF, INF)
	var max_pos := Vector2(-INF, -INF)
	for vertex in vertices:
		min_pos = Vector2(minf(min_pos.x, vertex.x), minf(min_pos.y, vertex.z))
		max_pos = Vector2(maxf(max_pos.x, vertex.x), maxf(max_pos.y, vertex.z))
	return max_pos - min_pos
