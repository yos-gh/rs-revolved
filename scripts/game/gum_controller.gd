class_name GumController
extends Node3D

signal hit_effect_requested(pos: Vector2, color: Color, impact_direction: Vector2)
signal opened
signal launched

const CollisionUtil := preload("res://scripts/core/collision.gd")

const MIN_ENERGY := 0.18
const ENEMY_RADIUS := 0.42
const BULLET_RADIUS := 0.32
const ORBIT_TARGET_RADIUS := 1.125
const ORBIT_SPEED := 13.0
const ATTACK_SPEED := 15.0
const TURN_RATE := TAU * 20.0
const CURSOR_ARRIVE_RADIUS := 0.40
const PLAYER_ARRIVE_RADIUS := 0.50
const RADIUS_CHANGE_SPEED := 4.5
const TRAIL_INTERVAL := 2.0 / 60.0
const TRAIL_LIFETIME := 13.0 / 60.0
const INPUT_BUFFER_TIME := 0.12

var state := 0
var energy := 1.0
var center := Vector2.ZERO

var _orbs: Array[Node3D] = []
var _visuals: Array[MeshInstance3D] = []
var _rotating_visuals: Array[Node3D] = []
var _angle := 0.0
var _travel_angle := 0.0
var _radius := 0.0
var _trail_timer := 0.0
var _input_buffer_timer := 0.0
var _palette := {}


func setup(palette: Dictionary) -> void:
	_palette = palette
	name = "GumController"
	for i in range(3):
		var orb := Node3D.new()
		orb.name = "GumOrb"
		_add_layered_orb_visual(orb)
		add_child(orb, true)
		_orbs.append(orb)
	visible = false


func reset(player_pos: Vector2) -> void:
	state = 0
	energy = 1.0
	center = player_pos
	_radius = 0.0
	_trail_timer = 0.0
	_input_buffer_timer = 0.0
	visible = false


func request_input() -> void:
	_input_buffer_timer = INPUT_BUFFER_TIME


func update_controller(delta: float, player_pos: Vector2, player_angle: float, aim_pos: Vector2, bullets: Array[Dictionary], enemies: Array[Dictionary], bullet_shape: Callable, launch_bounds: Rect2 = Rect2()) -> void:
	if Input.is_action_just_pressed("gum"):
		request_input()
	if _input_buffer_timer > 0.0 and _try_consume_input(player_pos, player_angle, aim_pos, launch_bounds.has_area()):
		_input_buffer_timer = 0.0
	else:
		_input_buffer_timer = maxf(0.0, _input_buffer_timer - delta)

	if state == 0:
		energy = minf(1.0, energy + delta * 0.28)
		center = player_pos
		_radius = lerpf(_radius, 0.0, minf(1.0, delta * 8.0))
	else:
		energy -= delta * 0.13
		if energy <= 0.0:
			energy = 0.0
			state = 3

	if state == 1:
		center = player_pos
		_radius = _approach(_radius, ORBIT_TARGET_RADIUS, RADIUS_CHANGE_SPEED * delta)
	elif state == 2:
		_radius = _approach(_radius, ORBIT_TARGET_RADIUS, RADIUS_CHANGE_SPEED * delta)
		if launch_bounds.has_area():
			_advance_launch_to_edge(delta, launch_bounds, aim_pos)
		else:
			_advance_launch_to_cursor(delta, aim_pos)
	elif state == 3:
		_travel_angle = _turn_toward(_travel_angle, (player_pos - center).angle(), TURN_RATE * delta)
		var to_player: Vector2 = player_pos - center
		if to_player.length() > PLAYER_ARRIVE_RADIUS:
			center += Vector2.from_angle(_travel_angle) * ATTACK_SPEED * delta
			_radius = _approach(_radius, ORBIT_TARGET_RADIUS, RADIUS_CHANGE_SPEED * delta)
		else:
			center = player_pos
			_radius = _approach(_radius, 0.0, RADIUS_CHANGE_SPEED * delta)
		if _radius <= 0.01:
			_finish_closing()

	_update_visuals(energy <= MIN_ENERGY)
	_update_rotating_visuals(delta)

	_angle += delta * ORBIT_SPEED
	visible = state != 0 or _radius > 0.05
	if state == 0:
		return

	_trail_timer -= delta
	var spawn_trail := _trail_timer <= 0.0
	if spawn_trail:
		_trail_timer += TRAIL_INTERVAL
	for i in range(_orbs.size()):
		var a := _angle + TAU * float(i) / 3.0
		var orb_pos := center + Vector2(cos(a), sin(a)) * _radius
		var orb_velocity := Vector2.from_angle(a + PI * 0.5) * ORBIT_SPEED * _radius
		if state == 2 or state == 3:
			orb_velocity += Vector2.from_angle(_travel_angle) * ATTACK_SPEED
		_orbs[i].position = _to_world(orb_pos, 0.38)
		_orbs[i].rotation.y = -a
		_hit_enemies_at(enemies, orb_pos, ENEMY_RADIUS, 3, orb_velocity.normalized())
		if spawn_trail:
			_spawn_trail(orb_pos, energy <= MIN_ENERGY)

	for bullet in bullets:
		if not bullet.hostile:
			continue
		if not bullet.gum_blockable:
			continue
		for i in range(_orbs.size()):
			if _catches_bullet(i, bullet, bullet_shape):
				bullet.life = 0.0


func state_name() -> String:
	return ["idle", "guard", "launch", "return"][min(state, 3)]


func _try_consume_input(player_pos: Vector2, player_angle: float, aim_pos: Vector2, directional_launch: bool = false) -> bool:
	if state == 0 and energy > MIN_ENERGY:
		_begin_opening(player_pos, player_angle)
		return true
	if state == 1:
		if directional_launch:
			_begin_directional_launch(player_angle)
		else:
			_begin_launch(aim_pos)
		return true
	if state == 2:
		state = 3
		return true
	if state >= 3 and energy > MIN_ENERGY:
		if directional_launch:
			_begin_directional_launch(player_angle)
		else:
			_begin_launch(aim_pos)
		return true
	return false


func _begin_opening(player_pos: Vector2, player_angle: float) -> void:
	state = 1
	center = player_pos
	_travel_angle = player_angle
	_radius = 0.0
	opened.emit()


func _begin_launch(aim_pos: Vector2) -> void:
	state = 2
	_travel_angle = (aim_pos - center).angle()
	launched.emit()


func _begin_directional_launch(direction: float) -> void:
	state = 2
	_travel_angle = direction
	launched.emit()


func _advance_launch_to_cursor(delta: float, aim_pos: Vector2) -> void:
	_travel_angle = _turn_toward(_travel_angle, (aim_pos - center).angle(), TURN_RATE * delta)
	var to_cursor: Vector2 = aim_pos - center
	if to_cursor.length() > CURSOR_ARRIVE_RADIUS:
		center += Vector2.from_angle(_travel_angle) * ATTACK_SPEED * delta
	else:
		center = aim_pos
		state = 3


func _advance_launch_to_edge(delta: float, launch_bounds: Rect2, aim_pos: Vector2) -> void:
	var to_aim := aim_pos - center
	if to_aim.length_squared() > 0.0001:
		_travel_angle = _turn_toward(_travel_angle, to_aim.angle(), TURN_RATE * delta)
	center += Vector2.from_angle(_travel_angle) * ATTACK_SPEED * delta
	if not launch_bounds.has_point(center):
		state = 3


func _finish_closing() -> void:
	state = 0
	_radius = 0.0


func debug_orb_positions() -> Array[Vector2]:
	var positions: Array[Vector2] = []
	if state == 0:
		return positions
	for orb in _orbs:
		positions.append(_from_world(orb.position))
	return positions


func duplicate_orb_visual() -> Node3D:
	if _orbs.is_empty():
		return null
	return _orbs[0].duplicate() as Node3D


func _hit_enemies_at(enemies: Array[Dictionary], pos: Vector2, radius: float, damage: int, impact_direction := Vector2.RIGHT) -> bool:
	var hit := false
	for enemy in enemies:
		if not enemy.get("gum_vulnerable", true):
			continue
		if enemy.get("damageable", true) and CollisionUtil.circle_overlaps_circle(pos, radius, enemy.pos, enemy.radius):
			enemy.life -= damage
			hit = true
	if hit:
		hit_effect_requested.emit(pos, _palette.gum, impact_direction)
	return hit


func _catches_bullet(orb_index: int, bullet: Dictionary, bullet_shape: Callable) -> bool:
	if state == 0:
		return false
	var now := _from_world(_orbs[orb_index].position)
	return CollisionUtil.shape_overlaps_circle(bullet_shape.call(bullet), now, BULLET_RADIUS)


func _update_visuals(low_energy: bool) -> void:
	for visual in _visuals:
		_apply_gum_visual_material(visual, low_energy)


func _update_rotating_visuals(delta: float) -> void:
	for visual in _rotating_visuals:
		visual.rotate_y(delta * 18.0)
		visual.rotate_x(delta * 11.0)
		visual.rotate_z(delta * 7.0)


func _spawn_trail(pos: Vector2, low_energy: bool) -> void:
	var trail := Node3D.new()
	trail.name = "GumTrail"
	var base_color: Color = _palette.gum_empty if low_energy else _palette.gum
	var mat := _material(Color(base_color.r, base_color.g, base_color.b, 0.34), base_color, 0.70)
	trail.add_child(_trail_square_mesh(0.46, mat))
	var rear_square := _trail_square_mesh(0.30, mat)
	rear_square.position = Vector3(-0.09, 0.006, 0.06)
	rear_square.rotation.y = deg_to_rad(22.0)
	trail.add_child(rear_square)
	trail.position = _to_world(pos, 0.30)
	trail.rotation.y = randf() * TAU
	trail.scale = Vector3(1.22, 0.30, 1.22)
	get_parent().add_child(trail)
	var tween := trail.create_tween()
	tween.parallel().tween_property(trail, "scale", Vector3.ZERO, TRAIL_LIFETIME)
	tween.parallel().tween_property(mat, "albedo_color", Color(base_color.r, base_color.g, base_color.b, 0.0), TRAIL_LIFETIME)
	tween.tween_callback(trail.queue_free)

func _turn_toward(current: float, target: float, max_step: float) -> float:
	return current + clampf(angle_difference(current, target), -max_step, max_step)


func _approach(current: float, target: float, step: float) -> float:
	if current < target:
		return minf(current + step, target)
	return maxf(current - step, target)


func _add_layered_orb_visual(orb: Node3D) -> void:
	var gum_color: Color = _palette.gum
	var low_color: Color = _palette.gum_low if _palette.has("gum_low") else Color(0.35, 0.42, 0.58)
	var empty_color: Color = _palette.gum_empty if _palette.has("gum_empty") else Color(1.0, 0.22, 0.16)

	var outer := _sphere_mesh(0.29, "gum-layer-outer")
	orb.add_child(outer)
	_register_gum_visual(outer, gum_color.lightened(0.22), low_color, 0.28, 0.22, 1.20, 0.62)

	var inner := _sphere_mesh(0.21, "gum-layer-inner")
	orb.add_child(inner)
	_register_gum_visual(inner, gum_color, low_color.darkened(0.12), 0.40, 0.30, 1.48, 0.86)

	var core := _sphere_mesh(0.12, "gum-layer-core")
	core.position = Vector3(0.040, 0.050, -0.025)
	orb.add_child(core)
	_register_gum_visual(core, Color(1.0, 0.86, 0.98), empty_color, 0.68, 0.48, 1.90, 1.20)

	var rotating_frame := Node3D.new()
	rotating_frame.name = "GumRotatingFrame"
	orb.add_child(rotating_frame)
	_rotating_visuals.append(rotating_frame)

	var square_points := [
		Vector3(-0.19, 0.055, -0.19),
		Vector3(0.19, 0.055, -0.19),
		Vector3(0.19, 0.055, 0.19),
		Vector3(-0.19, 0.055, 0.19),
	]
	for edge in [[0, 1], [1, 2], [2, 3], [3, 0]]:
		var line := _gum_line_mesh(square_points[edge[0]], square_points[edge[1]], 0.018, "gum-inner-square-outline")
		rotating_frame.add_child(line)
		_register_gum_visual(line, gum_color.lightened(0.36), low_color.lightened(0.18), 0.72, 0.38, 1.35, 0.74)

	var primary_ring := _ring_mesh(0.34, 0.014, "gum-shell-ring-primary")
	primary_ring.rotation = Vector3(deg_to_rad(70.0), 0.0, deg_to_rad(16.0))
	rotating_frame.add_child(primary_ring)
	_register_gum_visual(primary_ring, gum_color.lightened(0.10), low_color.lightened(0.20), 0.60, 0.30, 1.16, 0.68)

	var secondary_ring := _ring_mesh(0.26, 0.010, "gum-shell-ring-secondary")
	secondary_ring.rotation = Vector3(deg_to_rad(22.0), 0.0, deg_to_rad(-38.0))
	rotating_frame.add_child(secondary_ring)
	_register_gum_visual(secondary_ring, gum_color.lightened(0.28), low_color.lightened(0.08), 0.34, 0.24, 0.85, 0.55)

	var outer_outline := _ring_mesh(0.385, 0.012, "gum-outer-outline")
	outer_outline.rotation = Vector3(deg_to_rad(90.0), 0.0, 0.0)
	rotating_frame.add_child(outer_outline)
	_register_gum_visual(outer_outline, gum_color.lightened(0.42), low_color.lightened(0.24), 0.78, 0.40, 1.28, 0.76)


func _sphere_mesh(radius: float, mesh_name: String) -> MeshInstance3D:
	var sphere_node := MeshInstance3D.new()
	sphere_node.name = mesh_name
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	mesh.radial_segments = 8
	mesh.rings = 4
	sphere_node.mesh = mesh
	return sphere_node


func _ring_mesh(radius: float, tube: float, mesh_name: String) -> MeshInstance3D:
	var ring := MeshInstance3D.new()
	ring.name = mesh_name
	var mesh := TorusMesh.new()
	mesh.inner_radius = maxf(0.02, radius - tube)
	mesh.outer_radius = radius
	mesh.ring_segments = 16
	mesh.rings = 4
	ring.mesh = mesh
	return ring


func _trail_line_mesh(a: Vector2, b: Vector2, width: float, material: Material) -> MeshInstance3D:
	var mid := (a + b) * 0.5
	var dir := b - a
	var line := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(width, width, maxf(0.01, dir.length()))
	line.mesh = mesh
	line.position = Vector3(mid.x, 0.0, mid.y)
	line.rotation.y = -dir.angle() + PI * 0.5
	line.material_override = material
	return line


func _trail_square_mesh(size: float, material: Material) -> MeshInstance3D:
	var half := size * 0.5
	var verts := PackedVector3Array([
		Vector3(-half, 0.0, -half),
		Vector3(half, 0.0, -half),
		Vector3(half, 0.0, half),
		Vector3(-half, 0.0, half),
	])
	var indices := PackedInt32Array([0, 1, 2, 0, 2, 3])
	return _array_mesh(verts, indices, material)


func _gum_line_mesh(a: Vector3, b: Vector3, width: float, mesh_name: String) -> MeshInstance3D:
	var direction := b - a
	var line := MeshInstance3D.new()
	line.name = mesh_name
	var mesh := BoxMesh.new()
	mesh.size = Vector3(width, width, direction.length())
	line.mesh = mesh
	line.position = (a + b) * 0.5
	line.quaternion = Quaternion(Vector3.FORWARD, direction.normalized())
	return line


func _register_gum_visual(visual: MeshInstance3D, color: Color, low_color: Color, alpha: float, low_alpha: float, emission: float, low_emission: float) -> void:
	visual.set_meta("gum_color", color)
	visual.set_meta("gum_low_color", low_color)
	visual.set_meta("gum_alpha", alpha)
	visual.set_meta("gum_low_alpha", low_alpha)
	visual.set_meta("gum_emission", emission)
	visual.set_meta("gum_low_emission", low_emission)
	_visuals.append(visual)
	_apply_gum_visual_material(visual, false)


func _apply_gum_visual_material(visual: MeshInstance3D, low_energy: bool) -> void:
	var color: Color = visual.get_meta("gum_low_color") if low_energy else visual.get_meta("gum_color")
	var alpha: float = visual.get_meta("gum_low_alpha") if low_energy else visual.get_meta("gum_alpha")
	var emission: float = visual.get_meta("gum_low_emission") if low_energy else visual.get_meta("gum_emission")
	visual.material_override = _material(Color(color.r, color.g, color.b, alpha), color, emission)


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


func _material(albedo: Color, emission: Color, emission_energy: float) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = albedo
	if albedo.a < 1.0:
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.emission_enabled = true
	mat.emission = emission
	mat.emission_energy_multiplier = emission_energy
	mat.roughness = 0.42
	return mat


func _to_world(v: Vector2, height: float) -> Vector3:
	return Vector3(v.x, height, v.y)


func _from_world(v: Vector3) -> Vector2:
	return Vector2(v.x, v.z)
