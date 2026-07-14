class_name Player
extends Node3D

signal shot_requested(pos: Vector2, angle: float)

const VisualMaterialsUtil := preload("res://scripts/core/visual_materials.gd")
const VisualMotionUtil := preload("res://scripts/core/visual_motion.gd")

const SPEED := 7.5
const SHOT_COOLDOWN := 1.0 / 60.0
const RESPAWN_DELAY := 1.2
const INVULN_TIME := 2.2
const HIT_FRONT := 0.46
const HIT_BACK := 0.34
const HIT_RADIUS := 0.0375
const SHOT_OFFSET := 0.20
const VISUAL_MAX_BANK := deg_to_rad(40.0)
const VISUAL_MAX_PITCH := deg_to_rad(24.0)
const VISUAL_RESPONSE := 9.0
const VISUAL_TURN_REFERENCE := 8.0

var pos := Vector2.ZERO
var angle := 0.0
var aim_pos := Vector2.ZERO
var alive := true
var respawn_timer := 0.0
var invuln_timer := INVULN_TIME
var visual_model: Node3D

var _shot_timer := 0.0
var _palette := {}
var _previous_visual_angle := 0.0


func setup(palette: Dictionary) -> void:
	_palette = palette
	name = "Player"
	var model := Node3D.new()
	model.name = "player-armored-pods"
	visual_model = model
	_add_player_center_cannon(model, -0.02)
	for side in [-1.0, 1.0]:
		_add_box_part(model, Vector3(side * 0.34, 0.04, 0.07), Vector3(0.25, 0.15, 0.38), _palette.player.darkened(0.14))
		_add_box_part(model, Vector3(side * 0.34, 0.11, -0.10), Vector3(0.17, 0.07, 0.20), _palette.player.lightened(0.04))
		_add_edge(model, Vector3(side * 0.23, 0.12, 0.28), Vector3(side * 0.45, 0.12, 0.28), 0.014, _palette.player_core, 0.38, 0.95)
	add_child(model)

	var hit_axis_preview := _line_mesh(Vector2(0.0, -HIT_FRONT), Vector2(0.0, HIT_BACK), HIT_RADIUS * 2.0, Color(1.0, 0.88, 0.36, 0.85))
	hit_axis_preview.name = "HitAxisPreview"
	hit_axis_preview.position.y = 0.08
	add_child(hit_axis_preview)
	_sync_visual()


func update_aim(camera: Camera3D, mouse: Vector2) -> void:
	var ray_origin := camera.project_ray_origin(mouse)
	var ray_dir := camera.project_ray_normal(mouse)
	var plane := Plane(Vector3.UP, 0.0)
	var hit = plane.intersects_ray(ray_origin, ray_dir)
	if hit != null:
		aim_pos = Vector2(hit.x, hit.z)
	angle = (aim_pos - pos).angle()


func update_aim_direction(direction: Vector2) -> void:
	if direction.length_squared() <= 0.0:
		return
	var normalized_direction := direction.normalized()
	angle = normalized_direction.angle()
	aim_pos = pos + normalized_direction * 4.0


func update_life(delta: float, lives_remaining: int) -> bool:
	if invuln_timer > 0.0:
		invuln_timer = maxf(0.0, invuln_timer - delta)
	if alive:
		return false

	respawn_timer -= delta
	if respawn_timer > 0.0:
		return false
	if lives_remaining < 0:
		return true
	respawn()
	return false


func update_motion(delta: float, field_w: float, field_h: float, margin: float) -> void:
	var move := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var previous_pos := pos
	if move.length_squared() > 0.0:
		pos += move.normalized() * SPEED * delta
	pos = _clamp_to_field(pos, field_w, field_h, margin)

	_sync_visual()
	var world_motion := Vector2.ZERO
	if delta > 0.0:
		world_motion = ((pos - previous_pos) / (SPEED * delta)).limit_length(1.0)
	var turn_input := clampf(angle_difference(_previous_visual_angle, angle) / maxf(0.001, delta * VISUAL_TURN_REFERENCE), -1.0, 1.0)
	_previous_visual_angle = angle
	_update_visual_motion(world_motion, turn_input, delta)
	visible = invuln_timer <= 0.0 or int(invuln_timer * 18.0) % 2 == 0

	_shot_timer -= delta
	if Input.is_action_pressed("fire") and _shot_timer <= 0.0:
		_shot_timer = SHOT_COOLDOWN
		shot_requested.emit(pos + Vector2.from_angle(angle) * SHOT_OFFSET, angle)


func kill(remaining_lives_after_hit: int) -> bool:
	if not can_be_hit():
		return false
	alive = false
	respawn_timer = RESPAWN_DELAY if remaining_lives_after_hit >= 0 else RESPAWN_DELAY * 1.7
	invuln_timer = 0.0
	visible = false
	return true


func respawn() -> void:
	alive = true
	pos = Vector2.ZERO
	_shot_timer = 0.0
	invuln_timer = INVULN_TIME
	_reset_visual_motion()
	_sync_visual()
	visible = true


func reset() -> void:
	alive = true
	pos = Vector2.ZERO
	_shot_timer = 0.0
	invuln_timer = INVULN_TIME
	respawn_timer = 0.0
	_reset_visual_motion()
	_sync_visual()
	visible = true


func can_be_hit() -> bool:
	return alive and invuln_timer <= 0.0


func hit_axis() -> Array[Vector2]:
	var forward := Vector2.from_angle(angle)
	return [
		pos - forward * HIT_BACK,
		pos + forward * HIT_FRONT,
	]


func life_state_text() -> String:
	if not alive:
		return "respawn %.1f" % respawn_timer
	if invuln_timer > 0.0:
		return "invuln %.1f" % invuln_timer
	return "active"


func _sync_visual() -> void:
	position = _to_world(pos, 0.30)
	rotation.y = -angle - PI * 0.5


func _update_visual_motion(world_motion: Vector2, turn_input: float, delta: float) -> void:
	var local_direction := VisualMotionUtil.local_motion(self, world_motion)
	VisualMotionUtil.update_bank_pitch(
		visual_model,
		local_direction,
		turn_input,
		delta,
		VISUAL_MAX_BANK,
		VISUAL_MAX_PITCH,
		VISUAL_RESPONSE
	)


func _reset_visual_motion() -> void:
	_previous_visual_angle = angle
	if visual_model != null:
		visual_model.rotation.x = 0.0
		visual_model.rotation.z = 0.0


func _clamp_to_field(value: Vector2, field_w: float, field_h: float, margin: float) -> Vector2:
	return Vector2(
		clampf(value.x, -field_w * 0.5 + margin, field_w * 0.5 - margin),
		clampf(value.y, -field_h * 0.5 + margin, field_h * 0.5 - margin)
	)


func _add_player_center_cannon(root: Node3D, lift: float) -> void:
	_add_box_part(root, Vector3(0.0, 0.06 + lift, 0.08), Vector3(0.24, 0.14, 0.62), _palette.player)
	_add_box_part(root, Vector3(0.0, 0.14 + lift, -0.31), Vector3(0.16, 0.10, 0.34), _palette.player.lightened(0.12))
	_add_edge(root, Vector3(0.0, 0.20 + lift, -0.62), Vector3(0.0, 0.20 + lift, -0.28), 0.036, _palette.player_core, 0.70, 1.55)
	var core := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.070
	sphere.height = 0.140
	sphere.radial_segments = 8
	sphere.rings = 4
	core.mesh = sphere
	core.position = Vector3(0.0, 0.18 + lift, -0.08)
	core.material_override = _transparent_material(Color(_palette.player_core.r, _palette.player_core.g, _palette.player_core.b, 0.48), _palette.player_core, 1.55)
	root.add_child(core)


func _add_box_part(root: Node3D, center: Vector3, size: Vector3, color: Color) -> void:
	var half := size * 0.5
	var points := [
		center + Vector3(-half.x, half.y, -half.z),
		center + Vector3(half.x, half.y, -half.z),
		center + Vector3(half.x, half.y, half.z),
		center + Vector3(-half.x, half.y, half.z),
		center + Vector3(-half.x, -half.y, -half.z),
		center + Vector3(half.x, -half.y, -half.z),
		center + Vector3(half.x, -half.y, half.z),
		center + Vector3(-half.x, -half.y, half.z),
	]
	root.add_child(_array_mesh(points, PackedInt32Array([
		0, 1, 2, 0, 2, 3, 4, 6, 5, 4, 7, 6,
		0, 4, 5, 0, 5, 1, 1, 5, 6, 1, 6, 2,
		2, 6, 7, 2, 7, 3, 3, 7, 4, 3, 4, 0,
	]), VisualMaterialsUtil.flat_face(color, 0.14, 0.52)))
	for edge in [
		[0, 1], [1, 2], [2, 3], [3, 0],
		[4, 5], [5, 6], [6, 7], [7, 4],
		[0, 4], [1, 5], [2, 6], [3, 7],
	]:
		_add_edge(root, points[edge[0]], points[edge[1]], 0.014, color.lightened(0.14), 0.30, 1.20)


func _add_edge(root: Node3D, a: Vector3, b: Vector3, width: float, color: Color, alpha: float, emission: float) -> void:
	var direction := b - a
	var edge := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(width, width, direction.length())
	edge.mesh = mesh
	edge.position = (a + b) * 0.5
	edge.quaternion = Quaternion(Vector3.FORWARD, direction.normalized())
	edge.material_override = VisualMaterialsUtil.outline(color, alpha, emission)
	root.add_child(edge)


func _line_mesh(a: Vector2, b: Vector2, width: float, color: Color) -> MeshInstance3D:
	var mid := (a + b) * 0.5
	var dir := b - a
	var line := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(width, width, maxf(0.01, dir.length()))
	line.mesh = mesh
	line.position = _to_world(mid, 0.02)
	line.rotation.y = -dir.angle() + PI * 0.5
	line.material_override = _material(color, color, 0.35)
	return line


func _array_mesh(verts: PackedVector3Array, indices: PackedInt32Array, mat: Material) -> MeshInstance3D:
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = verts
	arrays[Mesh.ARRAY_INDEX] = indices
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = mat
	return mi


func _material(albedo: Color, emission: Color, energy: float) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = albedo
	mat.emission_enabled = true
	mat.emission = emission
	mat.emission_energy_multiplier = energy
	mat.roughness = 0.42
	return mat


func _transparent_material(albedo: Color, emission: Color, energy: float) -> StandardMaterial3D:
	var mat := _material(albedo, emission, energy)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	return mat


func _to_world(v: Vector2, height: float) -> Vector3:
	return Vector3(v.x, height, v.y)
