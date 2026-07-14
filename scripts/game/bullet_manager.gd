class_name BulletManager
extends Node3D

signal hit_effect_requested(pos: Vector2, color: Color, impact_direction: Vector2)

const CollisionUtil := preload("res://scripts/core/collision.gd")
const PlayerUtil := preload("res://scripts/game/player.gd")
const VisualMaterialsUtil := preload("res://scripts/core/visual_materials.gd")

const SHOT_SPEED := 24.0
const BULLET0_SPEED := 1.8
const BULLET1_SPEED := 7.5
const BULLET2_SPEED := 4.5
const BOSS_B1_SPEED := 6.0
const BOSS_B2_SPEED := 4.5
const BOSS_B2_HOMING_RATE := PI
const HOSTILE_BULLET_RADIUS := 0.09
const BOSS_UNBLOCKABLE_BULLET_RADIUS := 0.16
const BOSS_B2_RADIUS := 0.075
const HOSTILE_CAPSULE_BULLET_RADIUS := 0.075
const HOSTILE_CAPSULE_BULLET_LENGTH := 0.46
const BULLET1_VISUAL_LENGTH := 0.552
const BULLET1_VISUAL_HALF_WIDTH := 0.075
const BULLET1_INNER_LENGTH := 0.48
const BULLET1_COLLISION_RADIUS := 0.070
const BULLET1_COLLISION_LENGTH := BULLET1_VISUAL_LENGTH - BULLET1_COLLISION_RADIUS * 2.0
const BULLET2_VISUAL_LENGTH := 0.44
const BULLET2_VISUAL_HALF_WIDTH := 0.065
const BULLET2_COLLISION_RADIUS := 0.060
const BULLET2_COLLISION_LENGTH := BULLET2_VISUAL_LENGTH - BULLET2_COLLISION_RADIUS * 2.0
const BULLET3_VISUAL_HALF_WIDTH := 0.045
const BULLET3_COLLISION_RADIUS := 0.040
const PLAYER_SHOT_RADIUS := 0.055
const PLAYER_SHOT_LENGTH := 0.55
const LINE_BULLET_LENGTH := 1.15
const ZAKO_LINE_BULLET_LENGTH := 0.82
const BOSS_B1_BASE_SCALE := 1.35
const BOSS_B1_CORE_SCALE := 1.30
const BOSS_B1_INITIAL_SCALE := BOSS_B1_BASE_SCALE * BOSS_B1_CORE_SCALE
const BOSS_B1_INITIAL_LENGTH := LINE_BULLET_LENGTH * BOSS_B1_INITIAL_SCALE
const BOSS_B1_VISUAL_HALF_WIDTH := 0.050 * BOSS_B1_CORE_SCALE
const BOSS_B1_COLLISION_RADIUS := 0.048 * BOSS_B1_CORE_SCALE
const BOSS_B1_COLLISION_LENGTH := BOSS_B1_INITIAL_LENGTH - BOSS_B1_COLLISION_RADIUS * 2.0
const BOSS_B1_GROWTH_SCALE := 2.00
const HOSTILE_DIRECTION_LINE_LENGTH := 0.90
const HOSTILE_DIRECTION_LINE_WIDTH := 0.012
const BULLET0_SPIN_SPEED := 2.2
const BULLET0_VISUAL_SCALE := 0.68
const DEFAULT_HOSTILE_BULLET_LIFETIME := INF
const BULLET0_OUTER_COLOR := Color(0.77, 0.04, 0.28)
const BULLET0_INNER_COLOR := Color(0.97, 0.12, 0.40)

const DISPLAY_NAMES := {
	"player_shot": "Wire Diamond",
	"bullet0": "Rugby Spindle",
	"bullet1": "Amber Bolt",
	"bullet2": "Orange Prism",
	"bullet3": "Low Rail",
	"boss_b1": "Piercing Light",
	"boss_b2": "Homing Wedge",
	"boss_orb": "Scarlet Orb",
	"hostile_capsule": "Hostile Capsule",
}

var bullets: Array[Dictionary] = []

var _palette := {}
var _game_mode := "arcade"
var _arcade_rank := 0
var _batch_root: Node3D
var _batch_instances := {}
var _batch_dirty := false


func setup(palette: Dictionary) -> void:
	_palette = palette
	name = "BulletManager"
	_setup_visual_batches()


func _setup_visual_batches() -> void:
	if _batch_root != null:
		return
	_batch_root = Node3D.new()
	_batch_root.name = "BatchedBulletVisuals"
	add_child(_batch_root)

	var bullet0_outer := PackedVector3Array([
		Vector3(0.0, 0.0, -0.30), Vector3(-0.10, 0.0, -0.20),
		Vector3(-0.14, 0.0, 0.0), Vector3(-0.10, 0.0, 0.20),
		Vector3(0.0, 0.0, 0.30), Vector3(0.10, 0.0, 0.20),
		Vector3(0.14, 0.0, 0.0), Vector3(0.10, 0.0, -0.20),
	])
	var bullet0_inner := PackedVector3Array([
		Vector3(0.0, 0.018, -0.245), Vector3(-0.078, 0.018, -0.16),
		Vector3(-0.108, 0.018, 0.0), Vector3(-0.078, 0.018, 0.16),
		Vector3(0.0, 0.018, 0.245), Vector3(0.078, 0.018, 0.16),
		Vector3(0.108, 0.018, 0.0), Vector3(0.078, 0.018, -0.16),
	])
	_create_batch("bullet0_outer", _polygon_mesh(bullet0_outer), VisualMaterialsUtil.flat_face(BULLET0_OUTER_COLOR, 0.94, 0.14))
	_create_batch("bullet0_inner", _polygon_mesh(bullet0_inner), VisualMaterialsUtil.flat_face(BULLET0_INNER_COLOR, 0.88, 0.58))
	_create_batch("bullet0_tail_light", _box_mesh(Vector3(HOSTILE_DIRECTION_LINE_WIDTH * 2.0, HOSTILE_DIRECTION_LINE_WIDTH * 2.0, HOSTILE_DIRECTION_LINE_LENGTH)), VisualMaterialsUtil.transparent_outline(Color(220.0 / 255.0, 200.0 / 255.0, 200.0 / 255.0).darkened(0.10), 0.60, 0.35))
	_create_batch("bullet0_tail_dark", _box_mesh(Vector3(HOSTILE_DIRECTION_LINE_WIDTH * 2.0, HOSTILE_DIRECTION_LINE_WIDTH * 2.0, HOSTILE_DIRECTION_LINE_LENGTH)), VisualMaterialsUtil.transparent_outline(Color(90.0 / 255.0, 90.0 / 255.0, 90.0 / 255.0).darkened(0.10), 0.60, 0.35))

	var bullet1_outer := PackedVector3Array([
		Vector3(-BULLET1_VISUAL_HALF_WIDTH, 0.0, -BULLET1_VISUAL_LENGTH * 0.5), Vector3(-BULLET1_VISUAL_HALF_WIDTH, 0.0, BULLET1_VISUAL_LENGTH * 0.5),
		Vector3(BULLET1_VISUAL_HALF_WIDTH, 0.0, BULLET1_VISUAL_LENGTH * 0.5), Vector3(BULLET1_VISUAL_HALF_WIDTH, 0.0, -BULLET1_VISUAL_LENGTH * 0.5),
	])
	var bullet1_inner := PackedVector3Array([
		Vector3(-0.042, 0.063, -BULLET1_INNER_LENGTH * 0.5), Vector3(-0.042, 0.063, BULLET1_INNER_LENGTH * 0.5),
		Vector3(0.042, 0.063, BULLET1_INNER_LENGTH * 0.5), Vector3(0.042, 0.063, -BULLET1_INNER_LENGTH * 0.5),
	])
	_create_batch("bullet1_outer", _polygon_mesh(bullet1_outer), VisualMaterialsUtil.flat_face(Color(0.72, 0.44, 0.02), 0.94, 0.12))
	_create_batch("bullet1_inner", _polygon_mesh(bullet1_inner), VisualMaterialsUtil.flat_face(Color(1.0, 0.84, 0.18), 0.92, 0.62))

	var bullet2_outer := PackedVector3Array([
		Vector3(-BULLET2_VISUAL_HALF_WIDTH, 0.0, -BULLET2_VISUAL_LENGTH * 0.5), Vector3(-BULLET2_VISUAL_HALF_WIDTH, 0.0, BULLET2_VISUAL_LENGTH * 0.5),
		Vector3(BULLET2_VISUAL_HALF_WIDTH, 0.0, BULLET2_VISUAL_LENGTH * 0.5), Vector3(BULLET2_VISUAL_HALF_WIDTH, 0.0, -BULLET2_VISUAL_LENGTH * 0.5),
	])
	var bullet2_inner := PackedVector3Array([
		Vector3(-0.034, 0.056, -0.19), Vector3(-0.034, 0.056, 0.19),
		Vector3(0.034, 0.056, 0.19), Vector3(0.034, 0.056, -0.19),
	])
	_create_batch("bullet2_outer", _polygon_mesh(bullet2_outer), VisualMaterialsUtil.flat_face(Color(0.70, 0.36, 0.02), 0.94, 0.10))
	_create_batch("bullet2_inner", _polygon_mesh(bullet2_inner), VisualMaterialsUtil.flat_face(Color(1.0, 0.66, 0.12), 0.92, 0.55))

	_create_batch("bullet3_outer", _box_mesh(Vector3(BULLET3_VISUAL_HALF_WIDTH * 2.0, BULLET3_VISUAL_HALF_WIDTH * 2.0, 1.0)), VisualMaterialsUtil.flat_face(BULLET0_OUTER_COLOR, 0.92, 0.24))
	var bullet3_inner_material := VisualMaterialsUtil.flat_face(BULLET0_INNER_COLOR, 0.88, 0.58)
	bullet3_inner_material.render_priority = 1
	_create_batch("bullet3_inner", _box_mesh(Vector3(0.052, 0.052, 1.0)), bullet3_inner_material)


func _create_batch(key: String, mesh: Mesh, material: Material) -> void:
	var multimesh := MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.mesh = mesh
	multimesh.instance_count = 0
	var instance := MultiMeshInstance3D.new()
	instance.name = "%s-batch" % key
	instance.multimesh = multimesh
	instance.material_override = material
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_batch_root.add_child(instance)
	_batch_instances[key] = multimesh


func _polygon_mesh(perimeter: PackedVector3Array) -> ArrayMesh:
	var points := PackedVector3Array([Vector3(0.0, perimeter[0].y, 0.0)])
	points.append_array(perimeter)
	var indices := PackedInt32Array()
	for index in perimeter.size():
		indices.append_array(PackedInt32Array([0, index + 1, (index + 1) % perimeter.size() + 1]))
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = points
	arrays[Mesh.ARRAY_INDEX] = indices
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return mesh


func _box_mesh(size: Vector3) -> BoxMesh:
	var mesh := BoxMesh.new()
	mesh.size = size
	return mesh


func _is_batched_visual(display_key: String) -> bool:
	return display_key in ["bullet0", "bullet1", "bullet2", "bullet3"]


func _refresh_visual_batches() -> void:
	var transforms := {}
	for key in _batch_instances:
		transforms[key] = []

	for bullet in bullets:
		if not bullet.get("batched_visual", false) or bullet.life <= 0.0:
			continue
		var display_key: String = bullet.get("visual_key", "")
		var root_rotation := _visual_rotation_for_bullet(bullet.angle, "")
		var root_basis := Basis(Vector3.UP, root_rotation)
		var root_origin := _to_world(bullet.pos, 0.25)
		if display_key == "bullet0":
			var spin_basis := Basis(Vector3.UP, root_rotation + float(bullet.get("age", 0.0)) * BULLET0_SPIN_SPEED).scaled(Vector3.ONE * BULLET0_VISUAL_SCALE)
			var spin_transform := Transform3D(spin_basis, root_origin)
			(transforms["bullet0_outer"] as Array).append(spin_transform)
			(transforms["bullet0_inner"] as Array).append(spin_transform)
			var tail_key := "bullet0_tail_light" if bullet.get("tail_light", false) else "bullet0_tail_dark"
			var tail_origin := root_origin + root_basis * Vector3(0.0, 0.040, -HOSTILE_DIRECTION_LINE_LENGTH * 0.5)
			(transforms[tail_key] as Array).append(Transform3D(root_basis, tail_origin))
		elif display_key == "bullet1":
			var transform := Transform3D(root_basis, root_origin)
			(transforms["bullet1_outer"] as Array).append(transform)
			(transforms["bullet1_inner"] as Array).append(transform)
		elif display_key == "bullet2":
			var transform := Transform3D(root_basis, root_origin)
			(transforms["bullet2_outer"] as Array).append(transform)
			(transforms["bullet2_inner"] as Array).append(transform)
		elif display_key == "bullet3":
			var visual_length: float = bullet.get("visual_length", ZAKO_LINE_BULLET_LENGTH)
			var outer_basis := _basis_with_local_scale(root_basis, Vector3(1.0, 1.0, visual_length))
			(transforms["bullet3_outer"] as Array).append(Transform3D(outer_basis, root_origin))
			var inner_basis := _basis_with_local_scale(root_basis, Vector3(1.0, 1.0, visual_length * 0.90))
			var inner_origin := root_origin + root_basis * Vector3(0.0, 0.052, 0.0)
			(transforms["bullet3_inner"] as Array).append(Transform3D(inner_basis, inner_origin))

	for key in _batch_instances:
		var multimesh := _batch_instances[key] as MultiMesh
		var batch_transforms := transforms[key] as Array
		multimesh.instance_count = batch_transforms.size()
		for index in batch_transforms.size():
			multimesh.set_instance_transform(index, batch_transforms[index])
	_batch_dirty = false


func set_game_context(game_mode: String, arcade_rank: int) -> void:
	_game_mode = game_mode
	_arcade_rank = arcade_rank


func spawn_player_shot(pos: Vector2, angle: float) -> void:
	var node := Node3D.new()
	node.name = "PlayerShot-%s" % DISPLAY_NAMES.player_shot.to_pascal_case()
	node.set_meta("display_name", DISPLAY_NAMES.player_shot)
	var shot_color: Color = _palette.get("shot", Color(0.80, 0.95, 1.0))
	node.add_child(_player_shot_wireframe(shot_color))
	node.position = _to_world(pos, 0.24)
	node.rotation.y = -angle + PI * 0.5
	add_child(node)
	bullets.append({
		"node": node,
		"pos": pos,
		"vel": Vector2.from_angle(angle) * SHOT_SPEED,
		"angle": angle,
		"shape": "capsule",
		"radius": PLAYER_SHOT_RADIUS,
		"length": PLAYER_SHOT_LENGTH,
		"life": 1.0,
		"hostile": false,
		"gum_blockable": true,
	})


func spawn_hostile_bullet(pos: Vector2, angle: float, speed := BULLET0_SPEED, gum_blockable := true, shape := "circle", life := DEFAULT_HOSTILE_BULLET_LIFETIME, length_override := 0.0) -> void:
	var node: Node3D = null
	var is_boss_b2 := shape == "boss_b2"
	if is_boss_b2:
		gum_blockable = true
	var body := MeshInstance3D.new()
	var spin_node: Node3D = null
	var bullet_visual_length := _length_for_shape(shape, length_override)
	var bullet_length := bullet_visual_length
	var bullet_visual_half_width := 0.0
	var is_bullet1 := shape == "capsule" and gum_blockable and is_equal_approx(speed, BULLET1_SPEED)
	var is_bullet2 := shape == "capsule" and gum_blockable and is_equal_approx(speed, BULLET2_SPEED)
	var is_bullet3 := shape == "line" and gum_blockable
	var is_boss_b1 := shape == "line" and not gum_blockable
	var display_key := _display_key_for_bullet(is_bullet1, is_bullet2, is_bullet3, is_boss_b1, is_boss_b2, shape, gum_blockable)
	var batched_visual := _is_batched_visual(display_key)
	if not batched_visual:
		node = Node3D.new()
		node.name = "%s-%s" % [display_key, (DISPLAY_NAMES[display_key] as String).to_pascal_case()]
		node.set_meta("display_name", DISPLAY_NAMES[display_key])
	var bullet_radius := BOSS_B2_RADIUS if is_boss_b2 else (HOSTILE_CAPSULE_BULLET_RADIUS if shape == "capsule" or shape == "line" else (HOSTILE_BULLET_RADIUS if gum_blockable else BOSS_UNBLOCKABLE_BULLET_RADIUS))
	if is_bullet1:
		bullet_visual_length = BULLET1_VISUAL_LENGTH
		bullet_visual_half_width = BULLET1_VISUAL_HALF_WIDTH
		bullet_length = BULLET1_COLLISION_LENGTH
		bullet_radius = BULLET1_COLLISION_RADIUS
		if not batched_visual:
			node.add_child(_bullet1_low_prism())
	elif is_bullet2:
		bullet_visual_length = BULLET2_VISUAL_LENGTH
		bullet_visual_half_width = BULLET2_VISUAL_HALF_WIDTH
		bullet_length = BULLET2_COLLISION_LENGTH
		bullet_radius = BULLET2_COLLISION_RADIUS
		if not batched_visual:
			node.add_child(_bullet2_low_prism())
	elif is_bullet3:
		bullet_visual_half_width = BULLET3_VISUAL_HALF_WIDTH
		bullet_radius = BULLET3_COLLISION_RADIUS
		bullet_length = maxf(0.01, bullet_visual_length - bullet_radius * 2.0)
		if not batched_visual:
			node.add_child(_bullet3_low_rail(bullet_visual_length))
	elif is_boss_b2:
		node.add_child(_boss_b2_low_wedge())
	elif is_boss_b1:
		bullet_visual_length *= BOSS_B1_INITIAL_SCALE
		bullet_visual_half_width = BOSS_B1_VISUAL_HALF_WIDTH
		bullet_radius = BOSS_B1_COLLISION_RADIUS
		bullet_length = maxf(0.01, bullet_visual_length - bullet_radius * 2.0)
		node.add_child(_boss_b1_additive_rect(bullet_visual_length))
	elif shape == "capsule" or shape == "line":
		var mesh := CylinderMesh.new()
		mesh.top_radius = HOSTILE_CAPSULE_BULLET_RADIUS
		mesh.bottom_radius = HOSTILE_CAPSULE_BULLET_RADIUS
		mesh.height = bullet_length
		mesh.radial_segments = 8
		body.mesh = mesh
		body.rotation_degrees.x = 90.0
		if shape == "line":
			body.material_override = _material(Color(0.56, 0.82, 1.0), Color(0.24, 0.58, 1.0), 1.45)
			node.add_child(_endcap_mesh(Vector2(0.0, -bullet_length * 0.5), HOSTILE_CAPSULE_BULLET_RADIUS * 0.85, Color(0.78, 0.92, 1.0)))
			node.add_child(_endcap_mesh(Vector2(0.0, bullet_length * 0.5), HOSTILE_CAPSULE_BULLET_RADIUS * 0.85, Color(0.78, 0.92, 1.0)))
	else:
		if gum_blockable:
			if not batched_visual:
				spin_node = _bullet0_rugby_spindle()
				node.add_child(spin_node)
		else:
			var mesh := SphereMesh.new()
			mesh.radius = BOSS_UNBLOCKABLE_BULLET_RADIUS
			mesh.height = mesh.radius * 2.0
			body.mesh = mesh
			var core_color: Color = (_palette.boss_unblockable as Color).lightened(0.30)
			node.add_child(_endcap_mesh(Vector2.ZERO, mesh.radius * 0.45, core_color))
	if body.mesh != null:
		if gum_blockable and shape != "circle":
			body.material_override = _material(Color(1.0, 0.50, 0.22), Color(1.0, 0.16, 0.05), 1.3)
		elif shape == "line":
			body.material_override = _material(Color(0.48, 0.72, 1.0), Color(0.18, 0.48, 1.0), 1.55)
		else:
			body.material_override = _material(_palette.boss_unblockable, _palette.boss_unblockable, 1.8)
		node.add_child(body)
	else:
		body.free()
	if shape == "circle" and not batched_visual:
		var line_color: Color = _bullet0_tail_color() if gum_blockable else _palette.boss_unblockable.lightened(0.25)
		node.add_child(_direction_line_mesh(HOSTILE_DIRECTION_LINE_LENGTH, HOSTILE_DIRECTION_LINE_WIDTH, line_color))
	if node != null:
		node.position = _to_world(pos, 0.25)
		node.rotation.y = _visual_rotation_for_bullet(angle, "boss_b2" if is_boss_b2 else "")
		add_child(node)
	bullets.append({
		"node": node,
		"visual_key": display_key,
		"batched_visual": batched_visual,
		"pos": pos,
		"vel": Vector2.from_angle(angle) * speed,
		"angle": angle,
		"shape": "capsule" if shape == "line" else ("circle" if is_boss_b2 else shape),
		"behavior": "boss_b2" if is_boss_b2 else ("boss_b1" if is_boss_b1 else ""),
		"radius": bullet_radius,
		"length": bullet_length,
		"visual_length": bullet_visual_length,
		"visual_half_width": bullet_visual_half_width,
		"base_radius": bullet_radius,
		"base_length": bullet_length,
		"base_visual_length": bullet_visual_length,
		"max_life": life,
		"age": 0.0,
		"life": life,
		"hostile": true,
		"gum_blockable": gum_blockable,
		"shot_blockable": is_boss_b2,
		"tail_light": _uses_light_bullet0_tail(),
		"spin_node": spin_node,
	})
	if batched_visual:
		_batch_dirty = true


func flush_visual_batches() -> void:
	if _batch_dirty:
		_refresh_visual_batches()


func _display_key_for_bullet(is_bullet1: bool, is_bullet2: bool, is_bullet3: bool, is_boss_b1: bool, is_boss_b2: bool, shape: String, gum_blockable: bool) -> String:
	if is_bullet1:
		return "bullet1"
	if is_bullet2:
		return "bullet2"
	if is_bullet3:
		return "bullet3"
	if is_boss_b1:
		return "boss_b1"
	if is_boss_b2:
		return "boss_b2"
	if shape == "circle":
		return "bullet0" if gum_blockable else "boss_orb"
	return "hostile_capsule"


func update_bullets(delta: float, field_w: float, field_h: float, despawn_margin: float, player_can_be_hit: bool, player_axis: Array[Vector2], enemies: Array[Dictionary]) -> bool:
	var live: Array[Dictionary] = []
	var player_hit := false
	var player_pos := (player_axis[0] + player_axis[1]) * 0.5
	for bullet in bullets:
		if bullet.get("behavior", "") == "boss_b2":
			var desired_angle := (player_pos - (bullet.pos as Vector2)).angle()
			bullet.angle = _turn_toward_angle(bullet.angle, desired_angle, BOSS_B2_HOMING_RATE * delta)
			bullet.vel = Vector2.from_angle(bullet.angle) * BOSS_B2_SPEED
		bullet.age = bullet.get("age", 0.0) + delta
		_update_boss_b1_growth(bullet)
		bullet.pos += bullet.vel * delta
		bullet.life -= delta
		var node := bullet.node as Node3D
		if node != null:
			node.position = _to_world(bullet.pos, 0.28)
			if bullet.hostile or bullet.shape == "capsule":
				node.rotation.y = _visual_rotation_for_bullet(bullet.angle, bullet.get("behavior", ""))
		elif bullet.get("batched_visual", false):
			_batch_dirty = true
		var spin_node: Node3D = bullet.get("spin_node")
		if spin_node != null:
			spin_node.rotation.y += delta * BULLET0_SPIN_SPEED

	_resolve_player_shot_hits_on_destructible_bullets()
	for bullet in bullets:
		if bullet.hostile:
			if player_can_be_hit and _hits_player(bullet, player_axis):
				bullet.life = 0.0
				player_hit = true
		else:
			if _hit_enemies_by_bullet(bullet, enemies, 1):
				bullet.life = 0.0
				hit_effect_requested.emit(bullet.pos, _palette.shot, (bullet.vel as Vector2).normalized())

		if bullet.life > 0.0 and _is_in_field_margin(bullet.pos, field_w, field_h, despawn_margin):
			live.append(bullet)
		else:
			var node := bullet.node as Node3D
			if node != null:
				node.queue_free()
			if bullet.get("batched_visual", false):
				_batch_dirty = true
	bullets = live
	if _batch_dirty:
		_refresh_visual_batches()
	return player_hit


func _resolve_player_shot_hits_on_destructible_bullets() -> void:
	for shot in bullets:
		if shot.hostile or shot.life <= 0.0:
			continue
		var shot_shape := shape_for(shot)
		for target in bullets:
			if not target.hostile or target.life <= 0.0 or not target.get("shot_blockable", false):
				continue
			if CollisionUtil.shape_overlaps_circle(shot_shape, target.pos, target.radius):
				shot.life = 0.0
				target.life = 0.0
				hit_effect_requested.emit(target.pos, _palette.shot, (shot.vel as Vector2).normalized())
				break


func clear() -> void:
	for bullet in bullets:
		var node := bullet.node as Node3D
		if node != null and is_instance_valid(node):
			node.queue_free()
	bullets.clear()
	_batch_dirty = true
	_refresh_visual_batches()


func clear_hostile() -> void:
	var player_shots: Array[Dictionary] = []
	for bullet in bullets:
		if not bullet.hostile:
			player_shots.append(bullet)
		else:
			var node := bullet.node as Node3D
			if node != null and is_instance_valid(node):
				node.queue_free()
	bullets = player_shots
	_batch_dirty = true
	_refresh_visual_batches()


func count() -> int:
	return bullets.size()


func shape_for(bullet: Dictionary) -> Dictionary:
	if bullet.shape == "capsule":
		var dir := Vector2.from_angle(bullet.angle)
		var half_length: float = bullet.length * 0.5
		return {
			"type": "capsule",
			"a": bullet.pos - dir * half_length,
			"b": bullet.pos + dir * half_length,
			"radius": bullet.radius,
		}
	return {
		"type": "circle",
		"pos": bullet.pos,
		"radius": bullet.radius,
	}


func _update_boss_b1_growth(bullet: Dictionary) -> void:
	if bullet.get("behavior", "") != "boss_b1":
		return
	var max_life: float = bullet.get("max_life", 0.0)
	var growth_t := clampf(float(bullet.get("age", 0.0)) / maxf(0.001, max_life), 0.0, 1.0)
	var scale := lerpf(1.0, BOSS_B1_GROWTH_SCALE, growth_t)
	bullet.radius = float(bullet.get("base_radius", bullet.radius)) * scale
	bullet.length = float(bullet.get("base_length", bullet.length)) * scale
	bullet.visual_length = float(bullet.get("base_visual_length", bullet.get("visual_length", 0.0))) * scale
	var visual := (bullet.node as Node3D).find_child("boss-b1-additive-rect", true, false) as Node3D
	if visual != null:
		visual.scale = Vector3(scale, scale, scale)


func show_debug_shapes(debug_root: Node, hostile_color: Color, player_color: Color) -> void:
	for bullet in bullets:
		var color := hostile_color if bullet.hostile else player_color
		var bullet_shape := shape_for(bullet)
		if bullet_shape.type == "capsule":
			debug_root.show_capsule(bullet_shape.a, bullet_shape.b, bullet_shape.radius, color)
		else:
			debug_root.show_circle(bullet_shape.pos, bullet_shape.radius, color)


func _hit_enemies_by_bullet(bullet: Dictionary, enemies: Array[Dictionary], damage: int) -> bool:
	var hit := false
	var bullet_shape := shape_for(bullet)
	for enemy in enemies:
		if not CollisionUtil.shape_overlaps_circle(bullet_shape, enemy.pos, enemy.radius):
			continue
		if enemy.get("blocks_shots", false):
			hit = true
			continue
		if enemy.get("damageable", true):
			enemy.life -= damage
			hit = true
	return hit


func _hits_player(bullet: Dictionary, player_axis: Array[Vector2]) -> bool:
	var bullet_shape := shape_for(bullet)
	if bullet_shape.type == "capsule":
		return CollisionUtil.capsules_overlap(bullet_shape.a, bullet_shape.b, bullet_shape.radius, player_axis[0], player_axis[1], PlayerUtil.HIT_RADIUS)
	return CollisionUtil.circle_overlaps_capsule(bullet_shape.pos, bullet_shape.radius, player_axis[0], player_axis[1], PlayerUtil.HIT_RADIUS)


func _is_in_field_margin(pos: Vector2, field_w: float, field_h: float, margin: float) -> bool:
	return (
		pos.x >= -field_w * 0.5 - margin
		and pos.x <= field_w * 0.5 + margin
		and pos.y >= -field_h * 0.5 - margin
		and pos.y <= field_h * 0.5 + margin
	)


func _material(albedo: Color, emission: Color, energy: float) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = albedo
	mat.emission_enabled = true
	mat.emission = emission
	mat.emission_energy_multiplier = energy
	mat.roughness = 0.42
	return mat


func _direction_line_mesh(length: float, width: float, color: Color) -> MeshInstance3D:
	var line := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius = width
	mesh.bottom_radius = width
	mesh.height = length
	mesh.radial_segments = 6
	line.mesh = mesh
	line.rotation_degrees.x = 90.0
	line.position = Vector3(0.0, 0.040, -length * 0.5)
	var material := VisualMaterialsUtil.transparent_outline(color.darkened(0.10), 0.60, 0.35)
	material.render_priority = 3
	line.material_override = material
	return line


func _player_shot_wireframe(color: Color) -> Node3D:
	var root := Node3D.new()
	root.name = "player-shot-wireframe"
	root.rotation.z = deg_to_rad(28.0)
	var half_width := 0.036
	var half_height := 0.044
	var half_length := PLAYER_SHOT_LENGTH * 0.5
	var points := PackedVector3Array([
		Vector3(0.0, half_height, -half_length),
		Vector3(half_width, 0.0, -half_length),
		Vector3(0.0, -half_height, -half_length),
		Vector3(-half_width, 0.0, -half_length),
		Vector3(0.0, half_height, half_length),
		Vector3(half_width, 0.0, half_length),
		Vector3(0.0, -half_height, half_length),
		Vector3(-half_width, 0.0, half_length),
	])
	var face_indices := PackedInt32Array([
		0, 1, 5, 0, 5, 4,
		1, 2, 6, 1, 6, 5,
		2, 3, 7, 2, 7, 6,
		3, 0, 4, 3, 4, 7,
	])
	root.add_child(_array_mesh(points, face_indices, VisualMaterialsUtil.flat_face(color.lightened(0.08), 0.24, 1.12)))
	var edge_color := color.lightened(0.10)
	for edge in [
		[0, 4], [1, 5], [2, 6], [3, 7],
		[0, 1], [1, 2], [2, 3], [3, 0],
		[4, 5], [5, 6], [6, 7], [7, 4],
	]:
		root.add_child(_edge_mesh(points[edge[0]], points[edge[1]], edge_color, 0.007))
	return root


func _bullet0_rugby_spindle() -> Node3D:
	var root := Node3D.new()
	root.name = "bullet0-rugby-spindle"
	root.scale = Vector3.ONE * BULLET0_VISUAL_SCALE
	var outer := PackedVector3Array([
		Vector3(0.0, 0.0, -0.30), Vector3(-0.10, 0.0, -0.20),
		Vector3(-0.14, 0.0, 0.0), Vector3(-0.10, 0.0, 0.20),
		Vector3(0.0, 0.0, 0.30), Vector3(0.10, 0.0, 0.20),
		Vector3(0.14, 0.0, 0.0), Vector3(0.10, 0.0, -0.20),
	])
	var inner := PackedVector3Array([
		Vector3(0.0, 0.018, -0.245), Vector3(-0.078, 0.018, -0.16),
		Vector3(-0.108, 0.018, 0.0), Vector3(-0.078, 0.018, 0.16),
		Vector3(0.0, 0.018, 0.245), Vector3(0.078, 0.018, 0.16),
		Vector3(0.108, 0.018, 0.0), Vector3(0.078, 0.018, -0.16),
	])
	root.add_child(_bullet0_polygon(outer, BULLET0_OUTER_COLOR, 0.94, 0.14, 0))
	root.add_child(_bullet0_polygon(inner, BULLET0_INNER_COLOR, 0.88, 0.58, 1))
	return root


func _bullet0_polygon(perimeter: PackedVector3Array, color: Color, alpha: float, emission: float, priority: int) -> MeshInstance3D:
	var points := PackedVector3Array([Vector3(0.0, perimeter[0].y, 0.0)])
	points.append_array(perimeter)
	var indices := PackedInt32Array()
	for index in perimeter.size():
		indices.append_array(PackedInt32Array([0, index + 1, (index + 1) % perimeter.size() + 1]))
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = points
	arrays[Mesh.ARRAY_INDEX] = indices
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	var face := MeshInstance3D.new()
	face.mesh = mesh
	var material := VisualMaterialsUtil.flat_face(color, alpha, emission)
	material.render_priority = priority
	face.material_override = material
	return face


func _bullet1_low_prism() -> Node3D:
	var root := Node3D.new()
	root.name = "bullet1-low-prism"
	var outer := PackedVector3Array([
		Vector3(-BULLET1_VISUAL_HALF_WIDTH, 0.0, -BULLET1_VISUAL_LENGTH * 0.5), Vector3(-BULLET1_VISUAL_HALF_WIDTH, 0.0, BULLET1_VISUAL_LENGTH * 0.5),
		Vector3(BULLET1_VISUAL_HALF_WIDTH, 0.0, BULLET1_VISUAL_LENGTH * 0.5), Vector3(BULLET1_VISUAL_HALF_WIDTH, 0.0, -BULLET1_VISUAL_LENGTH * 0.5),
	])
	var inner := PackedVector3Array([
		Vector3(-0.042, 0.063, -BULLET1_INNER_LENGTH * 0.5), Vector3(-0.042, 0.063, BULLET1_INNER_LENGTH * 0.5),
		Vector3(0.042, 0.063, BULLET1_INNER_LENGTH * 0.5), Vector3(0.042, 0.063, -BULLET1_INNER_LENGTH * 0.5),
	])
	root.add_child(_bullet0_polygon(outer, Color(0.72, 0.44, 0.02), 0.94, 0.12, 0))
	root.add_child(_bullet0_polygon(inner, Color(1.0, 0.84, 0.18), 0.92, 0.62, 1))
	return root


func _bullet2_low_prism() -> Node3D:
	var root := Node3D.new()
	root.name = "bullet2-low-prism"
	var outer := PackedVector3Array([
		Vector3(-BULLET2_VISUAL_HALF_WIDTH, 0.0, -BULLET2_VISUAL_LENGTH * 0.5), Vector3(-BULLET2_VISUAL_HALF_WIDTH, 0.0, BULLET2_VISUAL_LENGTH * 0.5),
		Vector3(BULLET2_VISUAL_HALF_WIDTH, 0.0, BULLET2_VISUAL_LENGTH * 0.5), Vector3(BULLET2_VISUAL_HALF_WIDTH, 0.0, -BULLET2_VISUAL_LENGTH * 0.5),
	])
	var inner := PackedVector3Array([
		Vector3(-0.034, 0.056, -0.19), Vector3(-0.034, 0.056, 0.19),
		Vector3(0.034, 0.056, 0.19), Vector3(0.034, 0.056, -0.19),
	])
	root.add_child(_bullet0_polygon(outer, Color(0.70, 0.36, 0.02), 0.94, 0.10, 0))
	root.add_child(_bullet0_polygon(inner, Color(1.0, 0.66, 0.12), 0.92, 0.55, 1))
	return root


func _bullet3_low_rail(length: float) -> Node3D:
	var root := Node3D.new()
	root.name = "bullet3-low-rail"
	var outer := MeshInstance3D.new()
	var outer_mesh := BoxMesh.new()
	outer_mesh.size = Vector3(BULLET3_VISUAL_HALF_WIDTH * 2.0, BULLET3_VISUAL_HALF_WIDTH * 2.0, length)
	outer.mesh = outer_mesh
	outer.material_override = VisualMaterialsUtil.flat_face(BULLET0_OUTER_COLOR, 0.92, 0.24)
	root.add_child(outer)
	var inner := MeshInstance3D.new()
	var inner_mesh := BoxMesh.new()
	inner_mesh.size = Vector3(0.052, 0.052, length * 0.90)
	inner.mesh = inner_mesh
	inner.position.y = 0.052
	var inner_material := VisualMaterialsUtil.flat_face(BULLET0_INNER_COLOR, 0.88, 0.58)
	inner_material.render_priority = 1
	inner.material_override = inner_material
	root.add_child(inner)
	return root


func _boss_b1_additive_rect(length: float) -> Node3D:
	var root := Node3D.new()
	root.name = "boss-b1-additive-rect"
	var face_color := Color(0.94, 0.99, 1.0)
	var edge_color := Color(0.82, 0.96, 1.0)
	var half_width := BOSS_B1_VISUAL_HALF_WIDTH
	var half_height := 0.035 * BOSS_B1_CORE_SCALE
	var points := PackedVector3Array([
		Vector3(-half_width, half_height, -length * 0.5), Vector3(half_width, half_height, -length * 0.5),
		Vector3(half_width, half_height, length * 0.5), Vector3(-half_width, half_height, length * 0.5),
		Vector3(-half_width, -half_height, -length * 0.5), Vector3(half_width, -half_height, -length * 0.5),
		Vector3(half_width, -half_height, length * 0.5), Vector3(-half_width, -half_height, length * 0.5),
	])
	var indices := PackedInt32Array([
		0, 1, 2, 0, 2, 3, 4, 6, 5, 4, 7, 6,
		0, 4, 5, 0, 5, 1, 1, 5, 6, 1, 6, 2,
		2, 6, 7, 2, 7, 3, 3, 7, 4, 3, 4, 0,
	])
	root.add_child(_array_mesh(points, indices, VisualMaterialsUtil.flat_face(face_color, 0.62, 2.85)))
	for edge in [
		[0, 1], [1, 2], [2, 3], [3, 0], [4, 5], [5, 6], [6, 7], [7, 4],
		[0, 4], [1, 5], [2, 6], [3, 7],
	]:
		root.add_child(_edge_mesh(points[edge[0]], points[edge[1]], edge_color, 0.012 * BOSS_B1_CORE_SCALE, 0.80, 2.35))
	root.add_child(_boss_b1_glow_band(length, half_width, half_height))
	return root


func _boss_b1_glow_band(length: float, half_width: float, half_height: float) -> MeshInstance3D:
	var glow_half_width := half_width * 2.15
	var glow_length := length * 1.04
	var glow_y := half_height - 0.004
	var points := PackedVector3Array([
		Vector3(-glow_half_width, glow_y, -glow_length * 0.5),
		Vector3(glow_half_width, glow_y, -glow_length * 0.5),
		Vector3(glow_half_width, glow_y, glow_length * 0.5),
		Vector3(-glow_half_width, glow_y, glow_length * 0.5),
	])
	var material := VisualMaterialsUtil.flat_face(Color(0.88, 0.98, 1.0), 0.18, 2.15)
	material.render_priority = -2
	var glow := _array_mesh(points, PackedInt32Array([0, 1, 2, 0, 2, 3]), material)
	glow.name = "boss-b1-soft-glow"
	return glow


func _boss_b2_low_wedge() -> Node3D:
	var root := Node3D.new()
	root.name = "boss-b2-homing-wedge"
	var color: Color = (_palette.zako3p as Color).lightened(0.12)
	var points := PackedVector3Array([
		Vector3(0.0, 0.14, -0.24), Vector3(-0.15, 0.0, 0.18),
		Vector3(0.15, 0.0, 0.18), Vector3(0.0, -0.11, 0.09),
	])
	var indices := PackedInt32Array([0, 1, 2, 0, 3, 1, 0, 2, 3, 1, 3, 2])
	root.add_child(_array_mesh(points, indices, VisualMaterialsUtil.flat_face(color, 0.54, 1.00)))
	for edge in [[0, 1], [1, 2], [2, 0], [0, 3], [1, 3], [2, 3]]:
		root.add_child(_edge_mesh(points[edge[0]], points[edge[1]], color.lightened(0.24), 0.012))
	return root


func _array_mesh(points: PackedVector3Array, indices: PackedInt32Array, material: Material) -> MeshInstance3D:
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = points
	arrays[Mesh.ARRAY_INDEX] = indices
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	var instance := MeshInstance3D.new()
	instance.mesh = mesh
	instance.material_override = material
	return instance


func _edge_mesh(a: Vector3, b: Vector3, color: Color, width: float, alpha := 0.72, emission := 0.72) -> MeshInstance3D:
	var edge := MeshInstance3D.new()
	var direction := b - a
	var mesh := BoxMesh.new()
	mesh.size = Vector3(width, width, direction.length())
	edge.mesh = mesh
	edge.position = (a + b) * 0.5
	edge.quaternion = Quaternion(Vector3.FORWARD, direction.normalized())
	edge.material_override = VisualMaterialsUtil.transparent_outline(color, alpha, emission)
	return edge


func _endcap_mesh(pos: Vector2, radius: float, color: Color) -> MeshInstance3D:
	var cap := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	mesh.radial_segments = 8
	mesh.rings = 4
	cap.mesh = mesh
	cap.position = _to_world(pos, 0.0)
	cap.material_override = _material(color, color, 1.2)
	return cap


func _bullet0_tail_color() -> Color:
	if _uses_light_bullet0_tail():
		return Color(220.0 / 255.0, 200.0 / 255.0, 200.0 / 255.0)
	return Color(90.0 / 255.0, 90.0 / 255.0, 90.0 / 255.0)


func _uses_light_bullet0_tail() -> bool:
	if _game_mode == "arcade" and _arcade_rank < 11:
		return true
	if _game_mode == "endless" and _arcade_rank == 15:
		return true
	return false


func _length_for_shape(shape: String, length_override: float) -> float:
	if length_override > 0.0:
		return length_override
	if shape == "capsule":
		return HOSTILE_CAPSULE_BULLET_LENGTH
	if shape == "line":
		return LINE_BULLET_LENGTH
	return 0.0


func _turn_toward_angle(current: float, target: float, max_delta: float) -> float:
	return current + clampf(angle_difference(current, target), -max_delta, max_delta)


func _visual_rotation_for_bullet(angle: float, behavior: String) -> float:
	return -angle - PI * 0.5 if behavior == "boss_b2" else -angle + PI * 0.5


func _basis_with_local_scale(basis: Basis, scale: Vector3) -> Basis:
	return basis * Basis.from_scale(scale)


func _to_world(v: Vector2, height: float) -> Vector3:
	return Vector3(v.x, height, v.y)
