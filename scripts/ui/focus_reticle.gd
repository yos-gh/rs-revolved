class_name FocusReticle
extends Control

# A quiet lock-on frame around the ship plus scrolling rulers on the side edges. Brackets
# snap 45 degrees on every bar of the music, the tick ring and its arcs turn slowly, and
# the rulers scroll with game time so they slow down in bullet time. The frame leans in 3D
# with the ship's movement.
#
# Two alert levels from the nearest enemy or hostile bullet: inside the wide caution radius
# the tick ring spins up and its ticks reach toward the ship; inside the narrow danger
# radius the brackets also close in on the ship (focusing) and the arcs turn magenta.

const BEATS_PER_SNAP := 4
const FALLBACK_BEAT_SECONDS := 0.5
const SNAP_EASE_TIME := 0.14
const FADE_IN := 2.5
const FADE_OUT := 8.0
const STEP_FPS := 15.0

# Sizes are in screen heights so the frame keeps its proportion at any window size.
const BRACKET_RADIUS := 0.120
const BRACKET_ARM := 0.18
const RING_RADIUS := 0.168
const ARC_COUNT := 3
const ARC_SPAN := 0.7
const ARC_INSET := 5.0
const ARC_SPIN := 1.6
const ARC_SEGMENTS := 12
const RING_TICKS := 32
const RING_LONG_EVERY := 8
const RING_SPIN := -0.30
const RULER_X := 12.0
const RULER_TOP := 0.30
const RULER_BOTTOM := 0.70
const RULER_SPACING := 10.0
const RULER_LONG_EVERY := 5
const RULER_SPEED := 22.0

# Threats closer than a radius count fully; the response fades out by ALERT_SOFT times it.
const CAUTION_RADIUS := 0.32
const DANGER_RADIUS := 0.15
const ALERT_SOFT := 1.2
const DANGER_RISE := 10.0
const DANGER_FALL := 2.5
const CAUTION_RISE := 8.0
const CAUTION_FALL := 2.0
# Brackets close in by this share of their radius while an enemy is near.
const FOCUS_SQUEEZE := 0.28
const CAUTION_SPIN := 15.0
const CAUTION_TICK_GROWTH := 9.0

# Lean: the side the ship moves toward tips away from the viewer.
const TILT_MAX := deg_to_rad(38.0)
const TILT_FOLLOW := 7.0
const TILT_DEPTH := 3.0

const BRACKET_ALPHA := 0.62
# Long ticks read clearly; short ones stay faint between them.
const RING_LONG_ALPHA := 0.62
const RING_SHORT_ALPHA := 0.26
const ARC_COLOR := Color(0.86, 0.98, 1.0, 0.26)
const DANGER_COLOR := Color(1.0, 0.20, 0.52, 0.80)
const CAUTION_COLOR := Color(0.92, 1.0, 0.98)
const RULER_COLOR := Color(0.72, 0.82, 0.80)
const RULER_LONG_ALPHA := 0.50
const RULER_SHORT_ALPHA := 0.18

var line_color := Color(0.32, 0.95, 0.86)
var _shown := 0.0
var _focus := Vector2.ZERO
var _snap_index := 0
var _snap_age := 10.0
var _spin := 0.0
var _arc_spin := 0.0
var _scroll := 0.0
var _free_beat := 0.0
var _time := 0.0
var _danger := 0.0
var _caution := 0.0
var _lean := Vector2.ZERO
var _tilt_axis := Vector2.RIGHT
var _tilt_cos := 1.0
var _tilt_sin := 0.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_TOP_LEFT)


# `beat_position` is the BGM position in beats (negative without music); `sim_delta` is
# the game-time step, so the rulers follow slowdowns. `motion` is the ship's screen-space
# movement scaled to 0..1 of its top speed. `threat_px` is the screen distance to the
# nearest enemy or hostile bullet (INF when there is none).
func update_reticle(delta: float, sim_delta: float, focus: Vector2, active: bool, beat_position := -1.0, motion := Vector2.ZERO, threat_px := INF) -> void:
	_shown = move_toward(_shown, 1.0 if active else 0.0, delta * (FADE_IN if active else FADE_OUT))
	visible = _shown > 0.001
	if not visible:
		return
	_focus = focus
	position = Vector2.ZERO
	size = get_viewport_rect().size
	_time += delta
	if beat_position < 0.0:
		_free_beat += delta / FALLBACK_BEAT_SECONDS
		beat_position = _free_beat
	var snap_index := floori(beat_position / float(BEATS_PER_SNAP))
	if snap_index != _snap_index:
		_snap_index = snap_index
		_snap_age = 0.0
	_snap_age += delta
	_update_alerts(delta, threat_px)
	var spin_rate := 1.0 + CAUTION_SPIN * _caution
	_spin += sim_delta * RING_SPIN * spin_rate
	_arc_spin -= sim_delta * RING_SPIN * ARC_SPIN
	_scroll = fposmod(_scroll + sim_delta * RULER_SPEED, RULER_SPACING * RULER_LONG_EVERY)
	_update_tilt(delta, motion)
	queue_redraw()


func _update_alerts(delta: float, threat_px: float) -> void:
	var caution := 1.0 - smoothstep(size.y * CAUTION_RADIUS, size.y * CAUTION_RADIUS * ALERT_SOFT, threat_px)
	var danger := 1.0 - smoothstep(size.y * DANGER_RADIUS, size.y * DANGER_RADIUS * ALERT_SOFT, threat_px)
	_caution = move_toward(_caution, caution, delta * (CAUTION_RISE if caution > _caution else CAUTION_FALL))
	_danger = move_toward(_danger, danger, delta * (DANGER_RISE if danger > _danger else DANGER_FALL))


func _update_tilt(delta: float, motion: Vector2) -> void:
	_lean = _lean.lerp(motion.limit_length(1.0), minf(1.0, delta * TILT_FOLLOW))
	var amount := _lean.length()
	if amount > 0.001:
		_tilt_axis = _lean / amount
	var angle := TILT_MAX * amount
	_tilt_cos = cos(angle)
	_tilt_sin = sin(angle)


# Projects a frame-plane offset from the ship after leaning the plane: the component along
# the lean direction is foreshortened and pushed away, with a simple perspective divide.
func _lean_point(offset: Vector2) -> Vector2:
	var along := offset.dot(_tilt_axis)
	var across := offset - _tilt_axis * along
	var depth := along * _tilt_sin
	var focal := size.y * RING_RADIUS * TILT_DEPTH
	var persp := focal / maxf(focal * 0.2, focal + depth)
	return _focus + (_tilt_axis * along * _tilt_cos + across) * persp


func _draw() -> void:
	var h := size.y
	if h <= 0.0:
		return
	_draw_brackets(h)
	_draw_ring(h)
	_draw_rulers()


func _draw_brackets(h: float) -> void:
	var snap := 1.0 - pow(1.0 - clampf(_snap_age / SNAP_EASE_TIME, 0.0, 1.0), 3.0)
	var turn := (float(_snap_index - 1) + snap) * PI * 0.25
	# Focus: the brackets close in on the ship while an enemy is near.
	var focus := smoothstep(0.0, 1.0, _danger)
	var radius := h * BRACKET_RADIUS * (1.0 - FOCUS_SQUEEZE * focus)
	var arm := h * BRACKET_RADIUS * BRACKET_ARM
	var color := Color(line_color, BRACKET_ALPHA * _shown)
	for corner in range(4):
		var a := turn + PI * 0.25 + float(corner) * PI * 0.5
		var tip := Vector2.from_angle(a) * radius
		draw_polyline(PackedVector2Array([
			_lean_point(tip + Vector2.from_angle(a + PI * 0.75) * arm),
			_lean_point(tip),
			_lean_point(tip + Vector2.from_angle(a - PI * 0.75) * arm),
		]), color, 1.0)


func _draw_ring(h: float) -> void:
	var radius := h * RING_RADIUS
	var long_points := PackedVector2Array()
	var short_points := PackedVector2Array()
	# On caution the ticks reach in toward the ship and the short ones flicker.
	var growth := CAUTION_TICK_GROWTH * _caution
	var step := floorf(_time * STEP_FPS)
	for i in range(RING_TICKS):
		var dir := Vector2.from_angle(_spin + float(i) * TAU / float(RING_TICKS))
		if i % RING_LONG_EVERY == 0:
			long_points.append_array([_lean_point(dir * (radius - growth)), _lean_point(dir * (radius + 7.0))])
		elif _caution < 0.05 or _hash(float(i) + step * 7.3) > 0.25 * _caution:
			short_points.append_array([_lean_point(dir * (radius - growth * 0.6)), _lean_point(dir * (radius + 3.0))])
	var long_color := Color(line_color, RING_LONG_ALPHA).lerp(Color(CAUTION_COLOR, 0.85), _caution)
	var short_color := Color(line_color, RING_SHORT_ALPHA).lerp(Color(CAUTION_COLOR, 0.55), _caution)
	long_color.a *= _shown
	short_color.a *= _shown
	draw_multiline(long_points, long_color, 1.0)
	if not short_points.is_empty():
		draw_multiline(short_points, short_color, 1.0)
	# Arcs run inside the ticks, turning the other way and faster; they turn magenta in
	# danger.
	var arc_color := ARC_COLOR.lerp(DANGER_COLOR, _danger)
	arc_color.a *= _shown
	var arc_radius := radius - ARC_INSET
	for i in range(ARC_COUNT):
		var start := _arc_spin + float(i) * TAU / float(ARC_COUNT)
		var arc := PackedVector2Array()
		for s in range(ARC_SEGMENTS + 1):
			arc.append(_lean_point(Vector2.from_angle(start + ARC_SPAN * float(s) / float(ARC_SEGMENTS)) * arc_radius))
		draw_polyline(arc, arc_color, lerpf(1.5, 2.0, _danger))


func _draw_rulers() -> void:
	var top := size.y * RULER_TOP
	var bottom := size.y * RULER_BOTTOM
	var span := bottom - top
	var period := RULER_SPACING * RULER_LONG_EVERY
	for side in range(2):
		var x := RULER_X if side == 0 else size.x - RULER_X
		var inward := 1.0 if side == 0 else -1.0
		# The two sides run in opposite directions.
		var offset := _scroll if side == 0 else period - _scroll
		var y := top - period + offset
		var index := 0
		while y <= bottom:
			if y >= top:
				# Ticks fade toward both ends of the ruler instead of stopping hard.
				var t := (y - top) / span
				var fade := clampf(minf(t, 1.0 - t) * 5.0, 0.0, 1.0)
				var long := index % RULER_LONG_EVERY == 0
				var color := Color(RULER_COLOR, (RULER_LONG_ALPHA if long else RULER_SHORT_ALPHA) * fade * _shown)
				draw_line(Vector2(x, y), Vector2(x + inward * (8.0 if long else 4.0), y), color, 1.0)
			y += RULER_SPACING
			index += 1


func _hash(x: float) -> float:
	return fposmod(sin(x * 12.9898) * 43758.5453, 1.0)
