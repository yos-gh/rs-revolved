extends SceneTree

const MainUtil := preload("res://scripts/prototype/main.gd")


func _init() -> void:
	var main := MainUtil.new()
	root.add_child(main)
	await process_frame

	for i in range(2):
		main._spawn_enemy("zako0", Vector2(-2.0 + float(i), 0.0))
	for i in range(3):
		main._spawn_enemy("zako1", Vector2(-2.0 + float(i), -0.4))
	for i in range(4):
		main._spawn_enemy("zako2", Vector2(-1.5 + float(i), 0.4))
	for i in range(3):
		main._spawn_enemy("zako3", Vector2(float(i), 0.25 * float(i)))
	for i in range(4):
		main._spawn_enemy("zako3p", Vector2(float(i), -0.25 * float(i)))
	for i in range(2):
		main._spawn_enemy("zako4", Vector2(-1.0 + float(i), 0.5))
	for i in range(3):
		main._spawn_enemy("zako5", Vector2(-1.0 + float(i), -0.8))
	for i in range(2):
		main._spawn_enemy("zako6", Vector2(0.4 + float(i), -1.1))
	for i in range(2):
		main._spawn_enemy("zako7", Vector2(1.0 + float(i), 0.9))
	main._spawn_enemy("zakoM0", Vector2(2.5, -1.3))
	main._spawn_enemy("zakoM1", Vector2(3.0, 1.2))
	main._update_enemy_visual_batches()

	var glider_batch := main.enemy_visual_batches.zako0 as Dictionary
	var glider_visual_entries := glider_batch.visual_entries as Array
	var glider_shadow_entries := glider_batch.shadow_entries as Array
	assert(not glider_visual_entries.is_empty())
	assert(glider_shadow_entries.is_empty())
	assert((glider_visual_entries[0].multimesh as MultiMesh).instance_count == 2)
	var batched_glider := _find_latest_enemy(main.enemies, "zako0")
	assert(String(batched_glider.visual_batch_kind) == "zako0")
	assert(batched_glider.visual_model != null)
	assert(batched_glider.spin_model != null)
	assert(_count_mesh_instances(batched_glider.node as Node) == 0)

	var wedge_batch := main.enemy_visual_batches.zako1 as Dictionary
	var wedge_visual_entries := wedge_batch.visual_entries as Array
	var wedge_shadow_entries := wedge_batch.shadow_entries as Array
	assert(not wedge_visual_entries.is_empty())
	assert(wedge_shadow_entries.is_empty())
	assert((wedge_visual_entries[0].multimesh as MultiMesh).instance_count == 3)
	var batched_wedge := _find_latest_enemy(main.enemies, "zako1")
	assert(String(batched_wedge.visual_batch_kind) == "zako1")
	assert(batched_wedge.visual_model != null)
	assert(batched_wedge.spin_model != null)
	assert(_count_mesh_instances(batched_wedge.node as Node) == 0)

	var fan_batch := main.enemy_visual_batches.zako2 as Dictionary
	var fan_visual_entries := fan_batch.visual_entries as Array
	var fan_shadow_entries := fan_batch.shadow_entries as Array
	assert(not fan_visual_entries.is_empty())
	assert(fan_shadow_entries.is_empty())
	for entry in fan_visual_entries:
		var multimesh := entry.multimesh as MultiMesh
		assert(multimesh.instance_count == 4)
	var batched_fan := _find_latest_enemy(main.enemies, "zako2")
	assert(String(batched_fan.visual_batch_kind) == "zako2")
	assert(batched_fan.visual_model != null)
	assert(batched_fan.spin_model != null)
	assert(_count_mesh_instances(batched_fan.node as Node) == 0)

	var batch := main.enemy_visual_batches.zako3 as Dictionary
	var visual_entries := batch.visual_entries as Array
	var shadow_entries := batch.shadow_entries as Array
	assert(not visual_entries.is_empty())
	assert(shadow_entries.is_empty())
	for entry in visual_entries:
		var multimesh := entry.multimesh as MultiMesh
		assert(multimesh.instance_count == 3)

	var batched_enemy := _find_latest_enemy(main.enemies, "zako3")
	assert(String(batched_enemy.visual_batch_kind) == "zako3")
	assert(_count_mesh_instances(batched_enemy.node as Node) == 0)
	assert(not batched_enemy.has("shadow") or batched_enemy.shadow == null)

	var part_batch := main.enemy_visual_batches.zako3p as Dictionary
	var part_visual_entries := part_batch.visual_entries as Array
	var part_shadow_entries := part_batch.shadow_entries as Array
	assert(not part_visual_entries.is_empty())
	assert(part_shadow_entries.is_empty())
	for entry in part_visual_entries:
		var multimesh := entry.multimesh as MultiMesh
		assert(multimesh.instance_count == 4)
	var batched_part := _find_latest_enemy(main.enemies, "zako3p")
	assert(String(batched_part.visual_batch_kind) == "zako3p")
	assert(batched_part.visual_model != null)
	assert(batched_part.spin_model != null)
	assert(_count_mesh_instances(batched_part.node as Node) == 0)
	assert(not batched_part.has("shadow") or batched_part.shadow == null)

	var battery_batch := main.enemy_visual_batches.zako4 as Dictionary
	var battery_visual_entries := battery_batch.visual_entries as Array
	var battery_shadow_entries := battery_batch.shadow_entries as Array
	assert(not battery_visual_entries.is_empty())
	assert(battery_shadow_entries.is_empty())
	for entry in battery_visual_entries:
		var multimesh := entry.multimesh as MultiMesh
		assert(multimesh.instance_count == 2)
	var batched_battery := _find_latest_enemy(main.enemies, "zako4")
	assert(String(batched_battery.visual_batch_kind) == "zako4")
	assert(batched_battery.visual_model != null)
	assert(batched_battery.spin_model != null)
	assert(_count_mesh_instances(batched_battery.node as Node) == 0)
	for muzzle_index in range(4):
		var muzzle := main._zako4_muzzle_pose(batched_battery, muzzle_index)
		assert((muzzle.pos as Vector2).distance_to(batched_battery.pos) > 0.20)

	var ray_batch := main.enemy_visual_batches.zako5 as Dictionary
	var ray_visual_entries := ray_batch.visual_entries as Array
	var ray_shadow_entries := ray_batch.shadow_entries as Array
	assert(not ray_visual_entries.is_empty())
	assert(ray_shadow_entries.is_empty())
	for entry in ray_visual_entries:
		var multimesh := entry.multimesh as MultiMesh
		assert(multimesh.instance_count == 3)
	var batched_ray := _find_latest_enemy(main.enemies, "zako5")
	assert(String(batched_ray.visual_batch_kind) == "zako5")
	assert(batched_ray.visual_model != null)
	assert(batched_ray.spin_model != null)
	assert(_count_mesh_instances(batched_ray.node as Node) == 0)

	var orbit_batch := main.enemy_visual_batches.zako6 as Dictionary
	var orbit_visual_entries := orbit_batch.visual_entries as Array
	var orbit_shadow_entries := orbit_batch.shadow_entries as Array
	assert(not orbit_visual_entries.is_empty())
	assert(orbit_shadow_entries.is_empty())
	for entry in orbit_visual_entries:
		var multimesh := entry.multimesh as MultiMesh
		assert(multimesh.instance_count == 2)
	var batched_orbit := _find_latest_enemy(main.enemies, "zako6")
	assert(String(batched_orbit.visual_batch_kind) == "zako6")
	assert(batched_orbit.visual_model != null)
	assert(batched_orbit.spin_model != null)
	assert(_count_mesh_instances(batched_orbit.node as Node) == 0)

	var glider7_batch := main.enemy_visual_batches.zako7 as Dictionary
	var glider7_visual_entries := glider7_batch.visual_entries as Array
	var glider7_shadow_entries := glider7_batch.shadow_entries as Array
	assert(not glider7_visual_entries.is_empty())
	assert(glider7_shadow_entries.is_empty())
	for entry in glider7_visual_entries:
		var multimesh := entry.multimesh as MultiMesh
		assert(multimesh.instance_count == 2)
	var batched_glider7 := _find_latest_enemy(main.enemies, "zako7")
	assert(String(batched_glider7.visual_batch_kind) == "zako7")
	assert(batched_glider7.visual_model != null)
	assert(batched_glider7.spin_model != null)
	assert(_count_mesh_instances(batched_glider7.node as Node) == 0)

	var crystal_batch := main.enemy_visual_batches.zako7p as Dictionary
	var crystal_visual_entries := crystal_batch.visual_entries as Array
	var crystal_shadow_entries := crystal_batch.shadow_entries as Array
	assert(not crystal_visual_entries.is_empty())
	assert(crystal_shadow_entries.is_empty())
	var batched_crystal := _find_latest_enemy(main.enemies, "zako7p")
	assert(String(batched_crystal.visual_batch_kind) == "zako7p")
	assert(batched_crystal.visual_model != null)
	assert(batched_crystal.spin_model != null)
	assert(_count_mesh_instances(batched_crystal.node as Node) == 0)
	for entry in crystal_visual_entries:
		var multimesh := entry.multimesh as MultiMesh
		assert(multimesh.instance_count >= 16)

	var bastion_batch := main.enemy_visual_batches.zakoM0 as Dictionary
	var bastion_visual_entries := bastion_batch.visual_entries as Array
	var bastion_shadow_entries := bastion_batch.shadow_entries as Array
	assert(not bastion_visual_entries.is_empty())
	assert(bastion_visual_entries.size() <= 10)
	assert(bastion_shadow_entries.is_empty())
	for entry in bastion_visual_entries:
		var multimesh := entry.multimesh as MultiMesh
		assert(multimesh.instance_count == 1)
	var batched_bastion := _find_latest_enemy(main.enemies, "zakoM0")
	assert(String(batched_bastion.visual_batch_kind) == "zakoM0")
	assert(batched_bastion.visual_model != null)
	assert(_count_mesh_instances(batched_bastion.visual_model as Node) == 0)
	assert(batched_bastion.gun0 != null)
	assert(batched_bastion.gun1 != null)
	assert((batched_bastion.node as Node).find_child("zakoM0-lattice-keep", false, false) == null)
	var bastion_template := main._enemy_visual_batch_template("zakoM0")
	assert(bastion_template.name == "zakoM0-lattice-keep")
	assert(bastion_template.find_children("zakoM0-crystal-plate-*", "MeshInstance3D", true, false).size() == 3)
	assert(_count_mesh_instances(bastion_template) == 9)
	bastion_template.free()

	var crystal_m_batch := main.enemy_visual_batches.zakoM1 as Dictionary
	var crystal_m_visual_entries := crystal_m_batch.visual_entries as Array
	var crystal_m_shadow_entries := crystal_m_batch.shadow_entries as Array
	assert(not crystal_m_visual_entries.is_empty())
	assert(crystal_m_shadow_entries.is_empty())
	for entry in crystal_m_visual_entries:
		var multimesh := entry.multimesh as MultiMesh
		assert(multimesh.instance_count == 1)
	var batched_crystal_m := _find_latest_enemy(main.enemies, "zakoM1")
	assert(String(batched_crystal_m.visual_batch_kind) == "zakoM1")
	assert(batched_crystal_m.visual_model != null)
	assert(batched_crystal_m.spin_model != null)
	assert(_count_mesh_instances(batched_crystal_m.node as Node) == 0)

	main._clear_enemies()
	for entry in glider_visual_entries:
		var multimesh := entry.multimesh as MultiMesh
		assert(multimesh.instance_count == 0)
	for entry in wedge_visual_entries:
		var multimesh := entry.multimesh as MultiMesh
		assert(multimesh.instance_count == 0)
	for entry in fan_visual_entries:
		var multimesh := entry.multimesh as MultiMesh
		assert(multimesh.instance_count == 0)
	for entry in visual_entries:
		var multimesh := entry.multimesh as MultiMesh
		assert(multimesh.instance_count == 0)
	for entry in part_visual_entries:
		var multimesh := entry.multimesh as MultiMesh
		assert(multimesh.instance_count == 0)
	for entry in battery_visual_entries:
		var multimesh := entry.multimesh as MultiMesh
		assert(multimesh.instance_count == 0)
	for entry in ray_visual_entries:
		var multimesh := entry.multimesh as MultiMesh
		assert(multimesh.instance_count == 0)
	for entry in orbit_visual_entries:
		var multimesh := entry.multimesh as MultiMesh
		assert(multimesh.instance_count == 0)
	for entry in glider7_visual_entries:
		var multimesh := entry.multimesh as MultiMesh
		assert(multimesh.instance_count == 0)
	for entry in crystal_visual_entries:
		var multimesh := entry.multimesh as MultiMesh
		assert(multimesh.instance_count == 0)
	for entry in bastion_visual_entries:
		var multimesh := entry.multimesh as MultiMesh
		assert(multimesh.instance_count == 0)
	for entry in crystal_m_visual_entries:
		var multimesh := entry.multimesh as MultiMesh
		assert(multimesh.instance_count == 0)

	main.queue_free()
	await process_frame
	await process_frame
	glider_visual_entries.clear()
	glider_shadow_entries.clear()
	wedge_visual_entries.clear()
	wedge_shadow_entries.clear()
	fan_visual_entries.clear()
	fan_shadow_entries.clear()
	visual_entries.clear()
	shadow_entries.clear()
	part_visual_entries.clear()
	part_shadow_entries.clear()
	battery_visual_entries.clear()
	battery_shadow_entries.clear()
	ray_visual_entries.clear()
	ray_shadow_entries.clear()
	orbit_visual_entries.clear()
	orbit_shadow_entries.clear()
	glider7_visual_entries.clear()
	glider7_shadow_entries.clear()
	crystal_visual_entries.clear()
	crystal_shadow_entries.clear()
	bastion_visual_entries.clear()
	bastion_shadow_entries.clear()
	crystal_m_visual_entries.clear()
	crystal_m_shadow_entries.clear()
	glider_batch.clear()
	wedge_batch.clear()
	fan_batch.clear()
	batch.clear()
	part_batch.clear()
	battery_batch.clear()
	ray_batch.clear()
	orbit_batch.clear()
	glider7_batch.clear()
	crystal_batch.clear()
	bastion_batch.clear()
	crystal_m_batch.clear()
	batched_glider.clear()
	batched_wedge.clear()
	batched_fan.clear()
	batched_enemy.clear()
	batched_part.clear()
	batched_battery.clear()
	batched_ray.clear()
	batched_orbit.clear()
	batched_glider7.clear()
	batched_crystal.clear()
	batched_bastion.clear()
	batched_crystal_m.clear()
	print("enemy visual batching verification passed")
	quit()


func _find_latest_enemy(enemies: Array[Dictionary], kind: String) -> Dictionary:
	for index in range(enemies.size() - 1, -1, -1):
		if enemies[index].kind == kind:
			return enemies[index]
	return {}


func _count_mesh_instances(node: Node) -> int:
	var count := 1 if node is MeshInstance3D else 0
	for child in node.get_children():
		count += _count_mesh_instances(child)
	return count
