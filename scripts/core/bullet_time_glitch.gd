class_name BulletTimeGlitch
extends Control

const MIN_VISIBLE_INTENSITY := 0.02
const PLAYER_SOFT_ZONE := 135.0
const PLAYER_CLEAR_ZONE := 52.0
const LINE_COUNT := 96
const RISE_LINE_COUNT := 30
const SEGMENT_MIN_WIDTH := 36.0
const SEGMENT_MAX_WIDTH := 360.0
const BLOCK_COUNT := 22
const TEAR_COUNT := 9

var player_screen_pos := Vector2.ZERO
var intensity := 0.0
var _time := 0.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_TOP_LEFT)
	_sync_viewport_rect()


func update_effect(delta: float, player_pos: Vector2, target_intensity: float) -> void:
	_sync_viewport_rect()
	player_screen_pos = player_pos
	intensity = lerpf(intensity, clampf(target_intensity, 0.0, 1.0), minf(1.0, delta * 8.0))
	_time += delta
	visible = intensity > MIN_VISIBLE_INTENSITY
	queue_redraw()


func _draw() -> void:
	if intensity <= MIN_VISIBLE_INTENSITY:
		return

	var viewport_size := get_viewport_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return
	var pulse := 0.5 + 0.5 * sin(_time * 11.0)
	var base_alpha := (0.155 + pulse * 0.115) * intensity

	for i in range(LINE_COUNT):
		var line_phase := _time * 10.5 + float(i) * 1.91
		var y := fposmod(float(i) * viewport_size.y / float(LINE_COUNT) + sin(line_phase) * 26.0, viewport_size.y)
		var width := lerpf(SEGMENT_MIN_WIDTH, SEGMENT_MAX_WIDTH, abs(sin(_time * 4.0 + float(i) * 0.73))) * (0.68 + intensity)
		var sweep := fposmod(_time * (95.0 + float(i % 7) * 21.0) + float(i) * 137.0, viewport_size.x + width * 2.0) - width
		var alpha := base_alpha * _player_readability_at(Vector2(sweep, y))
		draw_line(Vector2(sweep - width * 0.5, y), Vector2(sweep + width * 0.5, y), _line_color(i, alpha), 1.0 + intensity * 3.0)

		if i % 3 == 0:
			var offset := Vector2(6.0 + intensity * 15.0, 0.0)
			var chroma_alpha := base_alpha * 1.22 * _player_readability_at(Vector2(sweep, y) + offset)
			draw_line(Vector2(sweep - width * 0.45, y) + offset, Vector2(sweep + width * 0.45, y) + offset, Color(1.0, 0.12, 0.40, chroma_alpha), 1.0 + intensity)

	for i in range(RISE_LINE_COUNT):
		var rise_speed := 82.0 + float(i % 6) * 24.0
		var y := viewport_size.y - fposmod(_time * rise_speed + float(i) * 53.0, viewport_size.y + 36.0)
		var wobble := sin(_time * 6.5 + float(i) * 1.37) * 28.0
		var center_x := viewport_size.x * (0.5 + 0.48 * sin(float(i) * 2.09 + _time * 0.55)) + wobble
		var width := lerpf(viewport_size.x * 0.18, viewport_size.x * 0.62, abs(sin(_time * 2.3 + float(i) * 0.61)))
		var alpha := base_alpha * 0.82 * _player_readability_at(Vector2(center_x, y))
		draw_line(Vector2(center_x - width * 0.5, y), Vector2(center_x + width * 0.5, y), Color(0.64, 0.92, 1.0, alpha), 1.0 + intensity * 1.8)

		if i % 3 == 0:
			var chroma_offset := Vector2(0.0, -2.0 - intensity * 5.0)
			var chroma_alpha := base_alpha * 0.55 * _player_readability_at(Vector2(center_x, y) + chroma_offset)
			draw_line(Vector2(center_x - width * 0.45, y), Vector2(center_x + width * 0.45, y) + chroma_offset, Color(1.0, 0.22, 0.54, chroma_alpha), 1.0)

	for i in range(BLOCK_COUNT):
		var phase := _time * 6.0 + float(i) * 2.4
		var block_size := Vector2(lerpf(48.0, 230.0, abs(sin(phase))), lerpf(5.0, 22.0, abs(cos(phase * 0.7))))
		var pos := Vector2(
			fposmod(_time * (70.0 + float(i) * 13.0) + float(i) * 211.0, viewport_size.x + block_size.x) - block_size.x,
			fposmod(float(i) * 83.0 + sin(phase) * 70.0, viewport_size.y)
		)
		var block_alpha := base_alpha * 1.05 * _player_readability_at(pos + block_size * 0.5)
		draw_rect(Rect2(pos, block_size), _line_color(i + LINE_COUNT, block_alpha))

	for i in range(TEAR_COUNT):
		var phase := _time * (8.0 + float(i % 3) * 1.7) + float(i) * 3.91
		var y := fposmod(float(i) * 97.0 + sin(phase) * viewport_size.y * 0.42, viewport_size.y)
		var tear_height := lerpf(2.0, 8.0, abs(sin(phase * 0.73)))
		var tear_alpha := base_alpha * (0.32 + pulse * 0.34) * _player_readability_at(Vector2(viewport_size.x * 0.5, y))
		draw_rect(Rect2(0.0, y, viewport_size.x, tear_height), Color(0.58, 0.94, 1.0, tear_alpha))
		var chroma_y := y + 3.0 + intensity * 5.0
		draw_rect(Rect2(0.0, chroma_y, viewport_size.x, maxf(1.0, tear_height * 0.35)), Color(1.0, 0.10, 0.38, tear_alpha * 0.72))

func _line_color(index: int, alpha: float) -> Color:
	if index % 3 == 0:
		return Color(0.20, 0.95, 1.0, alpha)
	if index % 3 == 1:
		return Color(1.0, 0.20, 0.50, alpha * 0.75)
	return Color(0.85, 1.0, 0.35, alpha * 0.55)


func _player_readability_at(pos: Vector2) -> float:
	var distance := pos.distance_to(player_screen_pos)
	if distance <= PLAYER_CLEAR_ZONE:
		return 0.28
	if distance >= PLAYER_CLEAR_ZONE + PLAYER_SOFT_ZONE:
		return 1.0
	var t := inverse_lerp(PLAYER_CLEAR_ZONE, PLAYER_CLEAR_ZONE + PLAYER_SOFT_ZONE, distance)
	return lerpf(0.28, 1.0, t)


func _sync_viewport_rect() -> void:
	position = Vector2.ZERO
	size = get_viewport_rect().size
