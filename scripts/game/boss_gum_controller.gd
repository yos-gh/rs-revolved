class_name BossGumController
extends Node3D

signal hit_effect_requested(pos: Vector2, color: Color, direction: Vector2)

const CollisionUtil := preload("res://scripts/core/collision.gd")
const PlayerUtil := preload("res://scripts/game/player.gd")

const MAX_ORBS := 4
const ACTIVE_LIFETIME := 8.0
const INITIAL_DELAY := 0.0
const RELOAD_DELAY := 2.0
const OUTBOUND_GRACE := 0.65
const OUTBOUND_SPEED := 5.68
const RETURN_SPEED := 15.0
const HOMING_RATE := 2.05
const RETURN_RATE := TAU * 20.0
const COLLISION_RADIUS := 0.32
const CORE_ARRIVE_RADIUS := 0.36
const LAUNCH_SPREAD := deg_to_rad(22.0)
const VISUAL_HEIGHT := 0.41
const TRAIL_HEIGHT := 0.31
const TRAIL_INTERVAL := 0.055
const TRAIL_LIFETIME := 0.30
const BLUE := Color(0.10, 0.48, 1.0)
const DEPLETED_RED := Color(1.0, 0.22, 0.16)

enum OrbState {
	WAITING,
	ACTIVE,
	RETURNING,
}

var _orbs: Array[Dictionary] = []
var _desired_count := 0
var _was_exposed := false


func setup(gum_source: GumController) -> void:
	name = "BossGumController"
	for index in range(MAX_ORBS):
		var visual := gum_source.duplicate_orb_visual()
		if visual == null:
			continue
		visual.name = "BossGumOrb%d" % (index + 1)
		_prepare_visual(visual)
		visual.visible = false
		add_child(visual)
		_orbs.append({
			"visual": visual,
			"rotating": visual.find_child("GumRotatingFrame", true, false) as Node3D,
			"state": OrbState.WAITING,
			"pos": Vector2.ZERO,
			"angle": 0.0,
			"age": 0.0,
			"wait": INF,
			"offset": 0.0,
			"depleted": false,
			"trail_timer": 0.0,
		})


func reset() -> void:
	_desired_count = 0
	_was_exposed = false
	for child in get_children():
		if child.name.begins_with("BossGumTrail"):
			child.queue_free()
	for orb in _orbs:
		orb.state = OrbState.WAITING
		orb.age = 0.0
		orb.wait = INF
		orb.trail_timer = 0.0
		_set_orb_depleted(orb, false)
		(orb.visual as Node3D).visible = false


func begin_boss(count: int, core_pos: Vector2) -> void:
	reset()
	set_desired_count(count, core_pos, false)


func set_desired_count(count: int, core_pos: Vector2, core_exposed: bool) -> void:
	var previous_count := _desired_count
	_desired_count = clampi(count, 0, _orbs.size())
	for index in range(_orbs.size()):
		var orb := _orbs[index]
		orb.offset = _spread_offset(index, _desired_count)
		if index >= _desired_count:
			orb.pos = core_pos
			orb.state = OrbState.WAITING
			orb.wait = INF
			(orb.visual as Node3D).visible = false
		elif index >= previous_count:
			orb.pos = core_pos
			orb.state = OrbState.WAITING
			orb.wait = 0.0 if core_exposed else INF
			orb.age = 0.0
			orb.trail_timer = 0.0
			_set_orb_depleted(orb, false)
			(orb.visual as Node3D).visible = false
		_update_visual_transform(orb, 0.0)


func restart_cycle(core_pos: Vector2) -> void:
	if _desired_count <= 0:
		return
	_arm_initial_launches(core_pos)
	_was_exposed = true


func update_attack(
	delta: float,
	core_pos: Vector2,
	core_exposed: bool,
	player_pos: Vector2,
	player_can_be_hit: bool,
	player_axis: Array[Vector2],
	bullets: Array[Dictionary],
	bullet_shape: Callable
) -> bool:
	if _desired_count <= 0:
		_was_exposed = core_exposed
		return false
	if core_exposed and not _was_exposed:
		_arm_initial_launches(core_pos)
	_was_exposed = core_exposed
	if not core_exposed:
		return false

	var player_hit := false
	for index in range(_desired_count):
		var orb := _orbs[index]
		match int(orb.state):
			OrbState.WAITING:
				orb.pos = core_pos
				orb.wait = maxf(0.0, float(orb.wait) - delta)
				if orb.wait <= 0.0:
					_launch_orb(orb, core_pos, player_pos)
			OrbState.ACTIVE:
				_update_active_orb(orb, delta, player_pos)
				if int(orb.state) == OrbState.ACTIVE:
					if player_can_be_hit and CollisionUtil.circle_overlaps_capsule(orb.pos, COLLISION_RADIUS, player_axis[0], player_axis[1], PlayerUtil.HIT_RADIUS):
						orb.state = OrbState.RETURNING
						player_hit = true
					else:
						_block_player_shots(orb, bullets, bullet_shape)
			OrbState.RETURNING:
				_update_returning_orb(orb, delta, core_pos)
		_update_visual_transform(orb, delta)
		_update_trail(orb, delta)
	return player_hit


func active_positions() -> Array[Vector2]:
	var positions: Array[Vector2] = []
	for index in range(_desired_count):
		var orb := _orbs[index]
		if int(orb.state) == OrbState.ACTIVE:
			positions.append(orb.pos)
	return positions


static func count_for_mode(game_mode: String, arcade_boss_rank: int, difficulty_rank: int) -> int:
	if game_mode == "arcade":
		var current_rank := difficulty_rank if difficulty_rank >= 0 else arcade_boss_rank
		return clampi(floori(float(current_rank) / 5.0) - 1, 0, 2)
	if difficulty_rank <= 5:
		return 0
	if difficulty_rank <= 10:
		return 1
	if difficulty_rank <= 14:
		return 2
	if difficulty_rank <= 16:
		return 3
	return 4


func _arm_initial_launches(core_pos: Vector2) -> void:
	for index in range(_desired_count):
		var orb := _orbs[index]
		orb.state = OrbState.WAITING
		orb.pos = core_pos
		orb.age = 0.0
		orb.wait = INITIAL_DELAY
		(orb.visual as Node3D).visible = false


func _launch_orb(orb: Dictionary, core_pos: Vector2, player_pos: Vector2) -> void:
	var away_angle := (core_pos - player_pos).angle()
	orb.state = OrbState.ACTIVE
	orb.pos = core_pos
	orb.angle = away_angle + float(orb.offset)
	orb.age = 0.0
	orb.trail_timer = 0.0
	_set_orb_depleted(orb, false)
	(orb.visual as Node3D).visible = true


func _update_active_orb(orb: Dictionary, delta: float, player_pos: Vector2) -> void:
	orb.age = float(orb.age) + delta
	if orb.age >= ACTIVE_LIFETIME:
		orb.state = OrbState.RETURNING
		_set_orb_depleted(orb, true)
		return
	if orb.age >= OUTBOUND_GRACE:
		var desired_angle := (player_pos - (orb.pos as Vector2)).angle() + float(orb.offset)
		orb.angle = _turn_toward(float(orb.angle), desired_angle, HOMING_RATE * delta)
	orb.pos += Vector2.from_angle(float(orb.angle)) * OUTBOUND_SPEED * delta


func _update_returning_orb(orb: Dictionary, delta: float, core_pos: Vector2) -> void:
	var to_core := core_pos - (orb.pos as Vector2)
	if to_core.length() <= CORE_ARRIVE_RADIUS:
		orb.state = OrbState.WAITING
		orb.pos = core_pos
		orb.wait = RELOAD_DELAY
		(orb.visual as Node3D).visible = false
		return
	orb.angle = _turn_toward(float(orb.angle), to_core.angle(), RETURN_RATE * delta)
	orb.pos += Vector2.from_angle(float(orb.angle)) * minf(RETURN_SPEED * delta, to_core.length())


func _block_player_shots(orb: Dictionary, bullets: Array[Dictionary], bullet_shape: Callable) -> void:
	for shot in bullets:
		if shot.hostile or shot.life <= 0.0:
			continue
		if not CollisionUtil.shape_overlaps_circle(bullet_shape.call(shot), orb.pos, COLLISION_RADIUS):
			continue
		shot.life = 0.0
		var direction := (shot.vel as Vector2).normalized()
		hit_effect_requested.emit(orb.pos, BLUE, direction)


func _update_visual_transform(orb: Dictionary, delta: float) -> void:
	var visual := orb.visual as Node3D
	visual.position = Vector3(orb.pos.x, VISUAL_HEIGHT, orb.pos.y)
	visual.rotation.y = -float(orb.angle)
	var rotating := orb.rotating as Node3D
	if rotating != null:
		rotating.rotate_y(delta * 14.0)
		rotating.rotate_x(delta * 9.0)
		rotating.rotate_z(delta * 6.0)


func _update_trail(orb: Dictionary, delta: float) -> void:
	if int(orb.state) == OrbState.WAITING:
		return
	orb.trail_timer = float(orb.trail_timer) - delta
	if orb.trail_timer > 0.0:
		return
	orb.trail_timer = TRAIL_INTERVAL
	_spawn_trail(orb.pos, bool(orb.depleted))


func _spawn_trail(pos: Vector2, depleted: bool) -> void:
	var trail := Node3D.new()
	trail.name = "BossGumTrail"
	var base_color := DEPLETED_RED if depleted else BLUE
	var material := _trail_material(Color(base_color.r, base_color.g, base_color.b, 0.30), base_color, 0.74)
	trail.add_child(_trail_square_mesh(0.46, material))
	var rear_square := _trail_square_mesh(0.30, material)
	rear_square.position = Vector3(-0.09, 0.006, 0.06)
	rear_square.rotation.y = deg_to_rad(22.0)
	trail.add_child(rear_square)
	trail.position = Vector3(pos.x, TRAIL_HEIGHT, pos.y)
	trail.rotation.y = randf() * TAU
	trail.scale = Vector3(1.18, 0.30, 1.18)
	add_child(trail)
	var tween := trail.create_tween()
	tween.parallel().tween_property(trail, "scale", Vector3.ZERO, TRAIL_LIFETIME)
	tween.parallel().tween_property(material, "albedo_color", Color(base_color.r, base_color.g, base_color.b, 0.0), TRAIL_LIFETIME)
	tween.tween_callback(trail.queue_free)


func _trail_square_mesh(size: float, material: Material) -> MeshInstance3D:
	var half := size * 0.5
	var vertices := PackedVector3Array([
		Vector3(-half, 0.0, -half), Vector3(half, 0.0, -half),
		Vector3(half, 0.0, half), Vector3(-half, 0.0, half),
	])
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_INDEX] = PackedInt32Array([0, 1, 2, 0, 2, 3])
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	var instance := MeshInstance3D.new()
	instance.mesh = mesh
	instance.material_override = material
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	return instance


func _trail_material(albedo: Color, emission: Color, emission_energy: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = albedo
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.emission_enabled = true
	material.emission = emission
	material.emission_energy_multiplier = emission_energy
	material.render_priority = 4
	return material


func _spread_offset(index: int, count: int) -> float:
	if count <= 1:
		return 0.0
	return (float(index) - float(count - 1) * 0.5) * LAUNCH_SPREAD


func _turn_toward(current: float, target: float, max_step: float) -> float:
	return current + clampf(angle_difference(current, target), -max_step, max_step)


func _prepare_visual(root: Node3D) -> void:
	for child in root.find_children("*", "MeshInstance3D", true, false):
		var mesh := child as MeshInstance3D
		var source := mesh.material_override as StandardMaterial3D
		if source == null:
			continue
		var material := source.duplicate() as StandardMaterial3D
		mesh.set_meta("boss_gum_alpha", source.albedo_color.a)
		mesh.set_meta("boss_gum_emission", source.emission_energy_multiplier * 1.16)
		material.emission_enabled = true
		material.render_priority = 5
		mesh.material_override = material
		mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_apply_visual_color(root, false)


func _set_orb_depleted(orb: Dictionary, depleted: bool) -> void:
	if bool(orb.get("depleted", false)) == depleted:
		return
	orb.depleted = depleted
	_apply_visual_color(orb.visual as Node3D, depleted)


func _apply_visual_color(root: Node3D, depleted: bool) -> void:
	for child in root.find_children("*", "MeshInstance3D", true, false):
		var mesh := child as MeshInstance3D
		var material := mesh.material_override as StandardMaterial3D
		if material == null:
			continue
		var color := _visual_part_color(mesh.name, depleted)
		var alpha: float = mesh.get_meta("boss_gum_alpha", material.albedo_color.a)
		material.albedo_color = Color(color.r, color.g, color.b, alpha)
		material.emission = color
		material.emission_energy_multiplier = mesh.get_meta("boss_gum_emission", material.emission_energy_multiplier)


func _visual_part_color(part_name: String, depleted: bool) -> Color:
	if depleted and ("layer" in part_name or "core" in part_name):
		return DEPLETED_RED.lightened(0.34) if "core" in part_name else DEPLETED_RED
	if "core" in part_name:
		return Color(0.76, 0.90, 1.0)
	if "outer" in part_name or "ring" in part_name:
		return Color(0.28, 0.68, 1.0)
	if "square" in part_name:
		return Color(0.42, 0.80, 1.0)
	return BLUE
