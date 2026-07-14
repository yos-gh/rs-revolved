extends SceneTree

const DebugOverlayUtil := preload("res://scripts/core/debug_overlay.gd")


func _init() -> void:
	var root := get_root()
	var overlay := DebugOverlayUtil.new()
	root.add_child(overlay)

	overlay.begin_shapes()
	for i in range(50):
		overlay.show_circle(Vector2(float(i) * 0.1, 0.0), 0.35, Color(1.0, 0.2, 0.2, 0.8))
	for i in range(15):
		overlay.show_capsule(Vector2(float(i) * 0.2, -0.5), Vector2(float(i) * 0.2 + 0.8, 0.5), 0.08, Color(0.7, 0.9, 1.0, 0.8))
	overlay.end_shapes()

	assert(overlay.get_child_count() == 1)
	var mesh_instance := overlay.get_child(0) as MeshInstance3D
	assert(mesh_instance != null)
	assert(mesh_instance.mesh != null)
	assert(mesh_instance.mesh.get_surface_count() == 1)

	overlay.clear_shapes()
	assert(mesh_instance.mesh == null)

	overlay.queue_free()
	print("debug overlay verification passed")
	quit()
