extends SceneTree

const MainUtil := preload("res://scripts/prototype/main.gd")
const PlayfieldUtil := preload("res://scripts/core/playfield.gd")


func _init() -> void:
	assert(is_equal_approx(PlayfieldUtil.BASE_FIELD_W, 16.0))
	assert(is_equal_approx(PlayfieldUtil.BASE_FIELD_H, 9.0))
	assert(is_equal_approx(PlayfieldUtil.SCALE, 1.5))
	assert(is_equal_approx(PlayfieldUtil.FIELD_W, 24.0))
	assert(is_equal_approx(PlayfieldUtil.FIELD_H, 13.5))
	assert(is_equal_approx(MainUtil.FIELD_W, PlayfieldUtil.FIELD_W))
	assert(is_equal_approx(MainUtil.FIELD_H, PlayfieldUtil.FIELD_H))
	assert(is_equal_approx(MainUtil.PLAYFIELD_SCALE, PlayfieldUtil.SCALE))
	assert(MainUtil.TUNNEL_NEAR_RADIUS > Vector2(MainUtil.FIELD_W, MainUtil.FIELD_H).length() * 0.85)

	var main := MainUtil.new()
	root.add_child(main)
	await process_frame
	assert(main.camera != null)
	assert(is_equal_approx(main.camera.size, PlayfieldUtil.FIELD_H))
	var bg := _find_floor_plane(main)
	assert(bg != null)
	assert((bg.mesh as PlaneMesh).size.is_equal_approx(Vector2(PlayfieldUtil.FIELD_W, PlayfieldUtil.FIELD_H)))
	assert(main.tunnel_ring_multimesh.custom_aabb.size.x >= MainUtil.TUNNEL_NEAR_RADIUS * 3.0)
	assert(main.tunnel_radial_multimesh.custom_aabb.size.z >= MainUtil.TUNNEL_NEAR_RADIUS * 3.0)
	main.player.pos = Vector2(99.0, 99.0)
	main.player.update_motion(0.0, MainUtil.FIELD_W, MainUtil.FIELD_H, MainUtil.FIELD_EDGE_MARGIN)
	assert(is_equal_approx(main.player.pos.x, PlayfieldUtil.FIELD_W * 0.5 - MainUtil.FIELD_EDGE_MARGIN))
	assert(is_equal_approx(main.player.pos.y, PlayfieldUtil.FIELD_H * 0.5 - MainUtil.FIELD_EDGE_MARGIN))
	main.queue_free()
	await process_frame
	print("playfield scale verification passed")
	quit()


func _find_floor_plane(root: Node) -> MeshInstance3D:
	for child in root.get_children():
		var mesh_instance := child as MeshInstance3D
		if mesh_instance != null and mesh_instance.mesh is PlaneMesh:
			return mesh_instance
	return null
