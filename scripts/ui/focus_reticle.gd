class_name FocusReticle
extends Control

# A quiet lock-on frame around the ship plus scrolling rulers on the side edges. Brackets
# snap 45 degrees on every bar of the music, the tick ring and its arcs turn slowly, and
# the rulers scroll with game time so they slow down in bullet time.

const BEATS_PER_SNAP := 4
const FALLBACK_BEAT_SECONDS := 0.5
const SNAP_EASE_TIME := 0.14
const FADE_IN := 2.5
const FADE_OUT := 8.0

# Sizes are in screen heights so the frame keeps its proportion at any window size.
const BRACKET_RADIUS := 0.120
const BRACKET_ARM := 0.18
const RING_RADIUS := 0.168
const ARC_COUNT := 3
const ARC_SPAN := 0.7
const ARC_INSET := 5.0
const ARC_SPIN := 1.6
const RING_TICKS := 32
const RING_LONG_EVERY := 8
const RING_SPIN := -0.30
const RULER_X := 12.0
const RULER_TOP := 0.30
const RULER_BOTTOM := 0.70
const RULER_SPACING := 10.0
const RULER_LONG_EVERY := 5
const RULER_SPEED := 22.0

const BRACKET_ALPHA := 0.62
# Long ticks read clearly; short ones stay faint between them.
const RING_LONG_ALPHA := 0.62
const RING_SHORT_ALPHA := 0.26
const ARC_COLOR := Color(0.86, 0.98, 1.0, 0.26)
const RULER_COLOR := Color(0.72, 0.82, 0.80)
const RULER_LONG_ALPHA := 0.50
const RULER_SHORT_ALPHA := 0.18

var line_color := Color(0.32, 0.95, 0.86)
var _shown := 0.0
var _focus := Vector2.ZERO
var _snap_index := 0
var _snap_age := 10.0
var _spin := 0.0
var _scroll := 0.0
var _free_beat := 0.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_TOP_LEFT)


# `beat_position` is the BGM position in beats (negative without music); `sim_delta` is
# the game-time step, so the rulers follow slowdowns.
func update_reticle(delta: float, sim_delta: float, focus: Vector2, active: bool, beat_position := -1.0) -> void:
	_shown = move_toward(_shown, 1.0 if active else 0.0, delta * (FADE_IN if active else FADE_OUT))
	visible = _shown > 0.001
	if not visible:
		return
	_focus = focus
	position = Vector2.ZERO
	size = get_viewport_rect().size
	if beat_position < 0.0:
		_free_beat += delta / FALLBACK_BEAT_SECONDS
		beat_position = _free_beat
	var snap_index := floori(beat_position / float(BEATS_PER_SNAP))
	if snap_index != _snap_index:
		_snap_index = snap_index
		_snap_age = 0.0
	_snap_age += delta
	_spin += sim_delta * RING_SPIN
	_scroll = fposmod(_scroll + sim_delta * RULER_SPEED, RULER_SPACING * RULER_LONG_EVERY)
	queue_redraw()


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
	var radius := h * BRACKET_RADIUS
	var arm := radius * BRACKET_ARM
	var color := Color(line_color, BRACKET_ALPHA * _shown)
	for corner in range(4):
		var a := turn + PI * 0.25 + float(corner) * PI * 0.5
		var tip := _focus + Vector2.from_angle(a) * radius
		draw_polyline(PackedVector2Array([
			tip + Vector2.from_angle(a + PI * 0.75) * arm,
			tip,
			tip + Vector2.from_angle(a - PI * 0.75) * arm,
		]), color, 1.0)


func _draw_ring(h: float) -> void:
	var radius := h * RING_RADIUS
	var long_points := PackedVector2Array()
	var short_points := PackedVector2Array()
	for i in range(RING_TICKS):
		var dir := Vector2.from_angle(_spin + float(i) * TAU / float(RING_TICKS))
		if i % RING_LONG_EVERY == 0:
			long_points.append_array([_focus + dir * radius, _focus + dir * (radius + 7.0)])
		else:
			short_points.append_array([_focus + dir * radius, _focus + dir * (radius + 3.0)])
	draw_multiline(long_points, Color(line_color, RING_LONG_ALPHA * _shown), 1.0)
	draw_multiline(short_points, Color(line_color, RING_SHORT_ALPHA * _shown), 1.0)
	# Arcs run inside the ticks, turning the other way and faster.
	var arc_color := Color(ARC_COLOR, ARC_COLOR.a * _shown)
	for i in range(ARC_COUNT):
		var start := -_spin * ARC_SPIN + float(i) * TAU / float(ARC_COUNT)
		draw_arc(_focus, radius - ARC_INSET, start, start + ARC_SPAN, 32, arc_color, 1.5)


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
