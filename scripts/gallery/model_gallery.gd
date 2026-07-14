class_name ModelGallery
extends Node3D

const VisualMaterialsUtil := preload("res://scripts/core/visual_materials.gd")

const ZAKO0_COLOR := Color(0.96, 0.28, 0.35)
const ZAKO1_COLOR := Color(1.00, 0.62, 0.12)
const ZAKO2_COLOR := Color(0.96, 0.12, 0.60)
const ZAKO3_COLOR := Color(0.96, 0.16, 0.30)
const ZAKO3P_COLOR := Color(1.00, 0.66, 0.12)
const ZAKO4_COLOR := Color(0.96, 0.12, 0.60)
const ZAKO5_COLOR := Color(0.96, 0.12, 0.60)
const ZAKO6_COLOR := Color(0.96, 0.12, 0.60)
const ZAKO7_COLOR := Color(0.95, 0.38, 1.00)
const ZAKO7P_COLOR := Color(1.00, 0.66, 0.12)
const ZAKOM0_COLOR := Color(0.90, 0.92, 0.96)
const ZAKOM1_COLOR := Color(1.00, 0.66, 0.12)
const BULLET0_COLOR := Color(0.88, 0.08, 0.42)
const BULLET0_BALANCED_OUTER_COLOR := Color(0.77, 0.04, 0.28)
const BULLET0_BALANCED_INNER_COLOR := Color(0.97, 0.12, 0.40)
const BULLET0_BALANCED_TAIL_COLOR := Color(1.0, 0.22, 0.30)
const BULLET1_COLOR := Color(1.00, 0.82, 0.12)
const BULLET2_COLOR := Color(1.00, 0.60, 0.10)
const BULLET3_COLOR := BULLET0_COLOR
const PLAYER_SHOT_COLOR := Color(0.80, 0.95, 1.00)
const MOUSE_TARGET_COLOR := Color(1.00, 0.86, 0.35)
const GUM_COLOR := Color(0.96, 0.42, 0.78)
const GUM_LOW_COLOR := Color(0.35, 0.42, 0.58)
const PLAYER_COLOR := Color(0.32, 0.95, 0.86)
const PLAYER_CORE_COLOR := Color(1.00, 0.86, 0.35)
const BOSS_B1_COLOR := Color(0.78, 0.96, 1.0)
const BOSS_B1_EDGE_COLOR := Color(0.28, 0.68, 0.70)
const BOSS_CORE_COLOR := Color(0.30, 0.92, 1.00)
const BOSS_T1_COLOR := Color(0.24, 0.86, 1.00)
const BOSS_T1_GUN_COLOR := Color(1.00, 0.70, 0.20)
const BOSS_CAGED_CORE_OUTLINE_WIDTH := 0.040
const BOSS_CAGED_PRIMARY_RING_WIDTH := 0.032
const BOSS_CAGED_SECONDARY_RING_WIDTH := 0.065
const BOSS_T_SLOW_GUN_EDGE_WIDTH := 0.015
const ZAKO4_OUTLINE_WIDTH := 0.009
const ZAKO6_OUTER_OUTLINE_WIDTH := 0.014
const ZAKO1_CROSS_SECTION_RADIUS := 0.28
const ZAKOM1_OUTLINE_WIDTH := 0.016
const ZAKOM1_RIDGE_WIDTH := 0.019
const CATEGORY_NAMES := ["Crimson Glider / zako0", "Amber Drifter / zako1", "Verdant Fan / zako2", "Rugby Spindle / bullet0", "Lattice Keep / zakoM0", "Amber Bolt / bullet1", "Split Pod / zako3", "Hatch Wedge / zako3p", "Diamond Battery / zako4", "Orange Prism / bullet2", "Armored Ray / zako5", "Ridged Comet / zakoM1", "Orbit Wisp / zako6", "Viper Glider / zako7", "Chain Crystal / zako7p", "Low Rail / bullet3", "Piercing Light / Boss_b1", "Caged Core / Boss_Core", "Citadel Turrets / Boss_T", "Wire Diamond / myshot", "Corner Sweep / Mousetarget", "Layered Orb / Gum", "Armored Pods / Mychar", "Tether Ribbons / Boss_Link", "Player Capture / Icon"]
const CANDIDATE_NAMES := [
	["A  TRANSPARENT MIX", "B  SOFT ADD", "C  FAINT GLOW"],
	["A  FACETED WEDGE", "B  LOW PRISM", "C  RIDGED DIAMOND"],
	["A  FOUR TILES", "B  PINWHEEL TILES", "C  FAN BLOCKS"],
	["A  CURRENT MAGENTA", "B  BALANCED RED", "C  SATURATED RED"],
	["A  PREVIOUS STEPPED", "B  INNER CITADEL", "C  ADOPTED LATTICE"],
	["A  OUTLINED BAR", "B  TAPERED BOLT", "C  LOW PRISM"],
	["A  FLAT HATCH", "B  RAISED SHELL", "C  SPLIT POD"],
	["A  FLAT SHARD", "B  LOW WEDGE", "C  SHARD PRISM"],
	["A  SQUARE BATTERY", "B  DIAMOND BATTERY", "C  STEPPED BATTERY"],
	["A  SHORT BAR", "B  LOW PRISM", "C  TAPERED BAR"],
	["A  FLAT RAY", "B  DIHEDRAL RAY", "C  ARMORED RAY"],
	["A  HEX CRYSTAL", "B  TALL CRYSTAL", "C  RIDGED CRYSTAL"],
	["A  ALIGNED ORBITS", "B  CROSSED ORBITS", "C  TILTED ORBITS"],
	["A  V-GLIDER", "B  DEEP V-GLIDER", "C  RIDGED V-GLIDER"],
	["A  MINI CRYSTAL", "B  FLAT LINK", "C  RIDGED LINK"],
	["A  DARK DASH", "B  FAINT GLOW DASH", "C  LOW RAIL"],
	["A  PALE RECT", "B  ADDITIVE RECT", "C  DARK EDGE RECT"],
	["A  GAPPED ORBITS", "B  CAGED CORE", "C  SATURN BANDS"],
	["T1  RAPID RAIL", "T2  OPPOSING FRAME", "T3  BURST TRIAD"],
	["A  WIRE DIAMOND", "B  CORE LANCE", "C  OPEN SPARK"],
	["A  CORNER SWEEP", "B  CROSS RING", "C  DUAL BRACKET"],
	["A  LAYERED ORB", "B  SHELL RINGS", "C  LOW-ENERGY CORE"],
	["A  CANNON WHEELS", "B  BOOSTER SHIP", "C  ARMORED PODS"],
	["A  SINUOUS RIBBON", "B  NODE TETHER", "C  HIGH ARCH"],
	["DRAG  ROTATE"],
]

var gallery_layer: CanvasLayer
var candidate_roots: Array[Node3D] = []
var category_roots: Array[Node3D] = []
var heading_label: Label
var candidate_label: Label
var category_index := 0
var adopted_builders: Dictionary = {}
var drag_rotating := false
var last_drag_position := Vector2.ZERO


func set_adopted_builders(builders: Dictionary) -> void:
	adopted_builders = builders.duplicate()


func _ready() -> void:
	_build_categories()
	_build_labels()
	_show_category(0)
	visible = false
	gallery_layer.visible = false


func set_active(value: bool) -> void:
	visible = value
	gallery_layer.visible = value


func update_gallery(delta: float) -> void:
	for index in candidate_roots.size():
		var root := candidate_roots[index]
		if root.has_meta("manual_gallery_rotation"):
			continue
		var diagonal_axis := Vector3(0.30 + index * 0.05, 1.0, 0.18).normalized()
		root.rotate(diagonal_axis, delta * (0.36 + index * 0.08))
	for ring in find_children("boss-core-ring-cw*", "Node3D", true, false):
		ring.rotate_y(delta * 1.05)
	for ring in find_children("boss-core-ring-ccw*", "Node3D", true, false):
		ring.rotate_y(-delta * 1.75)
	for orbit in find_children("boss-core-gun-orbit", "Node3D", true, false):
		orbit.rotate_y(delta * 0.55)
	for sweep in find_children("mousetarget-visibility-sweep", "Node3D", true, false):
		sweep.rotate_y(delta * 8.0)


func candidate_count() -> int:
	return candidate_roots.size()


func category_count() -> int:
	return category_roots.size()


func change_category(direction: int) -> void:
	_show_category(posmod(category_index + direction, category_roots.size()))


func wants_clean_background() -> bool:
	return visible and category_index == 24


func _unhandled_input(event: InputEvent) -> void:
	if not visible or not wants_clean_background():
		return
	var button := event as InputEventMouseButton
	if button != null and button.button_index == MOUSE_BUTTON_LEFT:
		drag_rotating = button.pressed
		last_drag_position = button.position
		if button.pressed:
			get_viewport().set_input_as_handled()
		return
	var motion := event as InputEventMouseMotion
	if motion != null and drag_rotating:
		var delta := motion.position - last_drag_position
		last_drag_position = motion.position
		for root in candidate_roots:
			root.rotate_y(delta.x * 0.010)
			root.rotate_object_local(Vector3.RIGHT, delta.y * 0.010)
		get_viewport().set_input_as_handled()


func _build_categories() -> void:
	var category_builders: Array = [
		[_build_zako0_transparent_mix, _build_zako0_soft_add, _build_zako0_faint_glow],
		[_build_zako1_thin_wedge, _build_zako1_low_prism, _build_zako1_ridged_diamond],
		[_build_zako2_four_tiles, _build_zako2_pinwheel_tiles, _build_zako2_fan_blocks],
		[_build_bullet0_rugby_outline, _build_bullet0_slender_outline, _build_bullet0_no_outline],
		[_build_zakom0_stepped_wall, _build_zakom0_inner_citadel, _build_zakom0_lattice_keep],
		[_build_bullet1_outlined_bar, _build_bullet1_tapered_bolt, _build_bullet1_low_prism],
		[_build_zako3_flat_hatch, _build_zako3_raised_shell, _build_zako3_split_pod],
		[_build_zako3p_flat_shard, _build_zako3p_low_wedge, _build_zako3p_shard_prism],
		[_build_zako4_square_battery, _build_zako4_diamond_battery, _build_zako4_stepped_battery],
		[_build_bullet2_short_bar, _build_bullet2_low_prism, _build_bullet2_tapered_bar],
		[_build_zako5_flat_ray, _build_zako5_dihedral_ray, _build_zako5_armored_ray],
		[_build_zakom1_low_tank, _build_zakom1_heavy_shell, _build_zakom1_ridged_tank],
		[_build_zako6_orbit_cores, _build_zako6_caged_cores, _build_zako6_offset_globes],
		[_build_zako7_forked_glider, _build_zako7_manta_head, _build_zako7_barbed_ray],
		[_build_zako7p_mini_crystal, _build_zako7p_flat_link, _build_zako7p_ridged_link],
		[_build_bullet3_dark_dash, _build_bullet3_faint_glow_dash, _build_bullet3_low_rail],
		[_build_boss_b1_original_capsule, _build_boss_b1_low_column, _build_boss_b1_faceted_beam],
		[_build_boss_core_gapped_orbits, _build_boss_core_complete_orbits, _build_boss_core_saturn_bands],
		[_build_boss_t1_stepped_citadel, _build_boss_t2_stepped_citadel, _build_boss_t3_stepped_citadel],
		[_build_myshot_wire_diamond, _build_myshot_core_lance, _build_myshot_open_spark],
		[_build_mousetarget_corner_sweep, _build_mousetarget_cross_ring, _build_mousetarget_dual_bracket],
		[_build_gum_layered_orb, _build_gum_shell_rings, _build_gum_low_energy_core],
		[_build_mychar_cannon_wheels, _build_mychar_booster_ship, _build_mychar_armored_pods],
		[_build_boss_link_sinuous_ribbon, _build_boss_link_node_tether, _build_boss_link_high_arch],
		[_build_player_capture_model],
	]
	for category in category_builders.size():
		var category_root := Node3D.new()
		category_root.name = CATEGORY_NAMES[category].replace(" / ", "-").replace(" ", "_")
		add_child(category_root)
		category_roots.append(category_root)
		for index in category_builders[category].size():
			var root := Node3D.new()
			root.name = CANDIDATE_NAMES[category][index].replace("  ", "_")
			root.position = Vector3(0.0, 1.2, 0.0) if category == 24 else Vector3((index - 1) * 4.2, 0.55, 0.0)
			root.scale = Vector3.ONE * _category_scale(category)
			root.rotation = Vector3.ZERO if category == 24 else Vector3(deg_to_rad(-8.0 + index * 8.0), 0.0, deg_to_rad(7.0 - index * 7.0))
			if category == 24:
				root.set_meta("manual_gallery_rotation", true)
			category_root.add_child(root)
			var builder: Callable = adopted_builders.get("%d:%d" % [category, index], category_builders[category][index])
			builder.call(root)


func _category_scale(category: int) -> float:
	if category == 3:
		return 2.7
	if category == 4:
		return 0.82
	if category == 5:
		return 2.2
	if category == 7:
		return 2.8
	if category == 9:
		return 2.8
	if category == 11:
		return 0.78
	if category == 12:
		return 1.7
	if category == 14:
		return 2.0
	if category == 15:
		return 1.45
	if category == 16:
		return 2.6
	if category == 17:
		return 0.82
	if category == 18:
		return 0.72
	if category == 19:
		return 3.1
	if category == 20:
		return 2.4
	if category == 21:
		return 2.4
	if category == 22:
		return 1.6
	if category == 23:
		return 0.85
	if category == 24:
		return 4.0
	return 1.0


func _build_labels() -> void:
	gallery_layer = CanvasLayer.new()
	gallery_layer.name = "ModelGalleryUI"
	gallery_layer.layer = 12
	add_child(gallery_layer)

	heading_label = Label.new()
	heading_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	heading_label.anchor_left = 0.0
	heading_label.anchor_top = 0.055
	heading_label.anchor_right = 1.0
	heading_label.anchor_bottom = 0.14
	heading_label.add_theme_color_override("font_color", Color(0.82, 0.95, 0.92))
	heading_label.add_theme_font_size_override("font_size", 28)
	gallery_layer.add_child(heading_label)

	candidate_label = Label.new()
	candidate_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	candidate_label.anchor_left = 0.0
	candidate_label.anchor_top = 0.74
	candidate_label.anchor_right = 1.0
	candidate_label.anchor_bottom = 0.84
	candidate_label.add_theme_color_override("font_color", Color(1.0, 0.72, 0.76))
	candidate_label.add_theme_font_size_override("font_size", 19)
	gallery_layer.add_child(candidate_label)

	var help := Label.new()
	help.text = "A / D or Left / Right: change model     Drag: rotate capture model     G or Esc: return to title"
	help.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	help.anchor_left = 0.0
	help.anchor_top = 0.89
	help.anchor_right = 1.0
	help.anchor_bottom = 0.96
	help.add_theme_color_override("font_color", Color(0.62, 0.76, 0.76))
	help.add_theme_font_size_override("font_size", 15)
	gallery_layer.add_child(help)


func _show_category(index: int) -> void:
	category_index = index
	for root_index in category_roots.size():
		category_roots[root_index].visible = root_index == category_index
	candidate_roots.clear()
	for child in category_roots[category_index].get_children():
		candidate_roots.append(child)
	if heading_label != null:
		heading_label.text = "MODEL GALLERY  /  %s  (%d/%d)" % [CATEGORY_NAMES[category_index], category_index + 1, category_roots.size()]
	if candidate_label != null:
		candidate_label.text = "                         ".join(CANDIDATE_NAMES[category_index])


func _build_zako0_transparent_mix(root: Node3D) -> void:
	_build_zako0_outline_sample(root, 0.012, 0.58, 0.55, false)


func _build_zako0_soft_add(root: Node3D) -> void:
	_build_zako0_outline_sample(root, 0.014, 0.42, 0.70, true)


func _build_zako0_faint_glow(root: Node3D) -> void:
	_build_zako0_outline_sample(root, 0.012, 0.26, 1.15, true)


func _build_zako0_outline_sample(root: Node3D, line_width: float, line_alpha: float, emission: float, additive: bool) -> void:
	var nose := Vector3(0.0, 0.08, -0.52)
	var left_tip := Vector3(-0.53, 0.21, 0.31)
	var left_tail := Vector3(-0.10, 0.10, -0.05)
	var right_tip := Vector3(0.53, 0.21, 0.31)
	var right_tail := Vector3(0.10, 0.10, -0.05)
	_add_styled_wing(root, nose, left_tip, left_tail, line_width, line_alpha, emission, additive)
	_add_styled_wing(root, nose, right_tip, right_tail, line_width, line_alpha, emission, additive)
	_add_styled_glider_body(root, nose, line_width, line_alpha, emission, additive)


func _build_zako1_thin_wedge(root: Node3D) -> void:
	var points := [
		Vector3(0.0, 0.0, -0.48), Vector3(-ZAKO1_CROSS_SECTION_RADIUS, 0.0, 0.0),
		Vector3(0.0, 0.0, 0.48), Vector3(ZAKO1_CROSS_SECTION_RADIUS, 0.0, 0.0),
		Vector3(0.0, ZAKO1_CROSS_SECTION_RADIUS, -0.04), Vector3(0.0, -ZAKO1_CROSS_SECTION_RADIUS, 0.04),
	]
	_add_zako1_model(root, points, [
		4, 0, 1, 4, 1, 2, 4, 2, 3, 4, 3, 0,
		5, 1, 0, 5, 2, 1, 5, 3, 2, 5, 0, 3,
	], [[0, 1], [1, 2], [2, 3], [3, 0], [0, 4], [1, 4], [2, 4], [3, 4], [0, 5], [1, 5], [2, 5], [3, 5]])


func _build_zako1_low_prism(root: Node3D) -> void:
	var points := [
		Vector3(0.0, 0.07, -0.48), Vector3(-0.28, 0.07, 0.0),
		Vector3(0.0, 0.07, 0.48), Vector3(0.28, 0.07, 0.0),
		Vector3(0.0, -0.07, -0.48), Vector3(-0.28, -0.07, 0.0),
		Vector3(0.0, -0.07, 0.48), Vector3(0.28, -0.07, 0.0),
	]
	_add_zako1_model(root, points, [
		0, 1, 2, 0, 2, 3, 4, 6, 5, 4, 7, 6,
		0, 4, 5, 0, 5, 1, 1, 5, 6, 1, 6, 2,
		2, 6, 7, 2, 7, 3, 3, 7, 4, 3, 4, 0,
	], [[0, 1], [1, 2], [2, 3], [3, 0], [4, 5], [5, 6], [6, 7], [7, 4], [0, 4], [2, 6]])


func _build_zako1_ridged_diamond(root: Node3D) -> void:
	var points := [
		Vector3(0.0, 0.02, -0.48), Vector3(-0.28, 0.02, 0.0),
		Vector3(0.0, 0.02, 0.48), Vector3(0.28, 0.02, 0.0),
		Vector3(0.0, 0.14, 0.0), Vector3(0.0, -0.05, 0.0),
	]
	_add_zako1_model(root, points, [
		0, 1, 4, 1, 2, 4, 2, 3, 4, 3, 0, 4,
		0, 5, 1, 1, 5, 2, 2, 5, 3, 3, 5, 0,
	], [[0, 1], [1, 2], [2, 3], [3, 0], [0, 4], [2, 4], [0, 5], [2, 5]])


func _add_zako1_model(root: Node3D, points: Array, indices: Array, edges: Array) -> void:
	_add_face(root, points, indices, ZAKO1_COLOR)
	for edge in edges:
		_add_styled_edge(root, points[edge[0]], points[edge[1]], 0.012, ZAKO1_COLOR, 0.26, 1.15, true)


func _build_zako2_four_tiles(root: Node3D) -> void:
	for x in [-0.27, 0.27]:
		for z in [-0.27, 0.27]:
			_add_square_plate(root, Vector3(x, 0.0, z), 0.43, 0.055, 0.0)


func _build_zako2_pinwheel_tiles(root: Node3D) -> void:
	var centers := [
		Vector3(-0.27, 0.0, -0.27), Vector3(0.27, 0.0, -0.27),
		Vector3(0.27, 0.0, 0.27), Vector3(-0.27, 0.0, 0.27),
	]
	for index in centers.size():
		_add_square_plate(root, centers[index], 0.43, 0.06, deg_to_rad(10.0 + index * 4.0), deg_to_rad(-8.0 + index * 5.0))


func _build_zako2_fan_blocks(root: Node3D) -> void:
	var centers := [
		Vector3(-0.27, 0.0, -0.27), Vector3(0.27, 0.0, -0.27),
		Vector3(0.27, 0.0, 0.27), Vector3(-0.27, 0.0, 0.27),
	]
	for center in centers:
		_add_zako2_pitched_plate(root, center)
	var hub_points := [
		Vector3(0.0, 0.10, 0.0), Vector3(-0.10, 0.0, 0.0),
		Vector3(0.0, 0.0, -0.10), Vector3(0.10, 0.0, 0.0),
		Vector3(0.0, 0.0, 0.10), Vector3(0.0, -0.10, 0.0),
	]
	_add_dense_polyhedron(root, hub_points, [
		0, 1, 2, 0, 2, 3, 0, 3, 4, 0, 4, 1,
		5, 2, 1, 5, 3, 2, 5, 4, 3, 5, 1, 4,
	], [[1, 2], [2, 3], [3, 4], [4, 1]], ZAKO2_COLOR)


func _add_zako2_pitched_plate(root: Node3D, center: Vector3) -> void:
	var plate := Node3D.new()
	plate.position = center
	root.add_child(plate)
	var half_size := 0.21
	var half_height := 0.01
	var radial := Vector2(center.x, center.z).normalized()
	var tangent := Vector2(-radial.y, radial.x)
	var corners := [
		Vector2(-half_size, -half_size), Vector2(half_size, -half_size),
		Vector2(half_size, half_size), Vector2(-half_size, half_size),
	]
	var points := []
	for thickness_sign in [1.0, -1.0]:
		for corner in corners:
			var corner_2d := corner as Vector2
			var blade_height: float = corner_2d.dot(tangent) * tan(deg_to_rad(13.0))
			points.append(Vector3(corner_2d.x, blade_height + half_height * thickness_sign, corner_2d.y))
	_add_face(plate, points, [
		0, 1, 2, 0, 2, 3, 4, 6, 5, 4, 7, 6,
		0, 4, 5, 0, 5, 1, 1, 5, 6, 1, 6, 2,
		2, 6, 7, 2, 7, 3, 3, 7, 4, 3, 4, 0,
	], ZAKO2_COLOR)
	for edge in [
		[0, 1], [1, 2], [2, 3], [3, 0],
		[4, 5], [5, 6], [6, 7], [7, 4],
		[0, 4], [1, 5], [2, 6], [3, 7],
	]:
		_add_styled_edge(plate, points[edge[0]], points[edge[1]], 0.012, ZAKO2_COLOR.lightened(0.10), 0.26, 1.15, true)


func _build_bullet0_rugby_outline(root: Node3D) -> void:
	_build_bullet0_spindle_sample(root, BULLET0_COLOR.darkened(0.22), BULLET0_COLOR.lightened(0.08), BULLET0_COLOR.lightened(0.20), 0.14, 0.58)


func _build_bullet0_slender_outline(root: Node3D) -> void:
	_build_bullet0_spindle_sample(root, BULLET0_BALANCED_OUTER_COLOR, BULLET0_BALANCED_INNER_COLOR, BULLET0_BALANCED_TAIL_COLOR, 0.18, 0.66)


func _build_bullet0_no_outline(root: Node3D) -> void:
	_build_bullet0_spindle_sample(root, Color(0.84, 0.015, 0.22), Color(1.0, 0.12, 0.30), Color(1.0, 0.25, 0.32), 0.20, 0.72)


func _build_bullet0_spindle_sample(root: Node3D, outer_color: Color, inner_color: Color, tail_color: Color, outer_emission: float, inner_emission: float) -> void:
	var outer := _bullet0_spindle_points(0.30, 0.14, 0.0)
	var inner := _bullet0_spindle_points(0.30 * 0.82, 0.14 * 0.78, 0.018)
	_add_gallery_bullet_polygon(root, outer, outer_color, 0.94, outer_emission, 0)
	_add_gallery_bullet_polygon(root, inner, inner_color, 0.88, inner_emission, 1)
	_add_bullet0_tail(root, Vector3(0.0, 0.04, 0.0), Vector3(0.0, 0.04, 1.08), tail_color)


func _bullet0_spindle_points(half_length: float, half_width: float, height: float) -> Array:
	return [
		Vector3(0.0, height, -half_length), Vector3(-half_width * 0.72, height, -half_length * 0.67),
		Vector3(-half_width, height, 0.0), Vector3(-half_width * 0.72, height, half_length * 0.67),
		Vector3(0.0, height, half_length), Vector3(half_width * 0.72, height, half_length * 0.67),
		Vector3(half_width, height, 0.0), Vector3(half_width * 0.72, height, -half_length * 0.67),
	]


func _build_zakom0_low_wall(root: Node3D) -> void:
	_add_zakom0_wall_frame(root, 0.22, false)


func _build_zakom0_raised_wall(root: Node3D) -> void:
	_add_zakom0_wall_frame(root, 0.40, false)


func _build_zakom0_stepped_wall(root: Node3D) -> void:
	_add_zakom0_wall_frame(root, 0.34, true)


func _build_zakom0_inner_citadel(root: Node3D) -> void:
	var citadel := Node3D.new()
	citadel.name = "zakoM0-inner-citadel"
	root.add_child(citadel)
	_add_zakom0_wall_frame(citadel, 0.30, true, 1.58, 0.78)
	var diamond := [
		Vector3(0.0, 0.48, -0.62), Vector3(0.62, 0.48, 0.0),
		Vector3(0.0, 0.48, 0.62), Vector3(-0.62, 0.48, 0.0),
	]
	for index in range(4):
		_add_styled_edge(citadel, diamond[index], diamond[(index + 1) % 4], 0.024, ZAKOM0_COLOR.lightened(0.18), 0.48, 1.45, true)
		_add_styled_edge(citadel, diamond[index], Vector3(diamond[index].x * 0.48, 0.16, diamond[index].z * 0.48), 0.016, ZAKOM0_COLOR.lightened(0.08), 0.34, 1.15, true)
	_add_box_part(citadel, Vector3(0.0, 0.29, 0.0), Vector3(0.34, 0.30, 0.34), ZAKOM0_COLOR.darkened(0.05), 0.22, 0.36, 1.25)


func _build_zakom0_lattice_keep(root: Node3D) -> void:
	var keep := Node3D.new()
	keep.name = "zakoM0-lattice-keep"
	root.add_child(keep)
	_add_zakom0_wall_frame(keep, 0.24, false, 1.54, 0.78)
	var half := 0.69
	var lower_y := 0.16
	var upper_y := 0.43
	for side_x in [-1.0, 1.0]:
		for side_z in [-1.0, 1.0]:
			_add_box_part(keep, Vector3(side_x * half, 0.30, side_z * half), Vector3(0.13, 0.44, 0.13), ZAKOM0_COLOR.lightened(0.04), 0.20, 0.34, 1.18)
	for diagonal in [-1.0, 1.0]:
		_add_styled_edge(keep, Vector3(-half, lower_y, -half * diagonal), Vector3(half, upper_y, half * diagonal), 0.028, ZAKOM0_COLOR.lightened(0.16), 50.0 / 255.0, 1.38, true)
		_add_styled_edge(keep, Vector3(-half, upper_y, -half * diagonal), Vector3(half, lower_y, half * diagonal), 0.018, ZAKOM0_COLOR.lightened(0.04), 50.0 / 255.0, 1.08, true)
	_add_zakom0_crystal_plate(keep, 0, 1.08, 0.17, 0.18, 0.35)
	_add_zakom0_crystal_plate(keep, 1, 0.76, 0.25, 0.23, 0.46)
	_add_zakom0_crystal_plate(keep, 2, 0.44, 0.33, 0.30, 0.60)


func _add_zakom0_crystal_plate(root: Node3D, index: int, extent: float, height: float, alpha: float, emission: float) -> void:
	var plate := Node3D.new()
	plate.name = "zakoM0-crystal-plate-%d" % index
	plate.position.y = height
	root.add_child(plate)
	var half := extent * 0.5
	_add_face(plate, [
		Vector3(-half, 0.0, -half), Vector3(half, 0.0, -half),
		Vector3(half, 0.0, half), Vector3(-half, 0.0, half),
	], [0, 1, 2, 0, 2, 3], ZAKOM0_COLOR.lightened(0.03), alpha, emission)


func _add_zakom0_wall_frame(root: Node3D, wall_height: float, stepped: bool, extent := 1.80, gun_spread := 1.0) -> void:
	var wall_width := 0.15
	var half := extent * 0.5
	for part in [
		[Vector3(0.0, 0.0, -half), Vector3(extent, wall_height, wall_width)],
		[Vector3(0.0, 0.0, half), Vector3(extent, wall_height, wall_width)],
		[Vector3(-half, 0.0, 0.0), Vector3(wall_width, wall_height, extent)],
		[Vector3(half, 0.0, 0.0), Vector3(wall_width, wall_height, extent)],
	]:
		_add_box_part(root, part[0], part[1], ZAKOM0_COLOR)
	if stepped:
		var upper_extent := extent * 0.82
		var upper_half := upper_extent * 0.5
		var upper_y := wall_height * 0.5 + 0.07
		for part in [
			[Vector3(0.0, upper_y, -upper_half), Vector3(upper_extent, 0.14, 0.07)],
			[Vector3(0.0, upper_y, upper_half), Vector3(upper_extent, 0.14, 0.07)],
			[Vector3(-upper_half, upper_y, 0.0), Vector3(0.07, 0.14, upper_extent)],
			[Vector3(upper_half, upper_y, 0.0), Vector3(0.07, 0.14, upper_extent)],
		]:
			_add_box_part(root, part[0], part[1], ZAKOM0_COLOR.lightened(0.08))
	_add_zakom0_gallery_guns(root, wall_height * 0.5 + 0.10, gun_spread)


func _add_zakom0_gallery_guns(root: Node3D, gun_height: float, spread := 1.0) -> void:
	var gun0 := Node3D.new()
	gun0.position = Vector3(-1.08, gun_height, 0.32) * Vector3(spread, 1.0, spread)
	root.add_child(gun0)
	for part in [
		[Vector3(0.0, 0.0, -0.25), Vector3(0.50, 0.055, 0.065)],
		[Vector3(0.0, 0.0, 0.25), Vector3(0.50, 0.055, 0.065)],
		[Vector3(-0.25, 0.0, 0.0), Vector3(0.065, 0.055, 0.50)],
		[Vector3(0.25, 0.0, 0.0), Vector3(0.065, 0.055, 0.50)],
	]:
		_add_box_part(gun0, part[0], part[1], ZAKOM0_COLOR.lightened(0.10))
	var gun1 := Node3D.new()
	gun1.position = Vector3(0.98, gun_height, -0.38) * Vector3(spread, 1.0, spread)
	gun1.rotation.y = deg_to_rad(28.0)
	root.add_child(gun1)
	_add_zakom0_triangle_gun(gun1, 2)


func _add_zakom0_triangle_gun(root: Node3D, variant: int) -> void:
	if variant == 2:
		var prism_points := [
			Vector3(0.0, 0.16, -0.34), Vector3(-0.20, 0.0, 0.20),
			Vector3(0.20, 0.0, 0.20), Vector3(0.0, -0.12, 0.09),
		]
		_add_dense_polyhedron(root, prism_points, [0, 1, 2, 0, 3, 1, 0, 2, 3, 1, 3, 2], [[0, 1], [1, 2], [2, 0], [0, 3], [1, 3], [2, 3]], ZAKOM0_COLOR.darkened(0.04), 0.32, 0.012, 0.28)
		return
	var top_y := 0.045 if variant == 2 else 0.018
	var top := [
		Vector3(0.0, top_y, -0.34),
		Vector3(-0.23, top_y, 0.23),
		Vector3(0.23, top_y, 0.23),
	]
	var points := top.duplicate()
	var indices := [0, 1, 2]
	var edges := [[0, 1], [1, 2], [2, 0]]
	if variant == 2:
		points.append_array([
			Vector3(0.0, -top_y, -0.34),
			Vector3(-0.23, -top_y, 0.23),
			Vector3(0.23, -top_y, 0.23),
		])
		indices.append_array([3, 5, 4, 0, 3, 4, 0, 4, 1, 1, 4, 5, 1, 5, 2, 2, 5, 3, 2, 3, 0])
		edges.append_array([[3, 4], [4, 5], [5, 3], [0, 3], [1, 4], [2, 5]])
	_add_face(root, points, indices, ZAKOM0_COLOR.darkened(0.04))
	for edge in edges:
		_add_styled_edge(root, points[edge[0]], points[edge[1]], 0.012, ZAKOM0_COLOR.lightened(0.08), 0.28, 1.10, true)
	if variant == 1:
		var fin := [
			Vector3(0.0, 0.018, -0.25),
			Vector3(0.0, 0.17, 0.12),
			Vector3(0.0, 0.018, 0.20),
		]
		_add_face(root, fin, [0, 1, 2, 0, 2, 1], ZAKOM0_COLOR.lightened(0.06))
		for edge in [[0, 1], [1, 2], [2, 0]]:
			_add_styled_edge(root, fin[edge[0]], fin[edge[1]], 0.012, ZAKOM0_COLOR.lightened(0.12), 0.28, 1.10, true)


func _build_bullet1_outlined_bar(root: Node3D) -> void:
	_add_bullet1_sample(root, 0.34, 0.075, false, true, 0.0)


func _build_bullet1_tapered_bolt(root: Node3D) -> void:
	_add_bullet1_sample(root, 0.38, 0.070, true, true, 0.0)


func _build_bullet1_low_prism(root: Node3D) -> void:
	_add_bullet1_sample(root, 0.34, 0.075, false, true, 0.045)


func _add_bullet1_sample(root: Node3D, half_length: float, half_width: float, tapered: bool, with_outline: bool, height: float) -> void:
	var outer := _bullet1_bar_points(half_length, half_width, 0.0, tapered)
	var inner := _bullet1_bar_points(half_length * 0.88, half_width * 0.55, height + 0.018, tapered)
	if with_outline:
		_add_gallery_bullet_polygon(root, outer, BULLET1_COLOR.darkened(0.34), 0.94, 0.12, 0)
	_add_gallery_bullet_polygon(root, inner, BULLET1_COLOR.lightened(0.06), 0.92, 0.62, 1)


func _bullet1_bar_points(half_length: float, half_width: float, height: float, tapered: bool) -> Array:
	if tapered:
		return [
			Vector3(0.0, height, -half_length), Vector3(-half_width, height, -half_length * 0.72),
			Vector3(-half_width, height, half_length * 0.72), Vector3(0.0, height, half_length),
			Vector3(half_width, height, half_length * 0.72), Vector3(half_width, height, -half_length * 0.72),
		]
	return [
		Vector3(-half_width, height, -half_length), Vector3(-half_width, height, half_length),
		Vector3(half_width, height, half_length), Vector3(half_width, height, -half_length),
	]


func _build_zako3_flat_hatch(root: Node3D) -> void:
	_add_zako3_hatch(root, 0.02, 0.0)


func _build_zako3_raised_shell(root: Node3D) -> void:
	_add_zako3_hatch(root, 0.20, 0.0)


func _build_zako3_split_pod(root: Node3D) -> void:
	_add_zako3_ellipsoid_pod(root)


func _add_zako3_ellipsoid_pod(root: Node3D) -> void:
	var radii := Vector3(0.40, 0.27, 0.62)
	var gap := 0.045
	for quadrant in range(4):
		_add_zako3_ellipsoid_shell(root, quadrant, radii, gap)
	for index in range(4):
		var part := Node3D.new()
		var part_angle := PI * 0.25 + float(index) * PI * 0.5
		part.position = Vector3(cos(part_angle) * 0.14, 0.045 if index % 2 == 0 else -0.035, sin(part_angle) * 0.22)
		part.rotation = Vector3(0.24 if index % 2 == 0 else -0.20, -part_angle + PI * 0.5, -0.18 if index < 2 else 0.18)
		part.scale = Vector3.ONE * 0.72
		root.add_child(part)
		_build_zako3p_low_wedge(part)


func _add_zako3_ellipsoid_shell(root: Node3D, quadrant: int, radii: Vector3, gap: float) -> void:
	var theta_steps := 3
	var phi_steps := 4
	var start_theta := -PI * 0.5 + float(quadrant) * PI * 0.5
	var mid_theta := start_theta + PI * 0.25
	var offset := Vector3(cos(mid_theta), 0.0, sin(mid_theta)) * gap
	var points := []
	for phi_index in range(phi_steps + 1):
		var phi := -PI * 0.5 + PI * float(phi_index) / float(phi_steps)
		for theta_index in range(theta_steps + 1):
			var theta := start_theta + PI * 0.5 * float(theta_index) / float(theta_steps)
			points.append(offset + Vector3(
				cos(phi) * cos(theta) * radii.x,
				sin(phi) * radii.y,
				cos(phi) * sin(theta) * radii.z
			))
	var indices := []
	for phi_index in range(phi_steps):
		for theta_index in range(theta_steps):
			var a: int = phi_index * (theta_steps + 1) + theta_index
			var b: int = a + 1
			var c: int = a + theta_steps + 1
			var d: int = c + 1
			indices.append_array([a, c, b, b, c, d])
	_add_face(root, points, indices, ZAKO3_COLOR.darkened(0.035 * float(quadrant % 2)))
	for theta_index in [0, theta_steps]:
		for phi_index in range(phi_steps):
			var a: int = phi_index * (theta_steps + 1) + theta_index
			var b: int = (phi_index + 1) * (theta_steps + 1) + theta_index
			_add_styled_edge(root, points[a], points[b], 0.012, ZAKO3_COLOR, 0.26, 1.15, true)
	var equator_row := int(float(phi_steps) / 2.0)
	for theta_index in range(theta_steps):
		var a: int = equator_row * (theta_steps + 1) + theta_index
		_add_styled_edge(root, points[a], points[a + 1], 0.012, ZAKO3_COLOR, 0.26, 1.15, true)


func _add_zako3_hatch(root: Node3D, crown_height: float, gap: float, show_parts := false) -> void:
	var radius := 0.58
	var aspect_x := 0.68 if show_parts else 1.0
	for index in range(4):
		var start_angle := -PI * 0.5 + float(index) * PI * 0.5
		var mid_angle := start_angle + PI * 0.25
		var end_angle := start_angle + PI * 0.5
		var offset := Vector3(cos(mid_angle) * aspect_x, 0.0, sin(mid_angle)) * gap
		var points := [
			offset + Vector3(cos(start_angle) * aspect_x, 0.0, sin(start_angle)) * radius,
			offset + Vector3(cos(mid_angle) * aspect_x, 0.0, sin(mid_angle)) * radius,
			offset + Vector3(cos(end_angle) * aspect_x, 0.0, sin(end_angle)) * radius,
			offset + Vector3(0.0, crown_height, 0.0),
		]
		var indices := [3, 0, 1, 3, 1, 2]
		_add_face(root, points, indices, ZAKO3_COLOR.darkened(0.04 * float(index % 2)))
		for edge in [[3, 0], [0, 1], [1, 2], [2, 3]]:
			_add_styled_edge(root, points[edge[0]], points[edge[1]], 0.012, ZAKO3_COLOR, 0.26, 1.15, true)
	var ring_root := Node3D.new()
	ring_root.scale.x = aspect_x
	root.add_child(ring_root)
	_add_ring(ring_root, 0.62 + gap, 0.026, ZAKO3_COLOR)
	if show_parts:
		for index in range(4):
			var part := Node3D.new()
			var part_angle := PI * 0.25 + float(index) * PI * 0.5
			part.position = Vector3(cos(part_angle) * 0.13, 0.035, sin(part_angle) * 0.20)
			part.rotation.y = -part_angle + PI * 0.5
			part.scale = Vector3.ONE * 0.62
			root.add_child(part)
			_build_zako3p_low_wedge(part)


func _build_zako3p_flat_shard(root: Node3D) -> void:
	var points := [Vector3(0.0, 0.02, -0.20), Vector3(-0.13, 0.02, 0.16), Vector3(0.13, 0.02, 0.16)]
	_add_zako3p_model(root, points, [0, 1, 2, 0, 2, 1], [[0, 1], [1, 2], [2, 0]])


func _build_zako3p_low_wedge(root: Node3D) -> void:
	var points := [
		Vector3(0.0, 0.12, -0.20), Vector3(-0.13, 0.0, 0.16),
		Vector3(0.13, 0.0, 0.16), Vector3(0.0, -0.10, 0.08),
	]
	_add_zako3p_model(root, points, [0, 1, 2, 0, 3, 1, 0, 2, 3, 1, 3, 2], [[0, 1], [1, 2], [2, 0], [0, 3], [1, 3], [2, 3]])


func _build_zako3p_shard_prism(root: Node3D) -> void:
	var points := [
		Vector3(0.0, 0.055, -0.20), Vector3(-0.13, 0.055, 0.16), Vector3(0.13, 0.055, 0.16),
		Vector3(0.0, -0.055, -0.20), Vector3(-0.13, -0.055, 0.16), Vector3(0.13, -0.055, 0.16),
	]
	_add_zako3p_model(root, points, [
		0, 1, 2, 3, 5, 4, 0, 3, 4, 0, 4, 1,
		1, 4, 5, 1, 5, 2, 2, 5, 3, 2, 3, 0,
	], [[0, 1], [1, 2], [2, 0], [3, 4], [4, 5], [5, 3], [0, 3], [1, 4], [2, 5]])


func _add_zako3p_model(root: Node3D, points: Array, indices: Array, edges: Array) -> void:
	_add_face(root, points, indices, ZAKO3P_COLOR)
	for edge in edges:
		_add_styled_edge(root, points[edge[0]], points[edge[1]], 0.010, ZAKO3P_COLOR, 0.26, 1.15, true)


func _build_zako4_square_battery(root: Node3D) -> void:
	_add_zako4_battery(root, 0.055, false)


func _build_zako4_diamond_battery(root: Node3D) -> void:
	var frame := Node3D.new()
	frame.rotation.y = PI * 0.25
	root.add_child(frame)
	_add_zako4_battery(frame, 0.065, false)


func _build_zako4_stepped_battery(root: Node3D) -> void:
	_add_zako4_battery(root, 0.10, true)


func _add_zako4_battery(root: Node3D, height: float, stepped: bool) -> void:
	var extent := 0.96
	var wall := 0.075
	var half := extent * 0.5
	for part in [
		[Vector3(0.0, 0.0, -half), Vector3(extent, height, wall)],
		[Vector3(0.0, 0.0, half), Vector3(extent, height, wall)],
		[Vector3(-half, 0.0, 0.0), Vector3(wall, height, extent)],
		[Vector3(half, 0.0, 0.0), Vector3(wall, height, extent)],
	]:
		_add_zako4_box_part(root, part[0], part[1], ZAKO4_COLOR)
	if stepped:
		for part in [
			[Vector3(0.0, 0.095, -half), Vector3(extent * 0.72, 0.055, wall)],
			[Vector3(0.0, 0.095, half), Vector3(extent * 0.72, 0.055, wall)],
			[Vector3(-half, 0.095, 0.0), Vector3(wall, 0.055, extent * 0.72)],
			[Vector3(half, 0.095, 0.0), Vector3(wall, 0.055, extent * 0.72)],
		]:
			_add_zako4_box_part(root, part[0], part[1], ZAKO4_COLOR.lightened(0.05))
	for index in range(4):
		var turret := Node3D.new()
		var angle := float(index) * PI * 0.5
		turret.position = Vector3(sin(angle) * half, height * 0.65 + 0.07, -cos(angle) * half)
		turret.rotation.y = -angle
		root.add_child(turret)
		_add_zako4_box_part(turret, Vector3.ZERO, Vector3(0.22, 0.10, 0.22), ZAKO4_COLOR.lightened(0.05))
		_add_zako4_box_part(turret, Vector3(0.0, 0.0, -0.16), Vector3(0.075, 0.07, 0.28), ZAKO4_COLOR.lightened(0.10))


func _add_zako4_box_part(root: Node3D, center: Vector3, size: Vector3, color: Color) -> void:
	var half := size * 0.5
	var points := [
		center + Vector3(-half.x, half.y, -half.z), center + Vector3(half.x, half.y, -half.z),
		center + Vector3(half.x, half.y, half.z), center + Vector3(-half.x, half.y, half.z),
		center + Vector3(-half.x, -half.y, -half.z), center + Vector3(half.x, -half.y, -half.z),
		center + Vector3(half.x, -half.y, half.z), center + Vector3(-half.x, -half.y, half.z),
	]
	_add_face(root, points, [
		0, 1, 2, 0, 2, 3, 4, 6, 5, 4, 7, 6,
		0, 4, 5, 0, 5, 1, 1, 5, 6, 1, 6, 2,
		2, 6, 7, 2, 7, 3, 3, 7, 4, 3, 4, 0,
	], color)
	for edge in [
		[0, 1], [1, 2], [2, 3], [3, 0], [4, 5], [5, 6], [6, 7], [7, 4],
		[0, 4], [1, 5], [2, 6], [3, 7],
	]:
		_add_styled_edge(root, points[edge[0]], points[edge[1]], ZAKO4_OUTLINE_WIDTH, color, 0.22, 0.95, true)


func _build_bullet2_short_bar(root: Node3D) -> void:
	_add_bullet2_sample(root, 0.22, 0.065, false, 0.0)


func _build_bullet2_low_prism(root: Node3D) -> void:
	_add_bullet2_sample(root, 0.22, 0.065, false, 0.04)


func _build_bullet2_tapered_bar(root: Node3D) -> void:
	_add_bullet2_sample(root, 0.25, 0.065, true, 0.0)


func _add_bullet2_sample(root: Node3D, half_length: float, half_width: float, tapered: bool, height: float) -> void:
	var outer := _bullet1_bar_points(half_length, half_width, 0.0, tapered)
	var inner := _bullet1_bar_points(half_length * 0.86, half_width * 0.52, height + 0.016, tapered)
	_add_gallery_bullet_polygon(root, outer, BULLET2_COLOR.darkened(0.30), 0.94, 0.10, 0)
	_add_gallery_bullet_polygon(root, inner, BULLET2_COLOR.lightened(0.08), 0.92, 0.55, 1)


func _build_zako5_flat_ray(root: Node3D) -> void:
	_add_zako5_ray(root, 0.025, 0.0, false)


func _build_zako5_dihedral_ray(root: Node3D) -> void:
	_add_zako5_ray(root, 0.045, 0.12, false)


func _build_zako5_armored_ray(root: Node3D) -> void:
	_add_zako5_detailed_ray(root)


func _add_zako5_ray(root: Node3D, thickness: float, wing_lift: float, armored: bool) -> void:
	var points := [
		Vector3(0.0, thickness, -0.35), Vector3(-0.86, wing_lift, 0.02),
		Vector3(0.0, thickness, 0.26), Vector3(0.86, wing_lift, 0.02),
		Vector3(0.0, -thickness, 0.02),
	]
	_add_dense_polyhedron(root, points, [
		0, 1, 4, 1, 2, 4, 2, 3, 4, 3, 0, 4,
		0, 3, 1, 1, 3, 2,
	], [[0, 1], [1, 2], [2, 3], [3, 0], [0, 4], [2, 4]], ZAKO5_COLOR)
	_add_styled_edge(root, Vector3(0.0, 0.02, 0.22), Vector3(0.0, 0.02, 0.78), 0.012, ZAKO5_COLOR, 0.26, 1.15, true)
	if armored:
		_add_box_part(root, Vector3(0.0, 0.11, -0.02), Vector3(0.28, 0.14, 0.48), ZAKO5_COLOR.lightened(0.10))


func _add_zako5_detailed_ray(root: Node3D) -> void:
	var points := [
		Vector3(0.0, 0.11, -0.46), Vector3(-0.92, 0.045, -0.08),
		Vector3(-0.62, 0.020, 0.14), Vector3(0.0, 0.075, 0.22),
		Vector3(0.74, 0.032, 0.12), Vector3(0.96, 0.065, -0.01),
		Vector3(0.0, -0.08, 0.02),
	]
	_add_dense_polyhedron(root, points, [
		0, 1, 6, 1, 2, 6, 2, 3, 6, 3, 4, 6, 4, 5, 6, 5, 0, 6,
		0, 5, 4, 0, 4, 3, 0, 3, 2, 0, 2, 1,
	], [[0, 1], [1, 2], [2, 3], [3, 4], [4, 5], [5, 0], [0, 6], [3, 6]], ZAKO5_COLOR, 0.48, 0.016, 0.40)
	for line in [
		[Vector3(-0.76, 0.075, -0.08), Vector3(-0.28, 0.12, 0.02)],
		[Vector3(-0.28, 0.12, 0.02), Vector3(0.0, 0.14, -0.34)],
		[Vector3(0.0, 0.14, -0.34), Vector3(0.34, 0.10, 0.02)],
		[Vector3(0.34, 0.10, 0.02), Vector3(0.78, 0.08, -0.01)],
	]:
		_add_styled_edge(root, line[0], line[1], 0.011, ZAKO5_COLOR.lightened(0.18), 0.28, 1.20, true)
	var body := [
		Vector3(0.0, 0.20, -0.42), Vector3(-0.12, 0.065, -0.08),
		Vector3(-0.065, 0.025, 0.46), Vector3(0.0, 0.035, 1.28),
		Vector3(0.065, 0.025, 0.46), Vector3(0.12, 0.065, -0.08),
		Vector3(0.0, -0.08, 0.18),
	]
	_add_dense_polyhedron(root, body, [
		0, 1, 6, 1, 2, 6, 2, 3, 6, 3, 4, 6, 4, 5, 6, 5, 0, 6,
		0, 5, 4, 0, 4, 3, 0, 3, 2, 0, 2, 1,
	], [[0, 1], [1, 2], [2, 3], [3, 4], [4, 5], [5, 0], [0, 6], [3, 6]], ZAKO5_COLOR.lightened(0.10), 0.52, 0.016, 0.42)


func _build_zakom1_low_tank(root: Node3D) -> void:
	_add_zakom1_crystal(root, 0.92, 0.50, 0.38, false)


func _build_zakom1_heavy_shell(root: Node3D) -> void:
	_add_zakom1_crystal(root, 1.00, 0.54, 0.50, false)


func _build_zakom1_ridged_tank(root: Node3D) -> void:
	_add_zakom1_crystal(root, 1.08, 0.58, 0.46, true)


func _add_zakom1_crystal(root: Node3D, half_length: float, half_width: float, half_height: float, ridged: bool) -> void:
	var points := [Vector3(0.0, 0.0, -half_length), Vector3(0.0, 0.0, half_length)]
	for ring in range(2):
		var z := -half_length * 0.32 if ring == 0 else half_length * 0.28
		for index in range(6):
			var angle := float(index) * TAU / 6.0
			var roughness := 1.0 + 0.08 * sin(float(index * 5 + ring * 3))
			points.append(Vector3(cos(angle) * half_width * roughness, sin(angle) * half_height * roughness, z))
	var indices := []
	for index in range(6):
		var next := (index + 1) % 6
		indices.append_array([0, 2 + index, 2 + next])
		indices.append_array([1, 8 + next, 8 + index])
		indices.append_array([2 + index, 8 + index, 2 + next, 2 + next, 8 + index, 8 + next])
	var edges := []
	for index in range(6):
		var next := (index + 1) % 6
		edges.append_array([[0, 2 + index], [1, 8 + index], [2 + index, 2 + next], [8 + index, 8 + next], [2 + index, 8 + index]])
	_add_dense_polyhedron(root, points, indices, edges, ZAKOM1_COLOR.lightened(0.08), 0.50, ZAKOM1_OUTLINE_WIDTH, 0.48)
	if ridged:
		for index in [0, 2, 4]:
			_add_styled_edge(root, points[2 + index], points[8 + ((index + 1) % 6)], ZAKOM1_RIDGE_WIDTH, ZAKOM1_COLOR.lightened(0.30), 0.46, 1.38, true)


func _build_zako6_orbit_cores(root: Node3D) -> void:
	_add_zako6_globe(root, 0.0, 0.0)


func _build_zako6_caged_cores(root: Node3D) -> void:
	_add_zako6_globe(root, 0.0, 0.42)


func _build_zako6_offset_globes(root: Node3D) -> void:
	var globe := Node3D.new()
	globe.rotation = Vector3(0.24, 0.0, -0.20)
	root.add_child(globe)
	_add_zako6_globe(globe, 0.20, -0.36, true)


func _add_zako6_globe(root: Node3D, large_tilt: float, small_tilt: float, enlarged_cores := false) -> void:
	_add_gallery_outlined_sphere(root, Vector3.ZERO, 0.38, ZAKO6_COLOR, 0.12, 0.42, Vector3.ZERO, ZAKO6_OUTER_OUTLINE_WIDTH)
	var large_position := Vector3(-0.10, 0.07, -0.04) if enlarged_cores else Vector3(-0.13, 0.08, -0.05)
	var small_position := Vector3(0.16, -0.07, 0.07) if enlarged_cores else Vector3(0.15, -0.07, 0.08)
	var large_radius := 0.23 if enlarged_cores else 0.15
	var small_radius := 0.16 if enlarged_cores else 0.095
	_add_gallery_outlined_sphere(root, large_position, large_radius, ZAKO6_COLOR.lightened(0.08), 0.34, 0.68, Vector3(large_tilt, 0.0, -large_tilt * 0.45), 0.012)
	_add_gallery_outlined_sphere(root, small_position, small_radius, ZAKO6_COLOR.lightened(0.14), 0.42, 0.82, Vector3(-small_tilt * 0.35, 0.0, small_tilt), 0.010)


func _add_gallery_outlined_sphere(root: Node3D, position: Vector3, radius: float, color: Color, alpha: float, emission: float, outline_rotation: Vector3, outline_width: float) -> void:
	_add_gallery_sphere(root, position, radius, color, alpha, emission)
	var outline := Node3D.new()
	outline.position = position
	outline.rotation = outline_rotation
	root.add_child(outline)
	_add_smooth_ring(outline, radius * 1.04, outline_width, color)


func _add_gallery_sphere(root: Node3D, position: Vector3, radius: float, color: Color, alpha: float, emission: float) -> void:
	var sphere := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	mesh.radial_segments = 8
	mesh.rings = 4
	sphere.mesh = mesh
	sphere.position = position
	sphere.material_override = VisualMaterialsUtil.flat_face(color, alpha, emission)
	root.add_child(sphere)


func _build_zako7_forked_glider(root: Node3D) -> void:
	_add_zako7_head(root, 0.66, 0.34, 0.11, 0.82, false)


func _build_zako7_manta_head(root: Node3D) -> void:
	_add_zako7_head(root, 0.72, 0.42, 0.09, 0.92, false)


func _build_zako7_barbed_ray(root: Node3D) -> void:
	_add_zako7_head(root, 0.74, 0.38, 0.12, 1.02, true)


func _add_zako7_head(root: Node3D, wing_span: float, wing_depth: float, body_width: float, body_length: float, ridged: bool) -> void:
	var nose := Vector3(0.0, 0.14, -0.58)
	_add_zako7_v_wing(root, nose, Vector3(-wing_span, 0.08, wing_depth), Vector3(-0.12, 0.10, -0.12))
	_add_zako7_v_wing(root, nose, Vector3(wing_span, 0.08, wing_depth), Vector3(0.12, 0.10, -0.12))
	var body := [
		Vector3(0.0, 0.22, -0.62), Vector3(-body_width, 0.06, -0.16),
		Vector3(-body_width * 0.48, 0.03, body_length * 0.52), Vector3(0.0, 0.05, body_length),
		Vector3(body_width * 0.48, 0.03, body_length * 0.52), Vector3(body_width, 0.06, -0.16),
		Vector3(0.0, -0.10, 0.14),
	]
	_add_dense_polyhedron(root, body, [
		0, 1, 6, 1, 2, 6, 2, 3, 6, 3, 4, 6, 4, 5, 6, 5, 0, 6,
		0, 5, 4, 0, 4, 3, 0, 3, 2, 0, 2, 1,
	], [[0, 1], [1, 2], [2, 3], [3, 4], [4, 5], [5, 0], [0, 6], [3, 6]], ZAKO7_COLOR.lightened(0.10), 0.38, 0.014, 0.36)
	if ridged:
		_add_styled_edge(root, Vector3(-wing_span * 0.82, 0.11, wing_depth * 0.78), nose, 0.012, ZAKO7_COLOR.lightened(0.18), 0.34, 1.20, true)
		_add_styled_edge(root, Vector3(wing_span * 0.82, 0.11, wing_depth * 0.78), nose, 0.012, ZAKO7_COLOR.lightened(0.18), 0.34, 1.20, true)


func _add_zako7_v_wing(root: Node3D, nose: Vector3, wing_tip: Vector3, inner_tip: Vector3) -> void:
	var thickness := Vector3(0.0, 0.045, 0.0)
	var points := [nose + thickness, wing_tip + thickness, inner_tip + thickness, nose - thickness, wing_tip - thickness, inner_tip - thickness]
	_add_dense_polyhedron(root, points, [
		0, 1, 2, 3, 5, 4,
		0, 3, 1, 1, 3, 4,
		1, 4, 2, 2, 4, 5,
		2, 5, 0, 0, 5, 3,
	], [[0, 1], [1, 2], [2, 0], [3, 4], [4, 5], [5, 3], [0, 3], [1, 4], [2, 5]], ZAKO7_COLOR, 0.30, 0.014, 0.34)


func _build_zako7p_mini_crystal(root: Node3D) -> void:
	_add_zako7p_link(root, 0.28, 0.14, 0.11, false)


func _build_zako7p_flat_link(root: Node3D) -> void:
	_add_zako7p_link(root, 0.32, 0.18, 0.06, false)


func _build_zako7p_ridged_link(root: Node3D) -> void:
	_add_zako7p_link(root, 0.34, 0.17, 0.12, true)


func _add_zako7p_link(root: Node3D, half_length: float, half_width: float, half_height: float, ridged: bool) -> void:
	var points := [
		Vector3(0.0, 0.0, -half_length), Vector3(-half_width, 0.0, 0.0),
		Vector3(0.0, 0.0, half_length), Vector3(half_width, 0.0, 0.0),
		Vector3(0.0, half_height, -0.04), Vector3(0.0, -half_height, 0.04),
	]
	_add_dense_polyhedron(root, points, [
		4, 0, 1, 4, 1, 2, 4, 2, 3, 4, 3, 0,
		5, 1, 0, 5, 2, 1, 5, 3, 2, 5, 0, 3,
	], [[0, 1], [1, 2], [2, 3], [3, 0], [0, 4], [1, 4], [2, 4], [3, 4], [0, 5], [2, 5]], ZAKO7P_COLOR, 0.42, 0.014, 0.38)
	if ridged:
		_add_styled_edge(root, points[0], points[2], 0.016, ZAKO7P_COLOR.lightened(0.20), 0.40, 1.30, true)


func _build_bullet3_dark_dash(root: Node3D) -> void:
	_add_bullet3_dash_line(root, 0, false, false)


func _build_bullet3_faint_glow_dash(root: Node3D) -> void:
	_add_bullet3_dash_line(root, 1, true, false)


func _build_bullet3_low_rail(root: Node3D) -> void:
	_add_bullet3_dash_line(root, 2, true, true)


func _build_myshot_wire_diamond(root: Node3D) -> void:
	root.name = "MyshotWireDiamond"
	root.rotation.z = deg_to_rad(28.0)
	var half_width := 0.036
	var half_height := 0.044
	var half_length := 0.55 * 0.5
	var points := [
		Vector3(0.0, half_height, -half_length),
		Vector3(half_width, 0.0, -half_length),
		Vector3(0.0, -half_height, -half_length),
		Vector3(-half_width, 0.0, -half_length),
		Vector3(0.0, half_height, half_length),
		Vector3(half_width, 0.0, half_length),
		Vector3(0.0, -half_height, half_length),
		Vector3(-half_width, 0.0, half_length),
	]
	_add_dense_face(root, points, [
		0, 1, 5, 0, 5, 4,
		1, 2, 6, 1, 6, 5,
		2, 3, 7, 2, 7, 6,
		3, 0, 4, 3, 4, 7,
	], PLAYER_SHOT_COLOR, 0.24)
	for edge in [
		[0, 4], [1, 5], [2, 6], [3, 7],
		[0, 1], [1, 2], [2, 3], [3, 0],
		[4, 5], [5, 6], [6, 7], [7, 4],
	]:
		_add_styled_edge(root, points[edge[0]], points[edge[1]], 0.007, PLAYER_SHOT_COLOR.lightened(0.10), 0.54, 0.92, false)


func _build_myshot_core_lance(root: Node3D) -> void:
	root.name = "MyshotCoreLance"
	_add_styled_edge(root, Vector3(0.0, 0.0, -0.31), Vector3(0.0, 0.0, 0.31), 0.026, PLAYER_SHOT_COLOR.lightened(0.18), 0.56, 1.35, true, 2)
	_add_styled_edge(root, Vector3(-0.045, 0.0, -0.18), Vector3(0.0, 0.0, -0.31), 0.010, PLAYER_SHOT_COLOR, 0.52, 0.90, false)
	_add_styled_edge(root, Vector3(0.045, 0.0, -0.18), Vector3(0.0, 0.0, -0.31), 0.010, PLAYER_SHOT_COLOR, 0.52, 0.90, false)
	_add_styled_edge(root, Vector3(-0.045, 0.0, 0.18), Vector3(0.0, 0.0, 0.31), 0.010, PLAYER_SHOT_COLOR, 0.52, 0.90, false)
	_add_styled_edge(root, Vector3(0.045, 0.0, 0.18), Vector3(0.0, 0.0, 0.31), 0.010, PLAYER_SHOT_COLOR, 0.52, 0.90, false)


func _build_myshot_open_spark(root: Node3D) -> void:
	root.name = "MyshotOpenSpark"
	for x in [-0.040, 0.0, 0.040]:
		_add_styled_edge(root, Vector3(x, 0.0, -0.28), Vector3(x * 0.45, 0.0, 0.28), 0.009, PLAYER_SHOT_COLOR.lightened(0.12), 0.60, 1.05, true, 1)
	_add_styled_edge(root, Vector3(-0.060, 0.0, -0.10), Vector3(0.060, 0.0, 0.10), 0.008, PLAYER_SHOT_COLOR, 0.36, 0.85, false)
	_add_styled_edge(root, Vector3(0.060, 0.0, -0.10), Vector3(-0.060, 0.0, 0.10), 0.008, PLAYER_SHOT_COLOR, 0.36, 0.85, false)


func _build_mousetarget_corner_sweep(root: Node3D) -> void:
	root.name = "MousetargetCornerSweep"
	_add_mousetarget_corner_markers(root, true)


func _build_mousetarget_cross_ring(root: Node3D) -> void:
	root.name = "MousetargetCrossRing"
	_add_smooth_ring(root, 0.22, 0.026, MOUSE_TARGET_COLOR)
	_add_gallery_2d_line(root, Vector2(-0.34, 0.0), Vector2(-0.12, 0.0), 0.015, MOUSE_TARGET_COLOR)
	_add_gallery_2d_line(root, Vector2(0.12, 0.0), Vector2(0.34, 0.0), 0.015, MOUSE_TARGET_COLOR)
	_add_gallery_2d_line(root, Vector2(0.0, -0.34), Vector2(0.0, -0.12), 0.015, MOUSE_TARGET_COLOR)
	_add_gallery_2d_line(root, Vector2(0.0, 0.12), Vector2(0.0, 0.34), 0.015, MOUSE_TARGET_COLOR)


func _build_mousetarget_dual_bracket(root: Node3D) -> void:
	root.name = "MousetargetDualBracket"
	for side in [-1.0, 1.0]:
		_add_gallery_2d_line(root, Vector2(side * 0.18, -0.30), Vector2(side * 0.34, -0.18), 0.014, MOUSE_TARGET_COLOR)
		_add_gallery_2d_line(root, Vector2(side * 0.34, -0.18), Vector2(side * 0.34, 0.18), 0.014, MOUSE_TARGET_COLOR)
		_add_gallery_2d_line(root, Vector2(side * 0.34, 0.18), Vector2(side * 0.18, 0.30), 0.014, MOUSE_TARGET_COLOR)
	_add_gallery_2d_line(root, Vector2(-0.065, 0.0), Vector2(0.0, -0.065), 0.008, MOUSE_TARGET_COLOR.darkened(0.10))
	_add_gallery_2d_line(root, Vector2(0.0, -0.065), Vector2(0.065, 0.0), 0.008, MOUSE_TARGET_COLOR.darkened(0.10))
	_add_gallery_2d_line(root, Vector2(0.065, 0.0), Vector2(0.0, 0.065), 0.008, MOUSE_TARGET_COLOR.darkened(0.10))
	_add_gallery_2d_line(root, Vector2(0.0, 0.065), Vector2(-0.065, 0.0), 0.008, MOUSE_TARGET_COLOR.darkened(0.10))


func _add_mousetarget_corner_markers(root: Node3D, with_sweep: bool) -> void:
	_add_gallery_2d_line(root, Vector2(-0.36, 0.0), Vector2(-0.14, 0.0), 0.014, MOUSE_TARGET_COLOR.darkened(0.04))
	_add_gallery_2d_line(root, Vector2(0.14, 0.0), Vector2(0.36, 0.0), 0.014, MOUSE_TARGET_COLOR.darkened(0.04))
	_add_gallery_2d_line(root, Vector2(0.0, -0.36), Vector2(0.0, -0.14), 0.014, MOUSE_TARGET_COLOR.darkened(0.04))
	_add_gallery_2d_line(root, Vector2(0.0, 0.14), Vector2(0.0, 0.36), 0.014, MOUSE_TARGET_COLOR.darkened(0.04))
	for sx in [-1.0, 1.0]:
		for sy in [-1.0, 1.0]:
			_add_gallery_2d_line(root, Vector2(sx * 0.23, sy * 0.38), Vector2(sx * 0.38, sy * 0.38), 0.016, MOUSE_TARGET_COLOR.lightened(0.06))
			_add_gallery_2d_line(root, Vector2(sx * 0.38, sy * 0.23), Vector2(sx * 0.38, sy * 0.38), 0.016, MOUSE_TARGET_COLOR.lightened(0.06))
	for point in [[Vector2(-0.085, 0.0), Vector2(0.0, -0.085)], [Vector2(0.0, -0.085), Vector2(0.085, 0.0)], [Vector2(0.085, 0.0), Vector2(0.0, 0.085)], [Vector2(0.0, 0.085), Vector2(-0.085, 0.0)]]:
		_add_gallery_2d_line(root, point[0], point[1], 0.010, MOUSE_TARGET_COLOR.darkened(0.08))
	if with_sweep:
		var sweep := Node3D.new()
		sweep.name = "mousetarget-visibility-sweep"
		root.add_child(sweep)
		_add_gallery_2d_line(sweep, Vector2(-0.060, -0.45), Vector2(0.060, -0.45), 0.022, Color(1.0, 0.95, 0.52))
		_add_gallery_2d_line(sweep, Vector2(0.060, -0.45), Vector2(0.105, -0.37), 0.015, Color(1.0, 0.95, 0.52))
		_add_gallery_2d_line(sweep, Vector2(-0.060, -0.45), Vector2(-0.105, -0.37), 0.015, Color(1.0, 0.95, 0.52))


func _add_gallery_2d_line(root: Node3D, a: Vector2, b: Vector2, width: float, color: Color) -> void:
	_add_styled_edge(root, Vector3(a.x, 0.02, a.y), Vector3(b.x, 0.02, b.y), width, color, 0.72, 0.72, false)


func _build_gum_layered_orb(root: Node3D) -> void:
	root.name = "GumLayeredOrb"
	_add_gallery_sphere(root, Vector3.ZERO, 0.29, GUM_COLOR.lightened(0.22), 0.28, 1.20)
	_add_gallery_sphere(root, Vector3(0.0, 0.0, 0.0), 0.21, GUM_COLOR, 0.40, 1.48)
	_add_gallery_sphere(root, Vector3(0.040, 0.050, -0.025), 0.12, Color(1.0, 0.86, 0.98), 0.68, 1.90)
	var square_points := [
		Vector3(-0.19, 0.055, -0.19),
		Vector3(0.19, 0.055, -0.19),
		Vector3(0.19, 0.055, 0.19),
		Vector3(-0.19, 0.055, 0.19),
	]
	for edge in [[0, 1], [1, 2], [2, 3], [3, 0]]:
		_add_styled_edge(root, square_points[edge[0]], square_points[edge[1]], 0.018, GUM_COLOR.lightened(0.36), 0.72, 1.35, false)
	_add_tilted_gallery_ring(root, Vector3.ZERO, 0.34, 0.014, GUM_COLOR.lightened(0.10), Vector3(deg_to_rad(70.0), 0.0, deg_to_rad(16.0)), 0.60, 1.16)
	_add_tilted_gallery_ring(root, Vector3.ZERO, 0.26, 0.010, GUM_COLOR.lightened(0.28), Vector3(deg_to_rad(22.0), 0.0, deg_to_rad(-38.0)), 0.34, 0.85)
	_add_tilted_gallery_ring(root, Vector3.ZERO, 0.385, 0.012, GUM_COLOR.lightened(0.42), Vector3(deg_to_rad(90.0), 0.0, 0.0), 0.78, 1.28)


func _build_gum_shell_rings(root: Node3D) -> void:
	root.name = "GumShellRings"
	_add_gallery_sphere(root, Vector3.ZERO, 0.19, GUM_COLOR, 0.26, 1.10)
	_add_gallery_sphere(root, Vector3.ZERO, 0.105, GUM_COLOR.lightened(0.35), 0.42, 1.55)
	_add_tilted_gallery_ring(root, Vector3.ZERO, 0.30, 0.014, GUM_COLOR.lightened(0.08), Vector3(deg_to_rad(78.0), 0.0, 0.0), 0.46, 1.10)
	_add_tilted_gallery_ring(root, Vector3.ZERO, 0.28, 0.010, GUM_COLOR.lightened(0.22), Vector3(0.0, 0.0, deg_to_rad(72.0)), 0.34, 0.95)
	_add_tilted_gallery_ring(root, Vector3.ZERO, 0.22, 0.008, Color(1.0, 0.76, 0.96), Vector3(deg_to_rad(44.0), 0.0, deg_to_rad(-44.0)), 0.30, 0.85)


func _build_gum_low_energy_core(root: Node3D) -> void:
	root.name = "GumLowEnergyCore"
	_add_gallery_sphere(root, Vector3.ZERO, 0.23, GUM_LOW_COLOR, 0.20, 0.55)
	_add_gallery_sphere(root, Vector3.ZERO, 0.15, GUM_COLOR.darkened(0.34), 0.28, 0.80)
	_add_gallery_sphere(root, Vector3(0.0, 0.035, 0.0), 0.070, Color(1.0, 0.16, 0.18), 0.42, 1.15)
	_add_tilted_gallery_ring(root, Vector3.ZERO, 0.25, 0.010, GUM_LOW_COLOR.lightened(0.20), Vector3(deg_to_rad(70.0), 0.0, deg_to_rad(24.0)), 0.28, 0.65)
	_add_styled_edge(root, Vector3(-0.15, 0.0, -0.15), Vector3(0.15, 0.0, 0.15), 0.009, GUM_LOW_COLOR.lightened(0.10), 0.24, 0.60, false)
	_add_styled_edge(root, Vector3(0.15, 0.0, -0.15), Vector3(-0.15, 0.0, 0.15), 0.009, GUM_LOW_COLOR.lightened(0.10), 0.24, 0.60, false)


func _add_tilted_gallery_ring(root: Node3D, position: Vector3, radius: float, tube: float, color: Color, rotation: Vector3, alpha: float, emission: float) -> void:
	var ring := MeshInstance3D.new()
	var mesh := TorusMesh.new()
	mesh.inner_radius = maxf(0.02, radius - tube)
	mesh.outer_radius = radius
	mesh.ring_segments = 24
	mesh.rings = 4
	ring.mesh = mesh
	ring.position = position
	ring.rotation = rotation
	ring.material_override = VisualMaterialsUtil.transparent_outline(color, alpha, emission)
	root.add_child(ring)


func _build_mychar_cannon_wheels(root: Node3D) -> void:
	root.name = "MycharCannonWheels"
	_add_player_center_cannon(root, 0.00)
	for side in [-1.0, 1.0]:
		_add_box_part(root, Vector3(side * 0.34, 0.02, 0.10), Vector3(0.22, 0.11, 0.44), PLAYER_COLOR.darkened(0.08))
		_add_tilted_gallery_ring(root, Vector3(side * 0.34, 0.04, 0.09), 0.18, 0.018, PLAYER_COLOR.lightened(0.12), Vector3(deg_to_rad(90.0), 0.0, 0.0), 0.42, 1.05)
		_add_tilted_gallery_ring(root, Vector3(side * 0.34, 0.055, 0.09), 0.095, 0.010, PLAYER_CORE_COLOR, Vector3(deg_to_rad(90.0), 0.0, 0.0), 0.46, 1.20)


func _build_mychar_booster_ship(root: Node3D) -> void:
	root.name = "MycharBoosterShip"
	_add_player_center_cannon(root, 0.04)
	for side in [-1.0, 1.0]:
		_add_box_part(root, Vector3(side * 0.33, 0.02, 0.12), Vector3(0.20, 0.12, 0.58), PLAYER_COLOR.lightened(0.05))
		_add_styled_edge(root, Vector3(side * 0.33, 0.09, 0.38), Vector3(side * 0.33, 0.09, 0.58), 0.045, PLAYER_CORE_COLOR, 0.48, 1.25, true)
		_add_styled_edge(root, Vector3(side * 0.23, 0.08, 0.00), Vector3(0.0, 0.10, -0.42), 0.014, PLAYER_COLOR.lightened(0.18), 0.38, 1.05, true)


func _build_mychar_armored_pods(root: Node3D) -> void:
	root.name = "MycharArmoredPods"
	_add_player_center_cannon(root, -0.02)
	for side in [-1.0, 1.0]:
		_add_box_part(root, Vector3(side * 0.34, 0.04, 0.07), Vector3(0.25, 0.15, 0.38), PLAYER_COLOR.darkened(0.14), 0.14, 0.58, 1.15)
		_add_box_part(root, Vector3(side * 0.34, 0.11, -0.10), Vector3(0.17, 0.07, 0.20), PLAYER_COLOR.lightened(0.04), 0.14, 0.58, 1.15)
		_add_styled_edge(root, Vector3(side * 0.23, 0.12, 0.28), Vector3(side * 0.45, 0.12, 0.28), 0.014, PLAYER_CORE_COLOR, 0.38, 0.95, true)


func _build_player_capture_model(root: Node3D) -> void:
	root.name = "PlayerCaptureModel"
	_build_mychar_armored_pods(root)


func _add_player_center_cannon(root: Node3D, lift: float) -> void:
	_add_box_part(root, Vector3(0.0, 0.06 + lift, 0.08), Vector3(0.24, 0.14, 0.62), PLAYER_COLOR, 0.14, 0.58, 1.15)
	_add_box_part(root, Vector3(0.0, 0.14 + lift, -0.31), Vector3(0.16, 0.10, 0.34), PLAYER_COLOR.lightened(0.12), 0.14, 0.58, 1.15)
	_add_styled_edge(root, Vector3(0.0, 0.20 + lift, -0.62), Vector3(0.0, 0.20 + lift, -0.28), 0.036, PLAYER_CORE_COLOR, 0.70, 1.55, true, 2)
	_add_gallery_sphere(root, Vector3(0.0, 0.18 + lift, -0.08), 0.070, PLAYER_CORE_COLOR, 0.48, 1.55)


func _add_bullet3_dash_line(root: Node3D, variant: int, outlined: bool, raised: bool) -> void:
	for index in range(3):
		var dash := Node3D.new()
		dash.position = Vector3(0.0, 0.0, (float(index) - 1.0) * 1.12)
		root.add_child(dash)
		_add_bullet3_dash(dash, variant, outlined, raised)


func _add_bullet3_dash(root: Node3D, variant: int, outlined: bool, raised: bool) -> void:
	var half_length := 0.40
	var half_width := 0.045
	var height := 0.045 if raised else 0.012
	var points := [
		Vector3(-half_width, height, -half_length), Vector3(-half_width, height, half_length),
		Vector3(half_width, height, half_length), Vector3(half_width, height, -half_length),
	]
	var face_color := BULLET3_COLOR.lightened(0.05 if variant == 0 else 0.12)
	_add_face(root, points, [0, 1, 2, 0, 2, 3], face_color)
	if raised:
		var lower := [
			Vector3(-half_width, -height, -half_length), Vector3(-half_width, -height, half_length),
			Vector3(half_width, -height, half_length), Vector3(half_width, -height, -half_length),
		]
		var all_points := points + lower
		_add_face(root, all_points, [
			4, 6, 5, 4, 7, 6,
			0, 4, 5, 0, 5, 1, 1, 5, 6, 1, 6, 2,
			2, 6, 7, 2, 7, 3, 3, 7, 4, 3, 4, 0,
		], BULLET3_COLOR.darkened(0.14))
	if outlined:
		for edge in [[0, 1], [1, 2], [2, 3], [3, 0]]:
			_add_styled_edge(root, points[edge[0]], points[edge[1]], 0.010, BULLET3_COLOR.lightened(0.22), 0.26, 1.15, true)


func _build_boss_b1_original_capsule(root: Node3D) -> void:
	root.name = "BossB1PaleRect"
	_add_boss_b1_rect_sample(root, 0.038, 0.026, 0.42, 0.85, 0.008, 0.55)


func _build_boss_b1_low_column(root: Node3D) -> void:
	root.name = "BossB1AdditiveRect"
	_add_boss_b1_rect_sample(root, 0.050, 0.035, 0.52, 1.35, 0.009, 0.48)


func _build_boss_b1_faceted_beam(root: Node3D) -> void:
	root.name = "BossB1DarkEdgeRect"
	_add_boss_b1_rect_sample(root, 0.044, 0.030, 0.46, 1.05, 0.011, 0.68)


func _add_boss_b1_rect_sample(root: Node3D, half_width: float, half_height: float, face_alpha: float, face_emission: float, edge_width: float, edge_alpha: float) -> void:
	var length := 1.15
	var points := [
		Vector3(-half_width, half_height, -length * 0.5), Vector3(half_width, half_height, -length * 0.5),
		Vector3(half_width, half_height, length * 0.5), Vector3(-half_width, half_height, length * 0.5),
		Vector3(-half_width, -half_height, -length * 0.5), Vector3(half_width, -half_height, -length * 0.5),
		Vector3(half_width, -half_height, length * 0.5), Vector3(-half_width, -half_height, length * 0.5),
	]
	_add_boss_b1_glow_sample(root, length, half_width, half_height)
	_add_dense_face(root, points, [
		0, 1, 2, 0, 2, 3, 4, 6, 5, 4, 7, 6,
		0, 4, 5, 0, 5, 1, 1, 5, 6, 1, 6, 2,
		2, 6, 7, 2, 7, 3, 3, 7, 4, 3, 4, 0,
	], BOSS_B1_COLOR, face_alpha)
	var face := root.get_child(root.get_child_count() - 1) as MeshInstance3D
	var material := face.material_override as ShaderMaterial
	if material != null:
		material.set_shader_parameter("face_color", Color(BOSS_B1_COLOR.r, BOSS_B1_COLOR.g, BOSS_B1_COLOR.b, face_alpha))
		material.set_shader_parameter("emission_strength", face_emission)
	for edge in [
		[0, 1], [1, 2], [2, 3], [3, 0], [4, 5], [5, 6], [6, 7], [7, 4],
		[0, 4], [1, 5], [2, 6], [3, 7],
	]:
		_add_styled_edge(root, points[edge[0]], points[edge[1]], edge_width, BOSS_B1_EDGE_COLOR, edge_alpha, 0.40, false)


func _add_boss_b1_glow_sample(root: Node3D, length: float, half_width: float, half_height: float) -> void:
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
	var glow := MeshInstance3D.new()
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = points
	arrays[Mesh.ARRAY_INDEX] = PackedInt32Array([0, 1, 2, 0, 2, 3])
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	glow.name = "boss-b1-soft-glow"
	glow.mesh = mesh
	glow.material_override = material
	root.add_child(glow)


func _add_boss_core_comparison_base(root: Node3D) -> void:
	_add_boss_core_sphere(root, 0.87, 0.14, 0.48, BOSS_CAGED_CORE_OUTLINE_WIDTH, 0.90)
	_add_boss_core_inner_mark(root, 1, 0.64)
	_add_boss_core_arc_ring(root, 1.18, 0.014, 3, 3, 0.22, 0.0, "boss-core-ring-cw-inner", BOSS_CORE_COLOR.darkened(0.12))


func _build_boss_core_gapped_orbits(root: Node3D) -> void:
	_add_boss_core_comparison_base(root)
	_add_boss_core_arc_ring(root, 1.85, BOSS_CAGED_PRIMARY_RING_WIDTH, 4, 5, -0.30, 0.24, "boss-core-ring-ccw-primary", BOSS_CORE_COLOR.darkened(0.14))
	_add_boss_core_arc_ring(root, 2.65, BOSS_CAGED_SECONDARY_RING_WIDTH, 5, 6, 0.24, -0.34, "boss-core-ring-cw-outer", BOSS_CORE_COLOR.lightened(0.34), 0.18, 0.82)
	_add_boss_core_gun_orbit(root, 0.96, 4)


func _build_boss_core_complete_orbits(root: Node3D) -> void:
	_add_boss_core_comparison_base(root)
	_add_boss_core_arc_ring(root, 1.85, BOSS_CAGED_PRIMARY_RING_WIDTH, 0, 0, -0.30, 0.24, "boss-core-ring-ccw-primary-complete", BOSS_CORE_COLOR.darkened(0.14))
	_add_boss_core_arc_ring(root, 2.65, BOSS_CAGED_SECONDARY_RING_WIDTH, 0, 0, 0.24, -0.34, "boss-core-ring-cw-outer-complete", BOSS_CORE_COLOR.lightened(0.34), 0.18, 0.82)
	_add_boss_core_gun_orbit(root, 0.96, 4)


func _build_boss_core_saturn_bands(root: Node3D) -> void:
	_add_boss_core_comparison_base(root)
	_add_boss_core_flat_band(root, 1.62, 0.18, -0.16, 0.10, "boss-core-ring-ccw-primary-saturn", BOSS_CORE_COLOR.darkened(0.08), 0.18)
	_add_boss_core_flat_band(root, 2.92, 0.58, 0.10, -0.16, "boss-core-ring-cw-outer-saturn", BOSS_CORE_COLOR.lightened(0.30), 0.11)
	_add_boss_core_gun_orbit(root, 0.96, 4)


func _add_boss_core_sphere(root: Node3D, radius: float, alpha: float, emission: float, outer_outline_width := 0.020, inner_ring_ratio := 0.69) -> void:
	var core_visual := Node3D.new()
	core_visual.name = "boss-core-visual"
	root.add_child(core_visual)
	_add_gallery_sphere(core_visual, Vector3.ZERO, radius, BOSS_CORE_COLOR.darkened(0.18), alpha, emission)
	_add_smooth_ring(core_visual, radius * 1.03, outer_outline_width, BOSS_CORE_COLOR)
	var inner_ring := Node3D.new()
	inner_ring.rotation = Vector3(0.30, 0.0, -0.18)
	core_visual.add_child(inner_ring)
	_add_smooth_ring(inner_ring, radius * inner_ring_ratio, 0.010, BOSS_CORE_COLOR.darkened(0.08))


func _add_boss_core_inner_mark(root: Node3D, variant: int, extent: float) -> void:
	var core_visual := root.find_child("boss-core-visual", false, false) as Node3D
	var mark := Node3D.new()
	mark.name = "boss-core-inner-mark"
	mark.rotation = Vector3(0.18, 0.0, -0.24)
	core_visual.add_child(mark)
	if variant == 0:
		var points := [
			Vector3(0.0, extent * 0.46, -extent), Vector3(-extent * 0.72, 0.0, extent * 0.52),
			Vector3(extent * 0.72, 0.0, extent * 0.52), Vector3(0.0, -extent * 0.46, -extent * 0.18),
		]
		_add_dense_polyhedron(mark, points, [0, 1, 2, 0, 3, 1, 0, 2, 3, 1, 3, 2], [[0, 1], [1, 2], [2, 0], [0, 3], [1, 3], [2, 3]], BOSS_CORE_COLOR.lightened(0.10), 0.32, 0.012, 0.28)
	elif variant == 1:
		var points := [
			Vector3(0.0, extent, 0.0), Vector3(-extent * 0.62, 0.0, -extent * 0.48),
			Vector3(extent * 0.62, 0.0, -extent * 0.48), Vector3(0.0, -extent, 0.0),
			Vector3(-extent * 0.42, 0.0, extent * 0.56), Vector3(extent * 0.42, 0.0, extent * 0.56),
		]
		_add_dense_polyhedron(mark, points, [0, 1, 2, 0, 2, 5, 0, 5, 4, 0, 4, 1, 3, 2, 1, 3, 5, 2, 3, 4, 5, 3, 1, 4], [[0, 1], [0, 2], [0, 4], [0, 5], [3, 1], [3, 2], [3, 4], [3, 5]], BOSS_CORE_COLOR.lightened(0.08), 0.30, 0.011, 0.27)
	else:
		for side in [-1.0, 1.0]:
			var shard := Node3D.new()
			shard.position.x = side * extent * 0.20
			shard.rotation.z = side * 0.28
			mark.add_child(shard)
			var points := [
				Vector3(0.0, extent * 0.54, -extent * 0.62), Vector3(-extent * 0.40, 0.0, extent * 0.40),
				Vector3(extent * 0.40, 0.0, extent * 0.40), Vector3(0.0, -extent * 0.36, -extent * 0.08),
			]
			_add_dense_polyhedron(shard, points, [0, 1, 2, 0, 3, 1, 0, 2, 3, 1, 3, 2], [[0, 1], [1, 2], [2, 0], [0, 3], [1, 3], [2, 3]], BOSS_CORE_COLOR.lightened(0.12), 0.28, 0.010, 0.26)


func _add_boss_core_arc_ring(root: Node3D, radius: float, width: float, gap_start: int, gap_length: int, tilt_x: float, tilt_z: float, ring_name: String, ring_color := BOSS_CORE_COLOR, alpha := 0.26, emission := 1.05) -> void:
	var ring := Node3D.new()
	ring.name = ring_name
	ring.position.y = maxf(0.0, radius - 0.30)
	ring.rotation = Vector3(tilt_x, 0.0, tilt_z)
	root.add_child(ring)
	var segments := 24
	for index in range(segments):
		if posmod(index - gap_start, segments) < gap_length:
			continue
		var a := TAU * float(index) / float(segments)
		var b := TAU * float(index + 1) / float(segments)
		var pa := Vector3(cos(a) * radius, 0.0, sin(a) * radius)
		var pb := Vector3(cos(b) * radius, 0.0, sin(b) * radius)
		_add_styled_edge(ring, pa, pb, width, ring_color, alpha, emission, true)


func _add_boss_core_flat_band(root: Node3D, radius: float, radial_width: float, tilt_x: float, tilt_z: float, ring_name: String, color: Color, alpha: float) -> void:
	var ring := Node3D.new()
	ring.name = ring_name
	ring.position.y = maxf(0.0, radius - 0.30)
	ring.rotation = Vector3(tilt_x, 0.0, tilt_z)
	root.add_child(ring)
	var inner_radius := radius - radial_width * 0.5
	var outer_radius := radius + radial_width * 0.5
	var points: Array[Vector3] = []
	var indices: Array[int] = []
	var segments := 32
	for index in range(segments):
		var angle := TAU * float(index) / float(segments)
		points.append(Vector3(cos(angle) * inner_radius, 0.0, sin(angle) * inner_radius))
		points.append(Vector3(cos(angle) * outer_radius, 0.0, sin(angle) * outer_radius))
	for index in range(segments):
		var next := (index + 1) % segments
		var inner := index * 2
		var outer := inner + 1
		var next_inner := next * 2
		var next_outer := next_inner + 1
		indices.append_array([inner, outer, next_outer, inner, next_outer, next_inner])
	_add_dense_face(ring, points, indices, color, alpha)


func _add_boss_core_gun_orbit(root: Node3D, radius: float, count: int) -> void:
	var orbit := Node3D.new()
	orbit.name = "boss-core-gun-orbit"
	root.add_child(orbit)
	for index in range(count):
		var angle := TAU * float(index) / float(count)
		var gun := Node3D.new()
		gun.position = Vector3(cos(angle) * radius, 0.07, sin(angle) * radius)
		gun.rotation.y = -angle + PI * 0.5
		orbit.add_child(gun)
		_add_zako4_box_part(gun, Vector3.ZERO, Vector3(0.16, 0.11, 0.22), BOSS_CORE_COLOR.darkened(0.12))


func _build_boss_t1_square_carrier(root: Node3D) -> void:
	_add_boss_t1_frame(root, 0.16, false, false)
	_add_boss_t1_guns(root, 0.08)


func _build_boss_t1_braced_fortress(root: Node3D) -> void:
	_add_boss_t1_frame(root, 0.22, true, false)
	_add_boss_t1_guns(root, 0.13)


func _build_boss_t1_stepped_citadel(root: Node3D) -> void:
	_add_boss_t_rapid_rail_body(root)
	_add_boss_t1_guns(root, 0.20)


func _build_boss_t2_stepped_citadel(root: Node3D) -> void:
	_add_boss_t_opposing_frame_body(root)
	_add_gallery_boss_t_slow_gun(root, 0.20)
	var opposing_gun := Node3D.new()
	opposing_gun.position.y = 0.20
	root.add_child(opposing_gun)
	for direction in [-1.0, 1.0]:
		var gun := Node3D.new()
		gun.position.z = -direction * 0.28
		gun.rotation.y = 0.0 if direction > 0.0 else PI
		opposing_gun.add_child(gun)
		_add_gallery_boss_t_prism_gun(gun, BOSS_T1_GUN_COLOR.lightened(0.08))


func _build_boss_t3_stepped_citadel(root: Node3D) -> void:
	_add_boss_t_burst_triad_body(root)
	for index in [1, 2, 3]:
		var angle := TAU * float(index) / 4.0
		var emitter := Node3D.new()
		emitter.position = Vector3(sin(angle) * 0.72, 0.20, -cos(angle) * 0.72)
		emitter.rotation.y = -angle
		root.add_child(emitter)
		_add_gallery_boss_t_prism_gun(emitter, ZAKO3P_COLOR)


func _add_boss_t_rapid_rail_body(root: Node3D) -> void:
	var body := Node3D.new()
	body.name = "boss-t-rapid-rail-body"
	root.add_child(body)
	var color := BOSS_CORE_COLOR.lightened(0.04)
	_add_dense_box_part(body, Vector3(0.0, 0.04, 0.0), Vector3(0.30, 0.26, 1.70), color, 0.28, 0.014, 0.32)
	for side in [-1.0, 1.0]:
		_add_dense_box_part(body, Vector3(side * 0.42, 0.09, 0.0), Vector3(0.12, 0.20, 1.42), color.lightened(0.05), 0.24, 0.012, 0.30)
		_add_styled_edge(body, Vector3(side * 0.55, 0.18, -0.70), Vector3(side * 0.24, 0.18, 0.70), 0.010, color.lightened(0.16), 0.28, 1.20, true)
	_add_dense_box_part(body, Vector3(0.0, 0.15, -0.78), Vector3(1.00, 0.12, 0.16), color.darkened(0.04), 0.22, 0.012, 0.28)
	_add_dense_box_part(body, Vector3(0.0, 0.16, 0.82), Vector3(0.56, 0.12, 0.18), color.lightened(0.08), 0.24, 0.012, 0.28)
	_add_boss_t1_connection_anchor(root, 0.88, 0.30)


func _add_boss_t_opposing_frame_body(root: Node3D) -> void:
	var body := Node3D.new()
	body.name = "boss-t-opposing-frame-body"
	root.add_child(body)
	var color := BOSS_CORE_COLOR.lightened(0.02)
	_add_dense_box_part(body, Vector3(0.0, 0.04, 0.0), Vector3(1.55, 0.22, 0.24), color, 0.27, 0.014, 0.32)
	_add_dense_box_part(body, Vector3(0.0, 0.11, 0.0), Vector3(0.44, 0.22, 1.18), color.darkened(0.03), 0.24, 0.012, 0.30)
	for side in [-1.0, 1.0]:
		_add_dense_box_part(body, Vector3(side * 0.82, 0.13, 0.0), Vector3(0.30, 0.18, 0.48), color.lightened(0.06), 0.24, 0.012, 0.30)
		_add_styled_edge(body, Vector3(side * 0.22, 0.23, -0.42), Vector3(side * 0.78, 0.23, 0.24), 0.011, color.lightened(0.17), 0.27, 1.15, true)
		_add_styled_edge(body, Vector3(side * 0.22, 0.23, 0.42), Vector3(side * 0.78, 0.23, -0.24), 0.011, color.lightened(0.17), 0.27, 1.15, true)
	_add_boss_t1_connection_anchor(root, 0.74, 0.30)


func _add_boss_t_burst_triad_body(root: Node3D) -> void:
	var body := Node3D.new()
	body.name = "boss-t-burst-triad-body"
	root.add_child(body)
	var color := BOSS_CORE_COLOR.lightened(0.06)
	_add_boss_t_tri_prism(body, 0.88, 0.26, color)
	for index in range(3):
		var angle := -PI * 0.5 + TAU * float(index) / 3.0
		var pad_position := Vector3(cos(angle) * 0.44, 0.20, sin(angle) * 0.44)
		var pad := Node3D.new()
		pad.position = pad_position
		pad.rotation.y = -angle + PI * 0.5
		body.add_child(pad)
		_add_dense_box_part(pad, Vector3.ZERO, Vector3(0.26, 0.12, 0.42), color.lightened(0.06), 0.26, 0.012, 0.30)
	_add_boss_t1_connection_anchor(root, 0.82, 0.30)


func _add_boss_t_tri_prism(root: Node3D, radius: float, height: float, color: Color) -> void:
	var top_y := height
	var bottom_y := 0.0
	var points := []
	for index in range(3):
		var angle := -PI * 0.5 + TAU * float(index) / 3.0
		points.append(Vector3(cos(angle) * radius, top_y, sin(angle) * radius))
	for index in range(3):
		var angle := -PI * 0.5 + TAU * float(index) / 3.0
		points.append(Vector3(cos(angle) * radius * 0.86, bottom_y, sin(angle) * radius * 0.86))
	_add_dense_polyhedron(root, points, [
		0, 1, 2,
		3, 5, 4,
		0, 3, 4, 0, 4, 1,
		1, 4, 5, 1, 5, 2,
		2, 5, 3, 2, 3, 0,
	], [
		[0, 1], [1, 2], [2, 0],
		[3, 4], [4, 5], [5, 3],
		[0, 3], [1, 4], [2, 5],
	], color, 0.26, 0.014, 0.34)


func _build_boss_link_sinuous_ribbon(root: Node3D) -> void:
	_add_boss_link_default_scene(root, 0)


func _build_boss_link_node_tether(root: Node3D) -> void:
	_add_boss_link_default_scene(root, 1)


func _build_boss_link_high_arch(root: Node3D) -> void:
	_add_boss_link_default_scene(root, 2)


func _add_boss_link_default_scene(root: Node3D, variant: int) -> void:
	_add_boss_core_sphere(root, 0.38, 0.10, 0.35)
	var turret := Node3D.new()
	turret.position = Vector3(2.25, 0.0, 0.0)
	turret.scale = Vector3.ONE * 0.44
	root.add_child(turret)
	_add_boss_t1_frame(turret, 0.30, false, true)
	var points := [
		Vector3(-0.38, 0.02, 0.0),
		Vector3(0.32, 0.30 + 0.18 * variant, -0.22 + 0.18 * variant),
		Vector3(1.16, 0.18 + 0.24 * variant, 0.25),
		Vector3(1.86, 0.04, -0.08),
	]
	for index in range(points.size() - 1):
		_add_styled_edge(root, points[index], points[index + 1], 0.030 + 0.012 * variant, Color(0.82, 0.96, 1.0), 0.18, 0.55, false)
	if variant == 1:
		for index in range(1, points.size() - 1):
			_add_gallery_sphere(root, points[index], 0.075, Color(0.90, 0.98, 1.0), 0.28, 0.55)


func _add_boss_t1_frame(root: Node3D, wall_height: float, braced: bool, stepped: bool) -> void:
	var extent := 1.80
	var half := extent * 0.5
	var wall := 0.12
	for part in [
		[Vector3(0.0, 0.0, -half), Vector3(extent, wall_height, wall)],
		[Vector3(0.0, 0.0, half), Vector3(extent, wall_height, wall)],
		[Vector3(-half, 0.0, 0.0), Vector3(wall, wall_height, extent)],
		[Vector3(half, 0.0, 0.0), Vector3(wall, wall_height, extent)],
	]:
		_add_dense_box_part(root, part[0], part[1], BOSS_CORE_COLOR, 0.34, 0.016, 0.34)
	if braced:
		_add_styled_edge(root, Vector3(-half, wall_height * 0.56, -half), Vector3(half, wall_height * 0.56, half), 0.014, BOSS_CORE_COLOR.darkened(0.06), 0.25, 1.05, true)
		_add_styled_edge(root, Vector3(half, wall_height * 0.56, -half), Vector3(-half, wall_height * 0.56, half), 0.014, BOSS_CORE_COLOR.darkened(0.06), 0.25, 1.05, true)
	if stepped:
		var upper_extent := extent * 0.76
		var upper_half := upper_extent * 0.5
		for part in [
			[Vector3(0.0, wall_height * 0.52, -upper_half), Vector3(upper_extent, 0.10, 0.06)],
			[Vector3(0.0, wall_height * 0.52, upper_half), Vector3(upper_extent, 0.10, 0.06)],
			[Vector3(-upper_half, wall_height * 0.52, 0.0), Vector3(0.06, 0.10, upper_extent)],
			[Vector3(upper_half, wall_height * 0.52, 0.0), Vector3(0.06, 0.10, upper_extent)],
		]:
			_add_dense_box_part(root, part[0], part[1], BOSS_CORE_COLOR.lightened(0.06), 0.32, 0.012, 0.28)
	_add_boss_t1_connection_anchor(root, half, wall_height)


func _add_boss_t1_guns(root: Node3D, mount_height: float) -> void:
	for side in [-1.0, 1.0]:
		var gun := Node3D.new()
		gun.position = Vector3(side * 0.42, mount_height, 0.18)
		root.add_child(gun)
		_add_gallery_boss_t_prism_gun(gun, BOSS_T1_GUN_COLOR)
	_add_gallery_boss_t_slow_gun(root, mount_height)


func _add_gallery_boss_t_slow_gun(root: Node3D, mount_height: float) -> void:
	var orbit_gun := Node3D.new()
	orbit_gun.position = Vector3(0.0, mount_height + 0.02, -0.96)
	root.add_child(orbit_gun)
	var cube := Node3D.new()
	cube.name = "boss-t-slow-gun-cube"
	orbit_gun.add_child(cube)
	_add_dense_box_part(cube, Vector3.ZERO, Vector3(0.24, 0.24, 0.24), BOSS_CORE_COLOR.lightened(0.04), 0.30, BOSS_T_SLOW_GUN_EDGE_WIDTH, 0.36)


func _add_gallery_boss_t_prism_gun(root: Node3D, color: Color) -> void:
	var points := [
		Vector3(0.0, 0.14, -0.34), Vector3(-0.18, 0.0, 0.18),
		Vector3(0.18, 0.0, 0.18), Vector3(0.0, -0.10, 0.08),
	]
	_add_dense_polyhedron(root, points, [0, 1, 2, 0, 3, 1, 0, 2, 3, 1, 3, 2], [[0, 1], [1, 2], [2, 0], [0, 3], [1, 3], [2, 3]], color, 0.38, 0.012, 0.30)


func _add_boss_t1_connection_anchor(root: Node3D, half: float, wall_height: float) -> void:
	var anchor := Node3D.new()
	anchor.name = "boss-t1-core-anchor"
	anchor.position = Vector3(0.0, wall_height * 0.20, half)
	root.add_child(anchor)
	_add_dense_box_part(anchor, Vector3.ZERO, Vector3(0.30, 0.16, 0.16), BOSS_CORE_COLOR.darkened(0.10), 0.34, 0.012, 0.28)


func _add_dense_box_part(root: Node3D, center: Vector3, size: Vector3, color: Color, alpha: float, edge_width: float, edge_alpha: float) -> void:
	var half := size * 0.5
	var points := [
		center + Vector3(-half.x, half.y, -half.z), center + Vector3(half.x, half.y, -half.z),
		center + Vector3(half.x, half.y, half.z), center + Vector3(-half.x, half.y, half.z),
		center + Vector3(-half.x, -half.y, -half.z), center + Vector3(half.x, -half.y, -half.z),
		center + Vector3(half.x, -half.y, half.z), center + Vector3(-half.x, -half.y, half.z),
	]
	_add_dense_polyhedron(root, points, [
		0, 1, 2, 0, 2, 3, 4, 6, 5, 4, 7, 6,
		0, 4, 5, 0, 5, 1, 1, 5, 6, 1, 6, 2,
		2, 6, 7, 2, 7, 3, 3, 7, 4, 3, 4, 0,
	], [
		[0, 1], [1, 2], [2, 3], [3, 0], [4, 5], [5, 6], [6, 7], [7, 4],
		[0, 4], [1, 5], [2, 6], [3, 7],
	], color, alpha, edge_width, edge_alpha)


func _add_styled_wing(root: Node3D, nose: Vector3, wing_tip: Vector3, inner_tail: Vector3, line_width: float, line_alpha: float, emission: float, additive: bool) -> void:
	var points := [nose, wing_tip, inner_tail]
	_add_face(root, points, [0, 1, 2, 0, 2, 1], ZAKO0_COLOR)
	for edge in [[0, 1], [1, 2], [2, 0]]:
		_add_styled_edge(root, points[edge[0]], points[edge[1]], line_width, ZAKO0_COLOR.lightened(0.10), line_alpha, emission, additive)


func _add_styled_glider_body(root: Node3D, nose: Vector3, line_width: float, line_alpha: float, emission: float, additive: bool) -> void:
	var points := [
		nose + Vector3(0.0, 0.02, -0.10),
		nose + Vector3(-0.09, 0.0, 0.15),
		nose + Vector3(0.0, 0.03, 0.50),
		nose + Vector3(0.09, 0.0, 0.15),
		nose + Vector3(0.0, 0.10, 0.12),
		nose + Vector3(0.0, -0.10, 0.12),
	]
	_add_face(root, points, [
		4, 0, 1, 4, 1, 2, 4, 2, 3, 4, 3, 0,
		5, 1, 0, 5, 2, 1, 5, 3, 2, 5, 0, 3,
	], ZAKO0_COLOR.lightened(0.12))
	for edge in [[0, 1], [1, 2], [2, 3], [3, 0], [0, 4], [2, 4], [0, 5], [2, 5]]:
		_add_styled_edge(root, points[edge[0]], points[edge[1]], line_width, ZAKO0_COLOR.lightened(0.14), line_alpha, emission, additive)


func _add_square_plate(root: Node3D, center: Vector3, size: float, height: float, yaw: float, tilt: float = 0.0, roll: float = 0.0, color: Color = ZAKO2_COLOR) -> void:
	var plate := Node3D.new()
	plate.position = center
	plate.rotation = Vector3(tilt, yaw, roll)
	root.add_child(plate)
	var half_size := size * 0.5
	var half_height := height * 0.5
	var points := [
		Vector3(-half_size, half_height, -half_size), Vector3(half_size, half_height, -half_size),
		Vector3(half_size, half_height, half_size), Vector3(-half_size, half_height, half_size),
		Vector3(-half_size, -half_height, -half_size), Vector3(half_size, -half_height, -half_size),
		Vector3(half_size, -half_height, half_size), Vector3(-half_size, -half_height, half_size),
	]
	_add_face(plate, points, [
		0, 1, 2, 0, 2, 3, 4, 6, 5, 4, 7, 6,
		0, 4, 5, 0, 5, 1, 1, 5, 6, 1, 6, 2,
		2, 6, 7, 2, 7, 3, 3, 7, 4, 3, 4, 0,
	], color)
	for edge in [
		[0, 1], [1, 2], [2, 3], [3, 0],
		[4, 5], [5, 6], [6, 7], [7, 4],
		[0, 4], [1, 5], [2, 6], [3, 7],
	]:
		_add_styled_edge(plate, points[edge[0]], points[edge[1]], 0.012, color.lightened(0.10), 0.26, 1.15, true)


func _add_dense_polyhedron(root: Node3D, points: Array, indices: Array, edges: Array, color: Color, alpha := 0.76, edge_width := 0.013, edge_alpha := 0.34) -> void:
	_add_dense_face(root, points, indices, color, alpha)
	for edge in edges:
		_add_styled_edge(root, points[edge[0]], points[edge[1]], edge_width, color.lightened(0.18), edge_alpha, 1.15, true)


func _add_box_part(root: Node3D, center: Vector3, size: Vector3, color: Color, face_alpha := 0.32, edge_alpha := 0.30, edge_emission := 1.20) -> void:
	var half := size * 0.5
	var points := [
		center + Vector3(-half.x, half.y, -half.z), center + Vector3(half.x, half.y, -half.z),
		center + Vector3(half.x, half.y, half.z), center + Vector3(-half.x, half.y, half.z),
		center + Vector3(-half.x, -half.y, -half.z), center + Vector3(half.x, -half.y, -half.z),
		center + Vector3(half.x, -half.y, half.z), center + Vector3(-half.x, -half.y, half.z),
	]
	_add_face(root, points, [
		0, 1, 2, 0, 2, 3, 4, 6, 5, 4, 7, 6,
		0, 4, 5, 0, 5, 1, 1, 5, 6, 1, 6, 2,
		2, 6, 7, 2, 7, 3, 3, 7, 4, 3, 4, 0,
	], color, face_alpha)
	for edge in [
		[0, 1], [1, 2], [2, 3], [3, 0],
		[4, 5], [5, 6], [6, 7], [7, 4],
		[0, 4], [1, 5], [2, 6], [3, 7],
	]:
		_add_styled_edge(root, points[edge[0]], points[edge[1]], 0.014, color.lightened(0.14), edge_alpha, edge_emission, true)


func _add_gallery_bullet_polygon(root: Node3D, perimeter: Array, color: Color, alpha: float, emission: float, priority: int) -> void:
	var points := [Vector3(0.0, perimeter[0].y, 0.0)]
	points.append_array(perimeter)
	var indices := []
	for index in perimeter.size():
		indices.append_array([0, index + 1, (index + 1) % perimeter.size() + 1])
	var vertices := PackedVector3Array(points)
	var packed_indices := PackedInt32Array(indices)
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_INDEX] = packed_indices
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	var face := MeshInstance3D.new()
	face.mesh = mesh
	var material := VisualMaterialsUtil.flat_face(color, alpha, emission)
	material.render_priority = priority
	face.material_override = material
	root.add_child(face)


func _add_dense_face(root: Node3D, points: Array, indices: Array, color: Color, alpha := 0.76) -> void:
	var vertices := PackedVector3Array(points)
	var packed_indices := PackedInt32Array(indices)
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_INDEX] = packed_indices
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	var face := MeshInstance3D.new()
	face.mesh = mesh
	face.material_override = VisualMaterialsUtil.flat_face(color.darkened(0.12), alpha, 0.48)
	root.add_child(face)


func _add_bullet0_tail(root: Node3D, start: Vector3, finish: Vector3, color := BULLET0_COLOR.lightened(0.20)) -> void:
	_add_styled_edge(root, start, finish, 0.010, color, 0.42, 0.85, true, 3)


func _add_octahedron(root: Node3D, radius: float, color: Color) -> void:
	var points := [
		Vector3(0.0, radius, 0.0), Vector3(-radius, 0.0, 0.0),
		Vector3(0.0, 0.0, -radius), Vector3(radius, 0.0, 0.0),
		Vector3(0.0, 0.0, radius), Vector3(0.0, -radius, 0.0),
	]
	_add_polyhedron(root, points, [
		0, 1, 2, 0, 2, 3, 0, 3, 4, 0, 4, 1,
		5, 2, 1, 5, 3, 2, 5, 4, 3, 5, 1, 4,
	], [[1, 2], [2, 3], [3, 4], [4, 1], [0, 1], [0, 2], [0, 3], [0, 4]], color)


func _add_ring(root: Node3D, radius: float, tube: float, color: Color) -> void:
	var ring := MeshInstance3D.new()
	var mesh := TorusMesh.new()
	mesh.inner_radius = radius - tube
	mesh.outer_radius = radius
	mesh.ring_segments = 16
	mesh.rings = 4
	ring.mesh = mesh
	ring.material_override = VisualMaterialsUtil.outline(color, 0.94, 1.8)
	root.add_child(ring)


func _add_smooth_ring(root: Node3D, radius: float, tube: float, color: Color) -> void:
	var ring := MeshInstance3D.new()
	var mesh := TorusMesh.new()
	mesh.inner_radius = radius - tube
	mesh.outer_radius = radius
	mesh.ring_segments = 6
	mesh.rings = 24
	ring.mesh = mesh
	ring.material_override = VisualMaterialsUtil.outline(color, 0.26, 0.90)
	root.add_child(ring)


func _add_polyhedron(root: Node3D, points: Array, indices: Array, edges: Array, color: Color) -> void:
	_add_face(root, points, indices, color)
	for edge in edges:
		_add_edge(root, points[edge[0]], points[edge[1]], 0.035, color.lightened(0.18))


func _add_face(root: Node3D, points: Array, indices: Array, color: Color, alpha := 0.32, emission := 0.75) -> void:
	var vertices := PackedVector3Array(points)
	var packed_indices := PackedInt32Array(indices)
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_INDEX] = packed_indices
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	var face := MeshInstance3D.new()
	face.mesh = mesh
	face.material_override = VisualMaterialsUtil.flat_face(color, alpha, emission)
	root.add_child(face)


func _add_edge(root: Node3D, a: Vector3, b: Vector3, width: float, color: Color) -> void:
	_add_styled_edge(root, a, b, width, color, 0.96, 2.1, true)


func _add_styled_edge(root: Node3D, a: Vector3, b: Vector3, width: float, color: Color, alpha: float, emission: float, additive: bool, priority := 0) -> void:
	var direction := b - a
	var edge := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(width, width, direction.length())
	edge.mesh = mesh
	edge.position = (a + b) * 0.5
	edge.quaternion = Quaternion(Vector3.FORWARD, direction.normalized())
	var material := VisualMaterialsUtil.outline(color, alpha, emission) if additive else VisualMaterialsUtil.transparent_outline(color, alpha, emission)
	material.render_priority = priority
	edge.material_override = material
	root.add_child(edge)
